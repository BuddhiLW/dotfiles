(setq doom-font
      (set-fontset-font "fontset-default" 'han
                        (font-spec :family "Sarasa Mono Slab HC")))

(package! zh-align
  :recipe (:host github
           :repo "chen-chao/zh-align.el"))

(use-package! pyim-basedict)

(use-package! pyim
  :config
  (require 'pyim-basedict) ; 拼音词库设置，五笔用户 *不需要* 此行设置
  (pyim-basedict-enable)   ; 拼音词库，五笔用户 *不需要* 此行设置
  (setq default-input-method "pyim")
  (setq pyim-page-length 10)
  (pyim-isearch-mode 1))

(use-package! bing-dict
  :config
  (map! :leader
        (:prefix-map ("b" . "buddhi")
         (:prefix ("b" . "bing")
          :desc "Bing dictionary brief" "d" #'lw/bing-dict-brief
          :desc "Personal vocabulary" "p" #'lw/find-vocabulary)))
  ;; :desc "Activate synonym" "s" #'lw/bing-synonym))))

  (setq bing-dict-add-to-kill-ring t)
  (setq bing-dict-show-thesaurus 'both)
  (setq bing-dict-vocabulary-save t)
  (setq bing-dict-vocabulary-file "~/PP/Notes/vocabulary.org"))
