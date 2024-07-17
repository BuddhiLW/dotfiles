;;; my-func/isosec.el -*- lexical-binding: t; -*-
;; ====================
;; insert date and time

(defvar current-isosec "%y%m%d%H%M%S%Z"
  "Format of date to insert with `current-isosec' func,
rxwrob isosec format with timezone reference at the end [%Z]")

;; ==========
;; sex nov 04 15:32:39 -03 2022
(defvar current-date-time-format "%a %b %d %H:%M:%S %Z %Y"
  "Format of date to insert with `insert-current-date-time' func
See help of `format-time-string' for possible replacements")

(defvar current-time-format "%a %H:%M:%S"
  "Format of date to insert with `insert-current-time' func.
Note the weekly scope of the command's precision.")

(defun blw/insert-current-isosec ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert (format-time-string current-isosec (current-time))))

(defun blw/insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert "==========\n")
                                        ;       (insert (let () (comment-start)))
  (insert (format-time-string current-date-time-format (current-time)))
  (insert "\n"))


(defun blw/insert-current-time ()
  "insert the current time (1-week scope) into the current buffer."
  (interactive)
  (insert (format-time-string current-time-format (current-time)))
  (insert "\n"))
