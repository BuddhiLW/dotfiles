(load-file (substitute-in-file-name "$HOME/.doom.d/my-func/splash-layout.el"))
(load-file (substitute-in-file-name "$HOME/.doom.d/my-func/splash-phrase.el"))

(defadvice! doom-dashboard-widget-loaded-with-phrase ()
  :override #'doom-dashboard-widget-loaded
  (setq line-spacing 0.2)
  (insert
   "\n\n"
   (propertize
    (+doom-dashboard--center
     +doom-dashboard--width
     (doom-display-benchmark-h 'return))
    'face 'doom-dashboard-loaded)
   "\n"
   (shell-command-to-string "fortune")
   "\n"))
