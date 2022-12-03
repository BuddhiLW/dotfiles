(defun lw/find-vocabulary ()
  (interactive)
  (find-file "~/PP/Notes/vocabulary.org"))

(defun lw/bing-dict-brief (word &optional sync-p)
  "Show the explanation of WORD from Bing in the echo area."
  (interactive
   (let* ((default (if (use-region-p)
                       (buffer-substring-no-properties
                        (region-beginning) (region-end))
                     (let ((text (thing-at-point 'word)))
                       (if text (substring-no-properties text)))))
          (prompt (if (stringp default)
                      (format "Search Bing dict (default \"%s\"): " default)
                    "Search Bing dict: "))
          (string (read-string prompt nil 'bing-dict-history default)))
     (list string)))

  (and bing-dict-cache-auto-save
       (not bing-dict--cache)
       (bing-dict--cache-load))

  (let ((cached-result (and (listp bing-dict--cache)
                            (car (assoc-default word bing-dict--cache)))))
    (if cached-result
        (progn
          ;; update cached-result's time
          (setcdr (assoc-default word bing-dict--cache) (time-to-seconds))
          (message cached-result))
      (save-match-data
        (if sync-p
            (with-current-buffer (url-retrieve-synchronously
                                  (concat bing-dict--base-url
                                          (url-hexify-string word))
                                  t t)
              (bing-dict-brief-cb nil (decode-coding-string word 'utf-8)))
          (url-retrieve (concat bing-dict--base-url
                                (url-hexify-string word))
                        'bing-dict-brief-cb
                        `(,(decode-coding-string word 'utf-8))
                        t
                        t)))))
  (lw/find-vocabulary))
