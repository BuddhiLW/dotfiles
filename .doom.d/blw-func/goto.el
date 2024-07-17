(defun blw/goto-emacs-org ()
  "Open =Emacs.org= file which maps to init.el."
  (interactive)
  (find-file (expand-file-name "Emacs.org" doom-private-dir)))

(defun blw/goto-my-func-org ()
  "Open =my-func.org= file which maps to homecooked function."
  (interactive)
  (find-file (expand-file-name "my-func/my-func.org" doom-private-dir)))

(defun blw/find-evildeeds ()
  (interactive)
  (find-file (getenv "EVILDEEDS")))

(defun blw/goto-cs-books ()
  (interactive)
  (find-file (getenv "CS_B")))

(defun blw/goto-cs-active ()
  (interactive)
  (find-file (concat (getenv "CS_B") "/Active")))

(defun blw/goto-book-notes ()
  (interactive)
  (find-file (getenv "BNOTES")))
