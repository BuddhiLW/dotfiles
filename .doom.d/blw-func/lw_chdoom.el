(defun blw/chdoom (fontsize)
  (interactive
   (list (read-number "Font size: "
                      (or 30))))
  (set-fontset-font "fontset-default" 'han
                    (font-spec :family "Sarasa Mono Slab HC" :size fontsize)))

;; (set-face-attribute 'default nil :height 200)

(defun blw/defdoom (fontsize)
  (interactive
   (list (read-number "Font size: "
                      (or 200))))
  (set-face-attribute 'default nil :height  fontsize))
