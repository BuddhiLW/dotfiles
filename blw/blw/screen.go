package blw

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"time"

	"github.com/BuddhiLW/bonzai"
)

func screenTimestamp() string {
	return time.Now().Format("2006-01-02-15-04-05")
}

func screenDisplay() string {
	d := os.Getenv("DISPLAY")
	if d == "" {
		d = ":0"
	}
	return d
}

func screenResolution() string {
	out, err := exec.Command("xdpyinfo").Output()
	if err != nil {
		return "2560x1600"
	}
	// parse "dimensions: WxH pixels" from xdpyinfo
	for _, line := range splitLines(string(out)) {
		if containsStr(line, "dimensions:") {
			fields := splitFields(line)
			for i, f := range fields {
				if f == "dimensions:" && i+1 < len(fields) {
					return fields[i+1]
				}
			}
		}
	}
	return "2560x1600"
}

// splitLines splits a string by newlines.
func splitLines(s string) []string {
	var lines []string
	start := 0
	for i := 0; i < len(s); i++ {
		if s[i] == '\n' {
			lines = append(lines, s[start:i])
			start = i + 1
		}
	}
	if start < len(s) {
		lines = append(lines, s[start:])
	}
	return lines
}

// splitFields splits by whitespace.
func splitFields(s string) []string {
	var fields []string
	inField := false
	start := 0
	for i := 0; i < len(s); i++ {
		if s[i] == ' ' || s[i] == '\t' {
			if inField {
				fields = append(fields, s[start:i])
				inField = false
			}
		} else {
			if !inField {
				start = i
				inField = true
			}
		}
	}
	if inField {
		fields = append(fields, s[start:])
	}
	return fields
}

// containsStr checks if s contains substr.
func containsStr(s, substr string) bool {
	return len(s) >= len(substr) && searchStr(s, substr)
}

func searchStr(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

var ScreenCmd = &bonzai.Cmd{
	Name:  `screen`,
	Alias: `scr`,
	Short: `screen recording via ffmpeg`,
	Cmds: []*bonzai.Cmd{
		screenRecordCmd,
		screenRecordAudioCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}

var screenRecordCmd = &bonzai.Cmd{
	Name:   `record`,
	Alias:  `rec|r`,
	Short:  `record screen to mp4 (video only)`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		return screenRecord(false)
	},
}

var screenRecordAudioCmd = &bonzai.Cmd{
	Name:   `record-audio`,
	Alias:  `reca|ra`,
	Short:  `record screen with audio to mp4`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		return screenRecord(true)
	},
}

func screenRecord(withAudio bool) error {
	outFile := fmt.Sprintf("screen-capture-%s.mp4", screenTimestamp())
	display := screenDisplay()
	res := screenResolution()

	ffArgs := []string{
		"-y",
		"-f", "x11grab",
		"-framerate", "30",
		"-video_size", res,
		"-i", display,
	}

	if withAudio {
		ffArgs = append(ffArgs,
			"-f", "alsa",
			"-i", "default",
			"-c:a", "aac",
		)
	}

	ffArgs = append(ffArgs,
		"-c:v", "libx264",
		"-preset", "ultrafast",
		"-crf", "20",
		outFile,
	)

	cmd := exec.Command("ffmpeg", ffArgs...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("ffmpeg start failed: %w", err)
	}

	fmt.Printf("Recording to %s (press Ctrl+C to stop)...\n", outFile)

	// Wait for interrupt signal to stop recording gracefully
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	done := make(chan error, 1)
	go func() {
		done <- cmd.Wait()
	}()

	select {
	case <-sigCh:
		// Send SIGINT to ffmpeg for graceful shutdown (writes trailer)
		cmd.Process.Signal(syscall.SIGINT)
		<-done
		fmt.Printf("\nSaved: %s\n", outFile)
		return nil
	case err := <-done:
		if err != nil {
			return fmt.Errorf("ffmpeg exited: %w", err)
		}
		fmt.Printf("Saved: %s\n", outFile)
		return nil
	}
}
