;;; ../dotfiles/.doom.d/my-func/ewal.el --- Ewal smart-hooks integration -*- lexical-binding: t; -*-
;;;
;;; Commentary:
;;;
;;; This file contains functions to manage ewal-related themes and processes.
;;; It includes functionality to start `ewal-watch` if it is not already running,
;;; and to reload ewal doom themes. Additionally, a hook is provided to ensure these
;;; functions are executed when any ewal doom theme is applied.
;;;
;;; Code:

(defun blw/start-ewal-watch-if-needed ()
  "Check if `ewal-watch` or `inotifywait` processes are running.
If not, start `ewal-watch`."
  (interactive)
  (let* ((ewal-watch-process (shell-command-to-string "pgrep -f ewal-watch"))
         (inotifywait-process (shell-command-to-string "pgrep -f inotifywait")))
    (unless (or (not (string-empty-p ewal-watch-process))
                (not (string-empty-p inotifywait-process)))
      (call-process "nohup" nil 0 nil "ewal-watch" "&")
      (message "Started ewal-watch process."))))

;; Important, because it will be called in `ewal-watch' script.
(defun blw/reload-ewal-doom-one-theme ()
  "Reload the ewal-doom-one and ewal-doom-vibrant themes."
  (interactive)
  (load-theme 'ewal-doom-one t)
  (load-theme 'ewal-doom-vibrant t))

(add-hook 'doom-load-theme-hook 'blw/start-ewal-watch-if-needed)

(provide 'ewal)
;;; ewal.el ends here
