package blw

import (
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/BuddhiLW/bonzai"
)

var WalCmd = &bonzai.Cmd{
	Name:  `wal`,
	Alias: `w`,
	Short: `wallpaper and colorscheme management`,
	Cmds: []*bonzai.Cmd{
		walRandomCmd,
		walPsychedelicCmd,
		walSetbgCmd,
	},
	Do: func(x *bonzai.Cmd, args ...string) error {
		return showHelp(x)
	},
}

func wallpaperDir() string {
	d := os.Getenv("WALLPAPER_DIR")
	if d != "" {
		return d
	}
	return filepath.Join(os.Getenv("HOME"), "Pictures", "Wallpapers", "Animated")
}

// videoExtensions lists common video file extensions for animated wallpapers.
var videoExtensions = map[string]bool{
	".mp4":  true,
	".mkv":  true,
	".webm": true,
	".avi":  true,
	".mov":  true,
	".gif":  true,
}

func findVideoFiles(dir string) ([]string, error) {
	var files []string
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("cannot read %s: %w", dir, err)
	}
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		ext := strings.ToLower(filepath.Ext(e.Name()))
		if videoExtensions[ext] {
			files = append(files, filepath.Join(dir, e.Name()))
		}
	}
	return files, nil
}

var walRandomCmd = &bonzai.Cmd{
	Name:   `random`,
	Alias:  `rand|r`,
	Short:  `set random animated wallpaper via lazywal`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		dir := wallpaperDir()
		files, err := findVideoFiles(dir)
		if err != nil {
			return err
		}
		if len(files) == 0 {
			return fmt.Errorf("no video files found in %s", dir)
		}

		rng := rand.New(rand.NewSource(time.Now().UnixNano()))
		pick := files[rng.Intn(len(files))]
		fmt.Printf("Setting wallpaper: %s\n", filepath.Base(pick))

		cmd := exec.Command("lazywal", "set", pick)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}

var walPsychedelicCmd = &bonzai.Cmd{
	Name:   `psychedelic`,
	Alias:  `psy|p`,
	Short:  `set psychedelic animated wallpaper`,
	NoArgs: true,
	Do: func(x *bonzai.Cmd, args ...string) error {
		gif := filepath.Join(os.Getenv("HOME"), "Pictures", "Wallpapers", "Animated", "psychedelic.gif")
		if _, err := os.Stat(gif); os.IsNotExist(err) {
			// Try finding any gif with psychedelic in name
			dir := wallpaperDir()
			entries, err := os.ReadDir(dir)
			if err != nil {
				return fmt.Errorf("cannot read wallpaper dir: %w", err)
			}
			for _, e := range entries {
				if strings.Contains(strings.ToLower(e.Name()), "psychedelic") {
					gif = filepath.Join(dir, e.Name())
					break
				}
			}
		}

		fmt.Printf("Setting psychedelic wallpaper: %s\n", filepath.Base(gif))
		cmd := exec.Command("lazywal", "set", gif)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	},
}

var walSetbgCmd = &bonzai.Cmd{
	Name:  `setbg`,
	Alias: `bg|set`,
	Short: `set static wallpaper image`,
	Do: func(x *bonzai.Cmd, args ...string) error {
		var target string

		if len(args) > 0 {
			target = args[0]
		} else {
			// Use dmenu to pick from wallpaper directories
			home := os.Getenv("HOME")
			wallDirs := []string{
				filepath.Join(home, "Pictures", "Wallpapers"),
				filepath.Join(home, "Pictures"),
			}

			var images []string
			for _, dir := range wallDirs {
				matches, _ := filepath.Glob(filepath.Join(dir, "*.png"))
				images = append(images, matches...)
				matches, _ = filepath.Glob(filepath.Join(dir, "*.jpg"))
				images = append(images, matches...)
				matches, _ = filepath.Glob(filepath.Join(dir, "*.jpeg"))
				images = append(images, matches...)
			}

			if len(images) == 0 {
				return fmt.Errorf("no images found in wallpaper directories")
			}

			// Show basenames in dmenu
			var names []string
			nameToPath := make(map[string]string)
			for _, img := range images {
				name := filepath.Base(img)
				names = append(names, name)
				nameToPath[name] = img
			}

			dm := exec.Command("dmenu", "-i", "-l", "20", "-p", "Wallpaper:")
			dm.Stdin = strings.NewReader(strings.Join(names, "\n"))
			dm.Stderr = os.Stderr
			out, err := dm.Output()
			if err != nil {
				return nil // user cancelled
			}
			choice := strings.TrimSpace(string(out))
			if p, ok := nameToPath[choice]; ok {
				target = p
			} else {
				return fmt.Errorf("unknown selection: %s", choice)
			}
		}

		info, err := os.Stat(target)
		if err != nil {
			return fmt.Errorf("cannot access %s: %w", target, err)
		}

		// If directory, pick random image from it
		if info.IsDir() {
			var images []string
			for _, ext := range []string{"*.png", "*.jpg", "*.jpeg"} {
				matches, _ := filepath.Glob(filepath.Join(target, ext))
				images = append(images, matches...)
			}
			if len(images) == 0 {
				return fmt.Errorf("no images in %s", target)
			}
			rng := rand.New(rand.NewSource(time.Now().UnixNano()))
			target = images[rng.Intn(len(images))]
		}

		// Symlink to ~/.local/share/bg
		bgLink := filepath.Join(os.Getenv("HOME"), ".local", "share", "bg")
		os.MkdirAll(filepath.Dir(bgLink), 0o755)
		os.Remove(bgLink)
		if err := os.Symlink(target, bgLink); err != nil {
			return fmt.Errorf("symlink failed: %w", err)
		}

		// Set wallpaper with xwallpaper
		xwp := exec.Command("xwallpaper", "--zoom", target)
		xwp.Stdout = os.Stdout
		xwp.Stderr = os.Stderr
		if err := xwp.Run(); err != nil {
			// Fallback to feh
			feh := exec.Command("feh", "--bg-fill", target)
			feh.Stdout = os.Stdout
			feh.Stderr = os.Stderr
			if err := feh.Run(); err != nil {
				return fmt.Errorf("failed to set wallpaper: %w", err)
			}
		}

		// Optionally run pywal if available
		if _, err := exec.LookPath("wal"); err == nil {
			fmt.Println("Running pywal color extraction...")
			wal := exec.Command("wal", "-i", target)
			wal.Stdout = os.Stdout
			wal.Stderr = os.Stderr
			wal.Run() // best-effort, don't fail if pywal errors
		}

		fmt.Printf("Wallpaper set: %s\n", filepath.Base(target))
		return nil
	},
}
