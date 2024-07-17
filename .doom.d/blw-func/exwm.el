;;; ../dotfiles/.doom.d/my-func/exwm.el -*- lexical-binding: t; -*-
(setq exwm-workspace-number 5)

;; When window "class" updates, use it to set the buffer name
(add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

;; Rebind CapsLock to Ctrl
;;(start-process-shell-command "xmodmap" nil "xmodmap ~/.emacs.d/exwm/Xmodmap")

;; Load the system tray before exwm-init
(require 'exwm-systemtray)
(exwm-systemtray-enable)

;; These keys should always pass through to Emacs
(setq exwm-input-prefix-keys
    '(?\C-x
        ?\C-u
        ?\C-h
        ?\M-x
        ?\M-`
        ?\M-&
        ?\M-:
        ?\C-\M-j  ;; Buffer list
        ?\C-\ ))  ;; Ctrl+Space

;; Ctrl+Q will enable the next key to be sent directly
(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

;; Set up global key bindings.  These always work, no matter the input state!
;; Keep in mind that changing this list after EXWM initializes has no effect.
(setq exwm-input-global-keys
      `(
        ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
        ([?\s-r] . exwm-reset)

        ;; Move between windows
        ([s-left] . windmove-left)
        ([s-right] . windmove-right)
        ([s-up] . windmove-up)
        ([s-down] . windmove-down)

        ;; Launch applications via shell command
        ([?\s-&] . (lambda (command)
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command command nil command)))

        ;; Switch workspace
        ([?\s-w] . exwm-workspace-switch)
        ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

        ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))

(exwm-enable)

(require 'exwm-randr)
(setq exwm-randr-workspace-output-plist '(0 "eDP1"))
(add-hook 'exwm-randr-screen-change-hook
      (lambda ()
        (start-process-shell-command
         "xrandr" nil "xrandr --output eDP1 --right-of HDMI-1-0 --auto")))
(start-process-shell-command "xrandr" nil "xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output DP-2 --off --output HDMI-1 --mode 2560x1080 --pos 1920x0 --rotate normal")
(setq exwm-randr-workspace-monitor-plist '(2 "eDP-1" 3 "HDMI-1"))
(exwm-randr-enable)

(defun efs/exwm-init-hook ()
  ;;   ;; Make workspace 1 be the one where we land at startup
  (exwm-workspace-switch-create 1)

  ;;   ;; Open eshell by default
  ;;   ;; (eshell)

  ;;   ;; NOTE: The next two are disabled because we now use Polybar!

  ;;   ;; Show battery status in the mode line
  (display-battery-mode 1)

  ;;   ;; Show the time and date in modeline
  (setq display-time-day-and-date t)
  (display-time-mode 1)
  ;;   ;; Also take a look at display-time-format and format-time-string

  ;;   ;; Start the Polybar panel
  ;; (efs/start-panel)

  ;;   ;; Launch apps that will run in the background
  (efs/run-in-background "dunst")
  (efs/run-in-background "nm-applet")
  (efs/run-in-background "pasystray")
  (efs/run-in-background "blueman-applet")
  (efs/start-panel))
