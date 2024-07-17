(defun blw/TeX-command-toggle-shell-escape ()
  "toggles the option --shell-escape from the tex command"
  (interactive)
  (setq TeX-command-extra-options
        (cond ((string-match-p "\\_<--shell-escape\\_>" TeX-command-extra-options)
               (replace-regexp-in-string "\\_<--shell-escape\\_>" "" TeX-command-extra-options))
              ((string-empty-p TeX-command-extra-options) "--shell-escape")
              (t (format "--shell-escape %s" TeX-command-extra-options))))
  (message "TeX-command-extra-options : `%s'" TeX-command-extra-options))
