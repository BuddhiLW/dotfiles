(defmacro lw/define-loadable (fn-name mod-name)
  `(defun ,fn-name ()
    (interactive)
    (load! (concat (expand-file-name "~/.doom.d/mod/") ,mod-name))))

;; (expand-file-name "../")
