;;; tools/codeium/config.el -*- lexical-binding: t; -*-

(use-package! codeium
  :bind ("C-c f" . +codeium-complete);; comfy a/q to my keyb layout
  :init
  ;; (add-hook 'prog-mode-hook
  ;;           (lambda ()
  ;;             (add-hook 'completion-at-point-functions
  ;;                       #'codeium-completion-at-point
  ;;                       -40 t)))
  (when (modulep! :completion corfu)
    (when (featurep! +python)

      (add-hook 'python-mode-hook
                (lambda ()
                  (setq-local completion-at-point-functions
                              (cons #'codeium-completion-at-point completion-at-point-functions)))))

    (when (featurep! +cmode)
      (defalias 'codeium-cmode-completion
        (cape-super-capf #'lsp-completion-at-point #'codeium-completion-at-point #'tags-completion-at-point-function #'cape-file))
      (setq-local completion-at-point-functions (list #'codeium-cmode-completion))
      (add-hook 'c-mode-hook
                (lambda ()
                  (setq-local completion-at-point-functions (list #'(codeium-python-completion)))))))

  ;; (add-hook 'emacs-startup-hook
  ;;           (lambda () (run-with-timer 0.1 nil #'codeium-init)))

  :defer t
  :config
  (defalias '+codeium-complete
    (cape-capf-interactive #'codeium-completion-at-point))
  (define-key evil-insert-state-map (kbd "C-f") #'+codeium-complete)
  ;; (define-key 'normal python-mode-map (kbd "C-f") #'my/codeium-complete)
  ;; (setq codeium/metadata/api_key
  ;;       (auth-source-pass-get 'secret "api/codeium"))
  (setq use-dialog-box nil) ;; do not use popup boxes

  ;; if you don't want to use customize to save the api-key
  ;; (setq codeium/metadata/api_key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

  ;; get codeium status in the modeline
  ;; (setq codeium-mode-line-enable
  ;;       (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
  ;; (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
  ;; alternatively for a more extensive mode-line
  (add-to-list 'mode-line-format '(-50 "" codeium-mode-line) t)

  ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
  (setq codeium-api-enabled
        (lambda (api)
          (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))

  ;; limiting the string sent to codeium for better performance
  (defun +codeium/document/text ()
    (buffer-substring-no-properties
     (max (- (point) 3000) (point-min))
     (min (+ (point) 1000) (point-max))))
  ;; if you change the text, you should also change the cursor_offset
  ;; warning: this is measured by UTF-8 encoded bytes
  (defun +codeium/document/cursor_offset ()
    (codeium-utf8-byte-length
     (buffer-substring-no-properties
      (max (- (point) 3000) (point-min)) (point))))
  (setq codeium/document/text '+codeium/document/text)
  (setq codeium/document/cursor_offset
        '+codeium/document/cursor_offset))

(when (modulep! :completion company)
  (after! company
    :config
    (setq-default
     ;; company-idle-delay 0.05
     company-require-match nil))

  (map! :leader
        (:prefix ("c " . "")
         :desc "Add/Remove Codeium Completion " "m" #'add-codeium-completion)))

(provide 'setup-codeium)
