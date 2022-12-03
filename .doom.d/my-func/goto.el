(defun lw/goto-emacs-org ()
  "Open =Emacs.org= file which maps to init.el."
  (interactive)
  (find-file (expand-file-name "Emacs.org" doom-private-dir)))

(defun lw/goto-my-func-org ()
  "Open =my-func.org= file which maps to homecooked function."
  (interactive)
  (find-file (expand-file-name "my-func/my-func.org" doom-private-dir)))

(defun lw/find-evildeeds ()
  (interactive)
  (find-file (getenv "EVILDEEDS")))

(defun lw/goto-cs-books ()
  (interactive)
  (find-file (getenv "CS_B")))

(defun lw/goto-cs-active ()
  (interactive)
  (find-file (concat (getenv "CS_B") "/Active")))

(defun lw/goto-book-notes ()
  (interactive)
  (find-file (getenv "BNOTES")))
