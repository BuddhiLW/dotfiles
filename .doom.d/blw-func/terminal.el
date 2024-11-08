;;; ../dotfiles/.doom.d/blw-func/terminal.el -*- lexical-binding: t; -*-

(defun blw/run-kitty ()
  "Open a new terminal in the current directory and bring focus to it."
  (interactive)
  (let ((current-dir (expand-file-name default-directory)))
    (start-process "terminal" nil "kitty" "--" "bash" "-c"
                   (concat "cd " (shell-quote-argument current-dir) " && exec bash"))
    (select-window (get-buffer-window "*terminal*"))))
