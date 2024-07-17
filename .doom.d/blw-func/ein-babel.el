(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
(add-hook 'org-mode-hook 'org-display-inline-images)

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (browser . t)
     (ditaa . t)
     (R . t)
     (go . t)
     ;; (ipython . t)
     ;; (julia-vterm . t)
     ;; (julia . t)
     (ein . t)
     (ditaa . t)
     (css . t)
     (lisp . t)
     (latex . t)
     (clojure . t)
     (clojurescript . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))
