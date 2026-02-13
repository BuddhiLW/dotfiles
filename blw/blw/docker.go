package blw

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/BuddhiLW/bonzai"
)

var DockerCmd = &bonzai.Cmd{
	Name:  `docker`,
	Alias: `dk`,
	Short: `docker utility commands`,
	Cmds: []*bonzai.Cmd{
		dockerStopCmd,
		dockerRmCmd,
		dockerUpCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}

// dockerContainerIDs returns running container IDs.
func dockerContainerIDs(all bool) ([]string, error) {
	args := []string{"ps", "-q"}
	if all {
		args = append(args, "-a")
	}
	out, err := exec.Command("docker", args...).Output()
	if err != nil {
		return nil, err
	}
	raw := strings.TrimSpace(string(out))
	if raw == "" {
		return nil, nil
	}
	return strings.Split(raw, "\n"), nil
}

var dockerStopCmd = &bonzai.Cmd{
	Name:   `stop`,
	Alias:  `s`,
	Short:  `stop all running docker containers`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		ids, err := dockerContainerIDs(false)
		if err != nil {
			return fmt.Errorf("failed to list containers: %w", err)
		}
		if len(ids) == 0 {
			fmt.Println("No running containers.")
			return nil
		}
		fmt.Printf("Stopping %d container(s)...\n", len(ids))
		stopArgs := append([]string{"stop"}, ids...)
		cmd := exec.Command("docker", stopArgs...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}

var dockerRmCmd = &bonzai.Cmd{
	Name:   `rm`,
	Short:  `stop and remove all docker containers`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		// Stop first
		ids, err := dockerContainerIDs(false)
		if err != nil {
			return fmt.Errorf("failed to list containers: %w", err)
		}
		if len(ids) > 0 {
			fmt.Printf("Stopping %d container(s)...\n", len(ids))
			stopArgs := append([]string{"stop"}, ids...)
			stop := exec.Command("docker", stopArgs...)
			stop.Stdout = os.Stdout
			stop.Stderr = os.Stderr
			if err := stop.Run(); err != nil {
				return fmt.Errorf("stop failed: %w", err)
			}
		}

		// Remove all (including stopped)
		allIDs, err := dockerContainerIDs(true)
		if err != nil {
			return fmt.Errorf("failed to list all containers: %w", err)
		}
		if len(allIDs) == 0 {
			fmt.Println("No containers to remove.")
			return nil
		}
		fmt.Printf("Removing %d container(s)...\n", len(allIDs))
		rmArgs := append([]string{"rm"}, allIDs...)
		cmd := exec.Command("docker", rmArgs...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}

var dockerUpCmd = &bonzai.Cmd{
	Name:   `up`,
	Short:  `start docker desktop via systemctl`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		fmt.Println("Starting Docker Desktop...")
		cmd := exec.Command("systemctl", "--user", "start", "docker-desktop")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}
