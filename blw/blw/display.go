package blw

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/BuddhiLW/bonzai"
)

var DisplayCmd = &bonzai.Cmd{
	Name:  `display`,
	Alias: `disp|dp`,
	Short: `display and monitor management via xrandr`,
	Cmds: []*bonzai.Cmd{
		displaySelectCmd,
		displayLayoutCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}

// connectedDisplays queries xrandr for connected outputs.
func connectedDisplays() ([]string, error) {
	out, err := exec.Command("xrandr", "--query").Output()
	if err != nil {
		return nil, fmt.Errorf("xrandr query failed: %w", err)
	}
	var displays []string
	for _, line := range strings.Split(string(out), "\n") {
		if strings.Contains(line, " connected") {
			fields := strings.Fields(line)
			if len(fields) > 0 {
				displays = append(displays, fields[0])
			}
		}
	}
	return displays, nil
}

var displaySelectCmd = &bonzai.Cmd{
	Name:   `select`,
	Alias:  `sel`,
	Short:  `interactive display setup via dmenu`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		displays, err := connectedDisplays()
		if err != nil {
			return err
		}
		if len(displays) < 2 {
			fmt.Println("Only one display connected, nothing to configure.")
			return nil
		}

		// Ask which display to use as primary
		choices := strings.Join(displays, "\n")
		dm := exec.Command("dmenu", "-i", "-p", "Primary display:")
		dm.Stdin = strings.NewReader(choices)
		dm.Stderr = os.Stderr
		out, err := dm.Output()
		if err != nil {
			return nil // user cancelled
		}
		primary := strings.TrimSpace(string(out))

		// Ask for layout mode
		modes := "mirror\nextend-right\nextend-left\nextend-above\nextend-below\nonly"
		dm2 := exec.Command("dmenu", "-i", "-p", "Layout mode:")
		dm2.Stdin = strings.NewReader(modes)
		dm2.Stderr = os.Stderr
		out2, err := dm2.Output()
		if err != nil {
			return nil // user cancelled
		}
		mode := strings.TrimSpace(string(out2))

		// Build xrandr command
		xrandrArgs := []string{"--output", primary, "--auto", "--primary"}

		switch mode {
		case "only":
			// Disable all other displays
			for _, d := range displays {
				if d != primary {
					xrandrArgs = append(xrandrArgs, "--output", d, "--off")
				}
			}
		case "mirror":
			for _, d := range displays {
				if d != primary {
					xrandrArgs = append(xrandrArgs, "--output", d, "--auto", "--same-as", primary)
				}
			}
		default:
			// extend modes
			posFlag := "--right-of"
			switch mode {
			case "extend-left":
				posFlag = "--left-of"
			case "extend-above":
				posFlag = "--above"
			case "extend-below":
				posFlag = "--below"
			}
			for _, d := range displays {
				if d != primary {
					xrandrArgs = append(xrandrArgs, "--output", d, "--auto", posFlag, primary)
				}
			}
		}

		fmt.Printf("Running: xrandr %s\n", strings.Join(xrandrArgs, " "))
		cmd := exec.Command("xrandr", xrandrArgs...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}

var displayLayoutCmd = &bonzai.Cmd{
	Name:   `layout`,
	Alias:  `lay|l`,
	Short:  `apply preset dual-monitor layout`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		displays, err := connectedDisplays()
		if err != nil {
			return err
		}

		// Check if HDMI display is present
		hasHDMI := false
		hdmiName := ""
		laptopName := ""
		for _, d := range displays {
			if strings.HasPrefix(d, "HDMI") {
				hasHDMI = true
				hdmiName = d
			}
			if strings.HasPrefix(d, "eDP") {
				laptopName = d
			}
		}

		if laptopName == "" {
			// fallback: use first display
			if len(displays) > 0 {
				laptopName = displays[0]
			} else {
				return fmt.Errorf("no displays found")
			}
		}

		if !hasHDMI || len(displays) < 2 {
			// Single display fallback
			fmt.Printf("Single display mode: %s\n", laptopName)
			cmd := exec.Command("xrandr",
				"--output", laptopName, "--auto", "--primary",
			)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			return cmd.Run()
		}

		// Dual monitor: eDP-1 at 1920x1200 + HDMI at 2560x1080
		fmt.Printf("Dual monitor: %s (1920x1200) + %s (2560x1080)\n", laptopName, hdmiName)
		cmd := exec.Command("xrandr",
			"--output", laptopName, "--mode", "1920x1200", "--primary",
			"--output", hdmiName, "--mode", "2560x1080", "--right-of", laptopName,
		)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}
