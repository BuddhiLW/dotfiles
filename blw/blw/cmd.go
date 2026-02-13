package blw

import (
	"fmt"

	"github.com/BuddhiLW/bonzai"
)

func showHelp(cmd *bonzai.Cmd) error {
	fmt.Printf("Name: %s\n", cmd.Name)
	if cmd.Short != "" {
		fmt.Printf("Description: %s\n", cmd.Short)
	}
	if cmd.Vers != "" {
		fmt.Printf("Version: %s\n", cmd.Vers)
	}
	if cmd.Usage != "" {
		fmt.Printf("Usage: %s\n", cmd.Usage)
	}
	if len(cmd.Cmds) > 0 {
		fmt.Println("\nCommands:")
		for _, c := range cmd.Cmds {
			if c.Name != "" && !c.IsHidden() {
				fmt.Printf("  %-12s %s\n", c.Name, c.Short)
			}
		}
	}
	if cmd.Long != "" {
		fmt.Printf("\n%s\n", cmd.Long)
	}
	return nil
}

var HelpCmd = &bonzai.Cmd{
	Name:  `help`,
	Alias: `h|?`,
	Short: `display help information`,
	Do: func(x *bonzai.Cmd, args ...string) error {
		caller := x.Caller()
		if caller != nil && caller != x {
			return showHelp(caller)
		}
		return showHelp(x)
	},
}

var Cmd = &bonzai.Cmd{
	Name:  `blw`,
	Short: `buddhilw utility commands`,
	Vers:  `v0.1.0`,
	Cmds: []*bonzai.Cmd{
		HelpCmd,
		ScreenshotCmd,
		ScreenCmd,
		DisplayCmd,
		DockerCmd,
		ClipCmd,
		WalCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}
