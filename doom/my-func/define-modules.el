(defmacro lw/define-loadable (fn-name mod-name)
  `(defun ,fn-name ()
    (interactive)
    (load! (concat "../modules/" ,mod-name))))
