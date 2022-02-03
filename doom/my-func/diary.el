(defconst diary-dir (expand-file-name "~/PP/Notes/Diary/"))

(defun lw/diary-day-entry ()
  (concat diary-dir (shell-command-to-string "echo -n $(date +%Y-%m-%d).org")))

(defun lw/create-or-access-diary ()
  (interactive)
  (if (not (file-exists-p (lw/diary-day-entry)))
      (or (write-region
           (format "#+TITLE: %s" (shell-command-to-string "echo -n $(date +%Y-%m-%d) \n"))
           nil
           (lw/diary-day-entry))
        (find-file (lw/diary-day-entry)))
    (find-file (lw/diary-day-entry))))

;; (defun fzl-create-empty-file-if-no-exist2022-01-16.orgs(filePath)
;;    "Create a file with FILEPATH parameter."
;;    (if (file-exists-p filePath)
;;        (message (concat  "File " (concat filePath " already exists")))
;;      (with-temp-buffer (write-file Pathfile))))
