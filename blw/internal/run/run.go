package run

import (
	"fmt"
	"os"
	"os/exec"
)

// Cmd runs a command with args, inheriting stdin/stdout/stderr.
func Cmd(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// CmdOutput runs a command and returns its stdout as a string.
func CmdOutput(name string, args ...string) (string, error) {
	out, err := exec.Command(name, args...).Output()
	return string(out), err
}

// CmdPipe runs a command piping its stdout to xclip (or similar).
func CmdPipe(from *exec.Cmd, toName string, toArgs ...string) error {
	to := exec.Command(toName, toArgs...)
	to.Stdin, _ = from.StdoutPipe()
	to.Stdout = os.Stdout
	to.Stderr = os.Stderr
	if err := to.Start(); err != nil {
		return err
	}
	if err := from.Run(); err != nil {
		return fmt.Errorf("source command failed: %w", err)
	}
	return to.Wait()
}

// Which checks if a binary is available in PATH.
func Which(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}
