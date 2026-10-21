;;; tod.el --- Start tod, the time-of-day theme, with Emacs -*- lexical-binding: t; -*-
;;;
;;; Commentary:
;;;
;;; tod paints the `tod-sky' theme from the sun's altitude, the moon,
;;; the sun's sign and the planetary hour, and repaints it every
;;; `tod-sky-interval' seconds.  M-x tod-describe shows the sky.
;;;
;;; Code:

(use-package! tod
  :defer t
  :init
  (setq tod-latitude -3.73
        tod-longitude -38.52
        tod-sky-interval 300
        tod-looks '((:palette sky)))
  ;; Depth 90 runs after Doom has loaded `doom-theme', so tod's theme wins.
  (add-hook 'emacs-startup-hook #'tod-mode 90))

;;; tod.el ends here
