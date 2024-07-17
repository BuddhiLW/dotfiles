(defconst diary-dir (expand-file-name "~/PP/Notes/Diary/"))

(defun blw/diary-day-entry ()
  (concat diary-dir (shell-command-to-string "echo -n $(date +%Y-%m-%d).org")))

(defun blw/create-or-access-diary ()
  (interactive)
  (if (not (file-exists-p (blw/diary-day-entry)))
      (or (write-region
           (format "#+TITLE: %s" (shell-command-to-string "echo -n $(date +%Y-%m-%d) \n"))
           nil
           (blw/diary-day-entry))
          (find-file (blw/diary-day-entry)))
    (find-file (blw/diary-day-entry))))
