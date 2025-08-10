## Xmonad Essentials

| Keybinding     | Description             | Command                                                              |
|----------------|-------------------------|----------------------------------------------------------------------|
| `M-d         ` | BLW's Xmonad Documented | `spawn "blw-docs"`                                                   |
| `M-C-r`        | Recompile XMonad        | `spawn "xmonad --recompile"`                                         |
| `M-S-r`        | Restart XMonad          | `spawn "xmonad --restart"`                                           |
| `M-S-q`        | Quit XMonad             | `sequence_ [spawn (mySoundPlayer ++ shutdownSound), io exitSuccess]` |
| `M-q`          | Kill focused window     | `kill1`                                                              |
| `M-S-a`        | Kill all windows on WS  | `killAll`                                                            |
| `M-S-b`        | Toggle bar show/hide    | `spawn "dbus-send --session --dest=org.Xmobar.Control ..."`          |
| `M-S-<Return>` | Run prompt              | `sequence_ [spawn (mySoundPlayer ++ dmenuSound), spawn "~/.local/bin/dm-run"]` |
| `M-<F1>`       | Show keybindings (YAD)  | `showKeybindings`                                                    |

<!-- 
| `M-S-<Return>`  | Run prompt               | `sequence_ [spawn (mySoundPlayer ++ dmenuSound), spawn "~/.local/bin/dm-run"]` | 
-->

## BLW Keys

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-p t t`       | Random Lazywallpaper      | `spawn "random-lazywal"`                                     |
| `M-p r`         | Launch Rofi 2             | `spawn "rofi -show run"`                                     |
| `M-p M-p`       | Take a screenshot (notify)| `spawn "notify-send 'hello!'"`                               |
| `M-p t e x`     | Latex OCR                 | `spawn "pix2tex_gui"`                                        |

## Favorite Programs

| Keybinding      | Description              | Command                                                      |
|-----------------|--------------------------|--------------------------------------------------------------|
| `M-<Return>`    | Launch terminal           | `spawn (myTerminal)`                                         |
| `M5-<Return>`   | Launch Alacritty          | `spawn "alacritty"`                                         |
| `M-v`           | Launch Document Viewer    | `spawn (myDocumentViewer)`                                   |
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

| Keybinding      | Description                                 | Command                         |
|-----------------|---------------------------------------------|---------------------------------|
| `M-S-<Up>`      | Increase clients in master pane             | `sendMessage (IncMasterN 1)`    |
| `M-S-<Down>`    | Decrease clients in master pane             | `sendMessage (IncMasterN (-1))` |
| `M-=`           | Increase max number of windows for layout   | `increaseLimit`                 |
| `M--`           | Decrease max number of windows for layout   | `decreaseLimit`                 |

## Sublayouts

| Keybinding | Description                       | Command                               |
|------------|-----------------------------------|---------------------------------------|
| `M-C-h`    | Pull window/group left            | `sendMessage $ pullGroup L`           |
| `M-C-l`    | Pull window/group right           | `sendMessage $ pullGroup R`           |
| `M-C-k`    | Pull window/group up              | `sendMessage $ pullGroup U`           |
| `M-C-j`    | Pull window/group down            | `sendMessage $ pullGroup D`           |
| `M-C-m`    | Merge all into sublayout tabs     | `withFocused (sendMessage . MergeAll)` |
| `M-C-/`    | Unmerge all from sublayout tabs   | `withFocused (sendMessage . UnMergeAll)` |
| `M-C-.`    | Focus next tab in sublayout       | `onGroup W.focusUp'`                  |
| `M-C-,`    | Focus previous tab in sublayout   | `onGroup W.focusDown'`                |

## Scratchpads

| Keybinding | Description                  | Command                                               |
|------------|------------------------------|-------------------------------------------------------|
| `M-s t`    | Toggle scratchpad terminal   | `namedScratchpadAction myScratchPads "terminal"`     |
| `M-s m`    | Toggle scratchpad mocp       | `namedScratchpadAction myScratchPads "mocp"`         |
| `M-s c`    | Toggle scratchpad calculator | `namedScratchpadAction myScratchPads "calculator"`   |

