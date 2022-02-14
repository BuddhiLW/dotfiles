
# Table of Contents

1.  [Loadable modules](#org38414f5)
    1.  [Chinese setup](#org207a7df)
    2.  [LaTeX setup](#org1389f46)
2.  [Modules code](#org913ce55)
    1.  [Chinese font](#org6659681)
        1.  [Tables alignment](#orgd6a0ba8)
    2.  [Chinese setup with guesses](#org9303ffb)
        1.  [Input](#org53772e1)
        2.  [Bing](#org82970a4)
    3.  [LaTeX](#orge52083f)
        1.  [Minted](#orgd4767ea)



<a id="org38414f5"></a>

# Loadable modules

    (defmacro lw/define-loadable (fn-name mod-name)
      `(defun ,fn-name ()
        (interactive)
        (load! (concat "../modules/" ,mod-name))))


<a id="org207a7df"></a>

## Chinese setup

    (lw/define-loadable lw/load-chinese "chinese.el")


<a id="org1389f46"></a>

## LaTeX setup

    (lw/define-loadable lw/load-latex "latex.el")


<a id="org913ce55"></a>

# Modules code


<a id="org6659681"></a>

## Chinese font

    (setq doom-font
          (set-fontset-font "fontset-default" 'han
                            (font-spec :family "Sarasa Mono Slab HC")))

    (load! "./my-func/lw_chdoom.el")


<a id="orgd6a0ba8"></a>

### Tables alignment

Discussion on: <https://emacs-china.org/t/org-mode/440/89>

    (package! zh-align
      :recipe (:host github
               :repo "chen-chao/zh-align.el"))


<a id="org9303ffb"></a>

## Chinese setup with guesses


<a id="org53772e1"></a>

### Input

    (use-package! pyim-basedict)
    
    (use-package! pyim
      :config
      (require 'pyim-basedict) ; 拼音词库设置，五笔用户 *不需要* 此行设置
      (pyim-basedict-enable)   ; 拼音词库，五笔用户 *不需要* 此行设置
      (setq default-input-method "pyim")
      (setq pyim-page-length 10)
      (pyim-isearch-mode 1))


<a id="org82970a4"></a>

### Bing

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


<a id="orge52083f"></a>

## LaTeX


<a id="orgd4767ea"></a>

### Minted

This change the default exportation options to `LaTeX`.

-   `linenos` means each line in the code representations is numbered.

    (setq org-latex-listings 'minted)
    
    (setq org-latex-custom-lang-environments
          '((emacs-lisp "common-lispcode")))
    
    (setq org-latex-minted-options
          '(("fontsize" "\\scriptsize")
            ("linenos" "false")
            ("bgcolor" "LightGray")
            ("frame" "lines")))

    (map! :leader
          (:prefix-map ("b" . "buddhi")
           (:prefix ("l" . "latex")
            :desc "Shell scape" "s" #'lw/TeX-command-toggle-shell-escape)))

