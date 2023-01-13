;; dir-local.el for facti's js setup
((rjsx-mode . ((eval . (setq js-indent-level 2))
               (eval . (setq indent-tabs-mode nil))
               (eval . (setq tab-width 4))
               (eval . (setq indent-line-function 'insert-tab)))))
