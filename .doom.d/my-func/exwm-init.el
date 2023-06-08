  (defun blw/exwm-init ()
    (interactive)
    (load! "$HOME/.doom.d/my-func/exwm.el"))
;; (load! "$HOME/.doom.d/desktop.el"))

  (defun efs/exwm-update-class ()
    (exwm-workspace-rename-buffer exwm-class-name))
