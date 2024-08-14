<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Xmonad Essentials](#xmonad-essentials)
- [BLW Keys](#blw-keys)
- [Favorite Programs](#favorite-programs)
- [Screenshot](#screenshot)
- [Switch to Workspace](#switch-to-workspace)
- [Send Window to Workspace](#send-window-to-workspace)
- [Move Window to WS and Go There](#move-window-to-ws-and-go-there)
- [Window Navigation](#window-navigation)
- [Monitors](#monitors)
- [Switch Layouts](#switch-layouts)
- [Window Resizing](#window-resizing)
- [Floating Windows](#floating-windows)
- [Window Spacing (Gaps)](#window-spacing-gaps)
- [Increase/Decrease Windows in Master Pane or Stack](#increasedecrease-windows-in-master-pane-or-stack)
- [TreeSelect](#treeselect)
- [Toggle Fullscreen Mode](#toggle-fullscreen-mode)

<!-- markdown-toc end -->


## Xmonad Essentials

| Keybinding     | Description             | Command                                                              |
|----------------|-------------------------|----------------------------------------------------------------------|
| `M-/         ` | BLW's Xmonad Documented | `spawn "blw-docs"`                                                   |
| `M-C-r`        | Recompile XMonad        | `spawn "xmonad --recompile"`                                         |
| `M-S-r`        | Restart XMonad          | `spawn "xmonad --restart"`                                           |
| `M-S-q`        | Quit XMonad             | `sequence_ [spawn (mySoundPlayer ++ shutdownSound), io exitSuccess]` |
| `M-q`          | Kill focused window     | `kill1`                                                              |
| `M-S-a`        | Kill all windows on WS  | `killAll`                                                            |
| `M-S-b`        | Toggle bar show/hide    | `spawn "dbus-send --session --dest=org.Xmobar.Control ..."`          |

<!-- 
| `M-S-<Return>`  | Run prompt               | `sequence_ [spawn (mySoundPlayer ++ dmenuSound), spawn "~/.local/bin/dm-run"]` | 
-->

## BLW Keys

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-p t t`       | Random Lazywallpaper      | `spawn "random-lazywal"`                                     |
| `M-p r`         | Launch Rofi 2             | `spawn "rofi -show run"`                                     |
| `M-p t e x`     | Latex OCR                 | `spawn "pix2tex_gui"`                                        |

## Favorite Programs

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-<Return>`    | Launch terminal           | `spawn (myTerminal)`                                         |
| `M-w`           | Launch web browser        | `spawn (myBrowser)`                                          |
| `M-M1-h`        | Launch htop               | `spawn (myTerminal ++ " -e htop")`                           |
| `M-r`           | Rofi                      | `spawn "rofi -show run"`                                     |
| `M-b s`         | Slack                     | `spawn "/snap/bin/slack"`                                    |
| `M-b M-f`       | Yazi                      | `spawn (myTerminal ++ " yazi")`                              |
| `M-b c`         | Conky clock               | `spawn "rofi -show run conky-clock"`                         |
| `M-b M-b`       | Bluetooth headset switch  | `spawn "switch-bluetooth-profile"`                           |

## Screenshot

| Keybinding | Description                   | Command                      |
|------------|-------------------------------|------------------------------|
| `<print>`  | "Take screenshot" | `spawn "~/.local/bin/blw/maimpick"` |

## Switch to Workspace

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-1`           | Switch to workspace 1     | `windows $ W.greedyView $ myWorkspaces !! 0`                 |
| `M-2`           | Switch to workspace 2     | `windows $ W.greedyView $ myWorkspaces !! 1`                 |
| `M-3`           | Switch to workspace 3     | `windows $ W.greedyView $ myWorkspaces !! 2`                 |
| `M-4`           | Switch to workspace 4     | `windows $ W.greedyView $ myWorkspaces !! 3`                 |
| `M-5`           | Switch to workspace 5     | `windows $ W.greedyView $ myWorkspaces !! 4`                 |
| `M-6`           | Switch to workspace 6     | `windows $ W.greedyView $ myWorkspaces !! 5`                 |
| `M-7`           | Switch to workspace 7     | `windows $ W.greedyView $ myWorkspaces !! 6`                 |
| `M-8`           | Switch to workspace 8     | `windows $ W.greedyView $ myWorkspaces !! 7`                 |
| `M-9`           | Switch to workspace 9     | `windows $ W.greedyView $ myWorkspaces !! 8`                 |

## Send Window to Workspace

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-S-1`         | Send to workspace 1       | `windows $ W.shift $ myWorkspaces !! 0`                      |
| `M-S-2`         | Send to workspace 2       | `windows $ W.shift $ myWorkspaces !! 1`                      |
| `M-S-3`         | Send to workspace 3       | `windows $ W.shift $ myWorkspaces !! 2`                      |
| `M-S-4`         | Send to workspace 4       | `windows $ W.shift $ myWorkspaces !! 3`                      |
| `M-S-5`         | Send to workspace 5       | `windows $ W.shift $ myWorkspaces !! 4`                      |
| `M-S-6`         | Send to workspace 6       | `windows $ W.shift $ myWorkspaces !! 5`                      |
| `M-S-7`         | Send to workspace 7       | `windows $ W.shift $ myWorkspaces !! 6`                      |
| `M-S-8`         | Send to workspace 8       | `windows $ W.shift $ myWorkspaces !! 7`                      |
| `M-S-9`         | Send to workspace 9       | `windows $ W.shift $ myWorkspaces !! 8`                      |

## Move Window to WS and Go There

| Keybinding      | Description                  | Command                                                      |
|-----------------|------------------------------|--------------------------------------------------------------|
| `M-S-<Page_Up>` | Move window to next WS       | `shiftTo Next nonNSP >> moveTo Next nonNSP`                  |
| `M-S-<Page_Down>`| Move window to prev WS      | `shiftTo Prev nonNSP >> moveTo Prev nonNSP`                  |

## Window Navigation

| Keybinding      | Description                             | Command                                                      |
|-----------------|-----------------------------------------|--------------------------------------------------------------|
| `M-j`           | Move focus to next window               | `windows W.focusDown`                                        |
| `M-k`           | Move focus to prev window               | `windows W.focusUp`                                          |
| `M-m`           | Move focus to master window             | `windows W.focusMaster`                                      |
| `M-S-j`         | Swap focused window with next window    | `windows W.swapDown`                                         |
| `M-S-k`         | Swap focused window with prev window    | `windows W.swapUp`                                           |
| `M-S-m`         | Swap focused window with master window  | `windows W.swapMaster`                                       |
| `M-<Backspace>` | Move focused window to master           | `promote`                                                    |
| `M-S-,`         | Rotate all windows except master        | `rotSlavesDown`                                              |
| `M-S-.`         | Rotate all windows in current stack     | `rotAllDown`                                                 |

## Monitors

| Keybinding      | Description                   | Command                                                      |
|-----------------|--------------------------------|--------------------------------------------------------------|
| `M-.`           | Switch focus to next monitor   | `nextScreen`                                                 |
| `M-,`           | Switch focus to prev monitor   | `prevScreen`                                                 |

## Switch Layouts

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-<Tab>`       | Switch to next layout    | `sendMessage NextLayout`                                     |
| `M-<Space>`     | Toggle noborders/full    | `sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts` |

## Window Resizing

| Keybinding      | Description                   | Command                                                      |
|-----------------|--------------------------------|--------------------------------------------------------------|
| `M-h`           | Shrink window                 | `sendMessage Shrink`                                         |
| `M-l`           | Expand window                 | `sendMessage Expand`                                         |
| `M-M1-j`        | Shrink window vertically      | `sendMessage MirrorShrink`                                   |
| `M-M1-k`        | Expand window vertically      | `sendMessage MirrorExpand`                                   |

## Floating Windows

| Keybinding      | Description                      | Command                                                      |
|-----------------|----------------------------------|--------------------------------------------------------------|
| `M-f`           | Toggle float layout              | `sendMessage (T.Toggle "floats")`                            |
| `M-t`           | Sink a floating window           | `withFocused $ windows . W.sink`                             |
| `M-S-t`         | Sink all floated windows         | `sinkAll`                                                    |

## Window Spacing (Gaps)

| Keybinding | Description             | Command              |
|------------|-------------------------|----------------------|
| `C-M1-j`   | Decrease window spacing | `decWindowSpacing 4` |
| `C-M1-k`   | Increase window spacing | `incWindowSpacing 4` |
| `C-M1-h`   | Decrease screen spacing | `decScreenSpacing 4` |
| `C-M1-l`   | Increase screen spacing | `incScreenSpacing 4` |

## Increase/Decrease Windows in Master Pane or Stack

| Keybinding | Description                     | Command                         |
|------------|---------------------------------|---------------------------------|
| `M-S-h`    | Increase windows in master pane | `sendMessage (IncMasterN 1)`    |
| `M-S-l`    | Decrease windows in master pane | `sendMessage (IncMasterN (-1))` |
| `M-C-m`    | Increase windows in stack pane  | `increaseLimit`                 |
| `M-C-n`    | Decrease windows in stack pane  | `decreaseLimit`                 |

## TreeSelect

| Keybinding      | Description                   | Command                                                      |
|-----------------|--------------------------------|--------------------------------------------------------------|
| `M-s`           | Bring up TreeSelect           | `TS.treeselectAction tsDefaultConfig`                        |

## Toggle Fullscreen Mode

| Keybinding      | Description                | Command                                                      |
|-----------------|----------------------------|--------------------------------------------------------------|
| `M-S-f`         | Toggle full screen         | `sendMessage $ MT.Toggle NBFULL`                             |

