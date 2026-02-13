package blw

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/BuddhiLW/bonzai"
)

func screenshotTimestamp() string {
	return time.Now().Format("060102-1504-05")
}

var ScreenshotCmd = &bonzai.Cmd{
	Name:  `screenshot`,
	Alias: `ss`,
	Short: `take screenshots with maim`,
	Cmds: []*bonzai.Cmd{
		screenshotDmenuCmd,
		screenshotSelectionCmd,
		screenshotWindowCmd,
		screenshotFullCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}

var screenshotDmenuCmd = &bonzai.Cmd{
	Name:   `dmenu`,
	Alias:  `dm`,
	Short:  `choose screenshot type via dmenu`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		choices := "a selected area\ncurrent window\nfull screen\na selected area (copy)\ncurrent window (copy)\nfull screen (copy)"
		dm := exec.Command("dmenu", "-l", "6", "-i", "-p", "Screenshot which area?")
		dm.Stdin = strings.NewReader(choices)
		dm.Stderr = os.Stderr
		out, err := dm.Output()
		if err != nil {
			return nil // user cancelled
		}
		choice := strings.TrimSpace(string(out))
		ts := screenshotTimestamp()

		switch choice {
		case "a selected area":
			return screenshotSelection("pic-selected-"+ts+".png", false)
		case "current window":
			return screenshotWindow("pic-window-"+ts+".png", false)
		case "full screen":
			return screenshotFull("pic-full-"+ts+".png", false)
		case "a selected area (copy)":
			return screenshotSelection("", true)
		case "current window (copy)":
			return screenshotWindow("", true)
		case "full screen (copy)":
			return screenshotFull("", true)
		}
		return nil
	},
}

var screenshotSelectionCmd = &bonzai.Cmd{
	Name:  `selection`,
	Alias: `sel|s`,
	Short: `screenshot a selected area`,
	Opts:  `copy`,
	Do: func(x *bonzai.Cmd, args ...string) error {
		cp := len(args) > 0 && args[0] == "copy"
		file := ""
		if !cp {
			file = "pic-selected-" + screenshotTimestamp() + ".png"
		}
		return screenshotSelection(file, cp)
	},
}

var screenshotWindowCmd = &bonzai.Cmd{
	Name:  `window`,
	Alias: `win|w`,
	Short: `screenshot the active window`,
	Opts:  `copy`,
	Do: func(x *bonzai.Cmd, args ...string) error {
		cp := len(args) > 0 && args[0] == "copy"
		file := ""
		if !cp {
			file = "pic-window-" + screenshotTimestamp() + ".png"
		}
		return screenshotWindow(file, cp)
	},
}

var screenshotFullCmd = &bonzai.Cmd{
	Name:  `full`,
	Alias: `f`,
	Short: `screenshot the full screen`,
	Opts:  `copy`,
	Do: func(x *bonzai.Cmd, args ...string) error {
		cp := len(args) > 0 && args[0] == "copy"
		file := ""
		if !cp {
			file = "pic-full-" + screenshotTimestamp() + ".png"
		}
		return screenshotFull(file, cp)
	},
}

func screenshotSelection(file string, toClip bool) error {
	geom, err := exec.Command("slop", "-f", "%g").Output()
	if err != nil {
		return fmt.Errorf("slop cancelled or failed: %w", err)
	}

	g := strings.TrimSpace(string(geom))
	if toClip {
		return pipeToClip(exec.Command("maim", "-g", g))
	}
	return exec.Command("maim", "-g", g, file).Run()
}

func screenshotWindow(file string, toClip bool) error {
	wid, err := exec.Command("xdotool", "getactivewindow").Output()
	if err != nil {
		return fmt.Errorf("xdotool failed: %w", err)
	}

	w := strings.TrimSpace(string(wid))
	if toClip {
		return pipeToClip(exec.Command("maim", "-q", "-i", w))
	}
	return exec.Command("maim", "-q", "-i", w, file).Run()
}

func screenshotFull(file string, toClip bool) error {
	if toClip {
		return pipeToClip(exec.Command("maim", "-q"))
	}
	return exec.Command("maim", "-q", file).Run()
}

func pipeToClip(src *exec.Cmd) error {
	clip := exec.Command("xclip", "-sel", "clip", "-t", "image/png")
	clip.Stdin, _ = src.StdoutPipe()
	clip.Stdout = os.Stdout
	if err := clip.Start(); err != nil {
		return err
	}
	if err := src.Run(); err != nil {
		return err
	}
	return clip.Wait()
}