## Mocp music player

| Keybinding      | Description         | Command                |
|-----------------|---------------------|------------------------|
| `M-u p`         | Play                | `spawn "mocp --play"` |
| `M-u l`         | Next                | `spawn "mocp --next"` |
| `M-u h`         | Previous            | `spawn "mocp --previous"` |
| `M-u <Space>`   | Toggle pause        | `spawn "mocp --toggle-pause"` |

## GridSelect

| Keybinding          | Description                    | Command |
|---------------------|--------------------------------|---------|
| `M-M1-<Return>`     | Select favorite apps (grid)    | `spawnSelected' (gsGames ++ gsEducation ++ gsInternet ++ gsMultimedia ++ gsOffice ++ gsSettings ++ gsSystem ++ gsUtilities)` |
| `M-M1-c`            | Select category menu           | `spawnSelected' gsCategories` |
| `M-M1-t`            | Go to selected window          | `goToSelected $ mygridConfig myColorizer` |
| `M-M1-b`            | Bring selected window          | `bringSelected $ mygridConfig myColorizer` |
| `M-M1-1`            | Menu of games                  | `spawnSelected' gsGames` |
| `M-M1-2`            | Menu of education apps         | `spawnSelected' gsEducation` |
| `M-M1-3`            | Menu of Internet apps          | `spawnSelected' gsInternet` |
| `M-M1-4`            | Menu of multimedia apps        | `spawnSelected' gsMultimedia` |
| `M-M1-5`            | Menu of office apps            | `spawnSelected' gsOffice` |
| `M-M1-6`            | Menu of settings apps          | `spawnSelected' gsSettings` |
| `M-M1-7`            | Menu of system apps            | `spawnSelected' gsSystem` |
| `M-M1-8`            | Menu of utilities apps         | `spawnSelected' gsUtilities` |

## Multimedia keys

| Keybinding                | Description            | Command                                      |
|---------------------------|------------------------|----------------------------------------------|
| `<XF86AudioPlay>`         | mocp play              | `spawn "mocp --play"`                        |
| `<XF86AudioPrev>`         | mocp previous          | `spawn "mocp --previous"`                    |
| `<XF86AudioNext>`         | mocp next              | `spawn "mocp --next"`                        |
| `<XF86AudioMute>`         | Toggle audio mute      | `spawn "amixer set Master toggle"`          |
| `<XF86AudioLowerVolume>`  | Lower volume           | `spawn "amixer set Master 5%- unmute"`      |
| `<XF86AudioRaiseVolume>`  | Raise volume           | `spawn "amixer set Master 5%+ unmute"`      |
| `<XF86HomePage>`          | Open home page         | `spawn (myBrowser ++ " https://www.youtube.com/c/DistroTube")` |
| `<XF86Search>`            | Web search             | `spawn "dm-websearch"`                       |
| `<XF86Mail>`              | Email client           | `runOrRaise "thunderbird" (resource =? "thunderbird")` |
| `<XF86Calculator>`        | Calculator             | `runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk")` |
| `<XF86Eject>`             | Eject /dev/cdrom       | `spawn "eject /dev/cdrom"`                   |

## Emacs

| Keybinding | Description                 | Command |
|------------|-----------------------------|---------|
| `M-e e`    | Emacsclient                 | `spawn (myEmacs)` |
| `M-e n`    | Emacsclient Dashboard       | `spawn "emacsclient -a emacs -c"` |
| `M-e b`    | Emacsclient Ibuffer         | `spawn (myEmacs ++ ("--eval '(ibuffer)'"))` |
| `M-e d`    | Emacsclient Dired           | `spawn (myEmacs ++ ("--eval '(dired nil)'"))` |
| `M-e i`    | Emacsclient ERC (IRC)       | `spawn (myEmacs ++ ("--eval '(erc)'"))` |
| `M-e s`    | Emacsclient Eshell          | `spawn (myEmacs ++ ("--eval '(eshell)'"))` |
| `M-e v`    | Emacsclient Vterm           | `spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))` |
| `M-e w`    | Emacsclient EWW Browser     | `spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distro.tube\"))'"))` |

