package blw

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/BuddhiLW/bonzai"
)

var ClipCmd = &bonzai.Cmd{
	Name:  `clip`,
	Alias: `cl`,
	Short: `clipboard operations via xclip`,
	Cmds: []*bonzai.Cmd{
		clipInCmd,
		clipOutCmd,
		clipFileCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}

var clipInCmd = &bonzai.Cmd{
	Name:   `in`,
	Alias:  `i`,
	Short:  `pipe stdin to clipboard`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		cmd := exec.Command("xclip", "-selection", "clipboard")
		cmd.Stdin = os.Stdin
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("xclip failed: %w", err)
		}
		return nil
	},
}

var clipOutCmd = &bonzai.Cmd{
	Name:   `out`,
	Alias:  `o`,
	Short:  `paste clipboard to stdout`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		cmd := exec.Command("xclip", "-selection", "clipboard", "-o")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("xclip failed: %w", err)
		}
		return nil
	},
}

var clipFileCmd = &bonzai.Cmd{
	Name:  `file`,
	Alias: `f|copy`,
	Short: `copy a file's contents to clipboard`,
	Do: func(x *bonzai.Cmd, args ...string) error {
		if len(args) < 1 {
			return fmt.Errorf("usage: clip file <path>")
		}
		f, err := os.Open(args[0])
		if err != nil {
			return fmt.Errorf("cannot open %s: %w", args[0], err)
		}
		defer f.Close()

		cmd := exec.Command("xclip", "-in", "-selection", "clipboard")
		cmd.Stdin = f
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return fmt.Errorf("xclip failed: %w", err)
		}
		fmt.Printf("Copied %s to clipboard.\n", args[0])
		return nil
	},
}
