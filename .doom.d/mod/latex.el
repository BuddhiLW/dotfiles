(setq org-latex-listings 'minted)

(setq org-latex-custom-lang-environments
      '((emacs-lisp "common-lispcode")))

(setq org-latex-minted-options
      '(("fontsize" "\\scriptsize")
        ("linenos" "false")
        ("bgcolor" "LightGray")
        ("frame" "lines")))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("l" . "latex")
                    :desc "Shell scape" "s" #'blw/TeX-command-toggle-shell-escape)))
