;;; Yazi (file-manager) integration ../dotfiles/.doom.d/blw-func/yazi.el -*- lexical-binding: t; -*-

(defun blw/run-yazi ()
  "Open a terminal and execute `yazi` with the current directory."
  (interactive)
  (let ((current-dir (expand-file-name default-directory)))
    (start-process "terminal" nil "kitty" "--" "bash" "-c"
                   (concat "yazi " (shell-quote-argument current-dir)))))
