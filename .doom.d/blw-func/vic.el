;;; ../dotfiles/.doom.d/blw-func/vic.el -*- lexical-binding: t; -*-

;; emc: emacs in command
(defun blw/emacs-in-command (command)
  "Prompt for a command name, find its executable, and open its script file in Emacs."
  (interactive (list (read-string "Command name: ")))
  (let ((cmd (executable-find command)))
    (if cmd
        (find-file cmd)
      (message "Command not found: %s" command))))

(defun blw/vic (command)
  "Open a new (kitty) terminal and run `vic <command>`. Close the terminal when the editing finishes."
  (interactive (list (read-string "Command name: ")))
  (let ((terminal-command (format "kitty bash -c 'vic %s'" command)))
    (start-process-shell-command "blw/vic" nil terminal-command)))

(defun blw/vic-hold (command)
  "Open a new (kitty) terminal and run `vic <command>`. It won't close the terminal when the editing finishes."
  (interactive (list (read-string "Command name: ")))
  (let ((terminal-command (format "kitty --hold bash -c 'vic %s'" command)))
    (start-process-shell-command "blw/vic" nil terminal-command)))
