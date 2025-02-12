;; (use-package! go-translate
;;   :config
(setq gt-langs '(en zh))
                 ;; ("en" "ru")
                 ;; ("en" "pt-br")
                 ;; ("pt-br" "en")))

(setq gt-default-translator
        (gt-translator
         :taker   (gt-taker :text 'buffer :pick 'paragraph)
         :engines  (list
                   (gt-bing-engine)
                   (gt-google-engine)
                   (gt-google-rpc-engine))
         :render
         (gt-buffer-render)))

;; (setq gt-langs '(en fr))        ; Default translation languages, at least two ​​must be specified
(setq gt-taker-text 'word)      ; By default, the initial text is the word under the cursor. If there is active region, the selected text will be used first
(setq gt-taker-pick 'paragraph) ; By default, the initial text will be split by paragraphs. If you don't want to use multi-parts translation, set it to nil
(setq gt-taker-prompt nil)
;; (setq gt-default-translator (gt-translator :engines (gt-google-engine)))

(setq gt-buffer-evil-leading-key "x")
       ;; (gt-posframe-pop-render))
