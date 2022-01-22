(defun lw/goto-emacs-org ()
  "Open =Emacs.org= file which maps to init.el."
  (interactive)
  (find-file (expand-file-name "Emacs.org" doom-private-dir)))
  ;; (goto-char
  ;;  (or (save-excursion
  ;;        (goto-char (point-min))
  ;;        (search-forward "(doom!" nil t))
  ;;      (point))))

(defun lw/goto-my-func-org ()
  "Open =my-func.org= file which maps to homecooked function."
  (interactive)
  (find-file (expand-file-name "my-func/my-func.org" doom-private-dir)))
