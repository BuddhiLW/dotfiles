;;; tools/codeium/autoload.el -*- lexical-binding: t; -*-

;;;###autoload
(defun add-codeium-completion()
  (interactive)
  (when (modulep! :completion corfu))
  (setq-local completion-at-point-functions
              (list (cape-super-capf #'codeium-completion-at-point #'lsp-completion-at-point)))
  (when (modulep! :completion company)
    (setq completion-at-point-functions
          (cons 'codeium-completion-at-point completion-at-point-functions)
          (setq-local company-frontends
                      '(company-pseudo-tooltip-frontend company-echo-metadata-frontend company-preview-frontend))
          (setq company-minimum-prefix-length 0)

;;;###autoload
          (defun remove-codeium-completion ()
            (interactive)
            (setq completion-at-point-functions
                  (delete 'codeium-completion-at-point completion-at-point-functions))
            (setq company-minimum-prefix-length 2)))))

;; (add-hook 'python-mode-hook
;;     (let ((buf (current-buffer)))
;;         (run-with-timer 2 nil
;;             (lambda ()
;;                 (with-current-buffer buf
;;                     (add-codeium-completion))))))
