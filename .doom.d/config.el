;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Pedro Branquinho")
(setq user-mail-address "pedrogbranquinho@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-font (font-spec :family "Oxygen Mono" :size 20)
;;       doom-variable-pitch-font (font-spec :family "Fantasque Sans Mono") ; inherits `doom-font''s :size
;;       doom-unicode-font (font-spec :family "JoyPixels" :size 25)
;;       doom-big-font (font-spec :family "Nimbus Mono PS" :size 15))
(setq doom-theme 'doom-monokai-pro) ;;-> edit "(use-pacakge doom-themes)" instead.
(setq doom-font (font-spec :family "Noto Mono" :size 20 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Fantasque Sans Mono" :weight 'regular) ; inherits `doom-font''s :size
      doom-unicode-font (font-spec :family "JoyPixels" :size 20)
      doom-big-font (font-spec :family "FreeMono" :size 20))

(set-fontset-font t 'arabic (font-spec :family "Noto Sans Arabic"))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Default face size
(set-face-attribute 'default nil :height 90)
;; Tecosaur snippet -- start --

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…"                ; Unicode ellispis are nicer than "...", and also save /precious/ space
      password-cache-expiry nil                   ; I can trust my computers ... can't I?
      ;; scroll-preserve-screen-position 'always     ; Don't have `point' jump around
      scroll-margin 2)                            ; It's nice to maintain a little margin

;; Prevent $HOME from being treated as a project root
(after! projectile
  (add-to-list 'projectile-ignored-projects "~/")
  (add-to-list 'projectile-ignored-projects "/home/lages/"))

(display-time-mode 0)                             ; Enable time in the mode-line
(display-battery-mode 0)                          ; it's nice to know how much power you have
(global-subword-mode 1)                           ; Iterate through CamelCase words

(map! :map evil-window-map
      "SPC" #'rotate-layout
      ;; Navigation
      "<left>"     #'evil-window-left
      "<down>"     #'evil-window-down
      "<up>"       #'evil-window-up
      "<right>"    #'evil-window-right
      ;; Swapping windows
      "C-<left>"       #'+evil/window-move-left
      "C-<down>"       #'+evil/window-move-down
      "C-<up>"         #'+evil/window-move-up
      "C-<right>"      #'+evil/window-move-right)

;; (load! "./blw-func/dashboard.el")

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))

(load! "./blw-func/transparency.el")

(setq org-directory "~/PP/self-managment/")
;; (setq org-directory )
(setq org-agenda-files '("~/PP/self-managment/Agenda/*"
                         "~/PP/self-managment/README.org"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "DOING(g)" "|" "DONE(d)" "CANCELED(c)")))

;; (use-package! org
;;   :config
;;   (setq org-ellipsis " ▾")
;;   (setq org-agenda-start-with-log-mode t)
;;   (setq org-log-done 'time)
;;   (setq org-log-into-drawer t)
;;   (setq org-agenda-files   '()))
;; '(
;;   ;; "~/PP/Notes/Agenda/Tasks.org"
;;   "~/PP/Notes/Agenda/Habits.org"
;;   "~/PP/Notes/Agenda/IMPA.org"
;;   "~/PP/Notes/Agenda/ProcSel.org"
;;   "~/PP/Notes/Agenda/University.org"
;;   "~/PP/Notes/Agenda/Research.org"
;;   "~/PP/Notes/Agenda/CafeDoBem.org"
;;   "~/PP/Notes/Agenda/Facti.org")))

;; (use-package! org-tanglesync
;;   :hook ((org-mode . org-tanglesync-mode)
;;          ;; enable watch-mode globally:
;;          ((prog-mode text-mode) . org-tanglesync-watch-mode))
;;   :custom
;;   ;; (org-tanglesync-watch-files '("conf.org" "myotherconf.org"))
;;   (org-tanglesync-watch-files '((substitute-in-file-name "$HOME/PP/Orasis/API-server-template/README.org")))
;;   :bind
;;   (( "C-c M-i" . org-tanglesync-process-buffer-interactive)
;;    ( "C-c M-a" . org-tanglesync-process-buffer-automatic)))

()

(setq warning-minimum-level :emergency)

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("f" . "font")
                    :desc "New default size" "d" #'blw/defdoom
                    :desc "New ch-default size" "c" #'blw/chdoom)))

(map! :leader
      :desc "Yank history" "y" #'consult-yank-from-kill-ring)

(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(add-to-list 'image-types 'svg)

(setq elfeed-feeds
      '("https://www.democracynow.org/democracynow.rss"
        "http://docuwiki.net/index.php?title=Special:Newpages&feed=rss"
        "https://www.inovacaotecnologica.com.br/boletim/rss.php"
        "http://feeds.nbcnews.com/feeds/topstories"))

;; '("http://nullprogram.com/feed/")
;; "https://planet.emacslife.com/atom.xml"
;; "https://arxiv.org/search/?query=physics+informed+neural+network&searchtype=all&source=header"

;; (use-package! helm-bibtex)

;; (use-package! gscholar-bibtex)

;; (use-package! bibtex-completion)

;; (use-package! org-ref
;;   :config
;;   (require 'org-ref-helm)
;;   (require 'org-ref-arxiv)
;;   (require 'org-ref-scopus)
;;   (require 'org-ref-wos)
;;   (map! :leader
;;         (:prefix-map ("b" . "buddhi")
;;          (:prefix ("l" . "latex")
;;           (:prefix ("i" . "insert")
;;            :desc "Bib-citation" "c" #'org-ref-insert-link
;;            :desc "Auto-ref" "r" #'org-ref-insert-ref-link
;;            :desc "Arxiv Search" "s" #'arxiv-search
;;            :desc "Arxiv Download" "d" #'arxiv-download-pdf-export-bibtex
;;            :desc "GScholar Search" "g" #'gscholar-bibtex))))
;;   (setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f")))

;; (use-package! arxiv-mode
;;   :config
;;   (setq arxiv-default-download-folder
;;         (substitute-in-file-name "$HOME/Documents/Reseach/"))
;;   (setq arxiv-default-bibliography
;;         (substitute-in-file-name "$HOME/Bibliography/collection.bib")))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Revert buffer" "r" #'revert-buffer))

;; (use-package! celestial-mode-line
;;   :config
;;   (setq calendar-longitude "20.54S")
;;   (setq calendar-latitude "47.40W")
;;   (setq calendar-location-name "Franca, SP")
;;   (defvar celestial-mode-line-phase-representation-alist '((0 . "○") (1 . "☽") (2 . "●") (3 . "☾")))
;;   (defvar celestial-mode-line-sunrise-sunset-alist '((sunrise . "☀↑ ") (sunset . "☀↓ ")))
;;   (defvar celestial-mode-line-phase-representation-alist '((0 . "( )") (1 . "|)") (2 . "(o)") (3 . "|)")))
;;   (defvar celestial-mode-line-sunrise-sunset-alist '((sunrise . "*^") (sunset . "*v")))
;;   (celestial-mode-line-start-timer))

(defun blw/sunset ()
  (interactive)
  (display-message-or-buffer (message "`%s'" (solar-sunrise-sunset-string (calendar-current-date)))))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Sunrise sunset info" "µ" #'blw/sunset))

(use-package! deft
  :bind ("<f2>" . deft)
  :commands (deft)
  :config (setq deft-directory "~/buddhi-roam/"
                deft-extensions '("md" "org"))
  :after org
  :bind
  ("C-c n d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org"))
;; (deft-directory org-roam-directory))

(use-package! pdf-tools)

;; (setq codeium/metadata/api_key (nth 0 (process-lines "pass" "show" "apikeys/codeium")))
(use-package! codeium
  :after cape
  :init
  ;; use globally
  (add-to-list 'completion-at-point-functions #'codeium-completion-at-point)

  :config

  ;; (setq codeium/metadata/api_key (nth 0 (process-lines "pass" "show" "apikeys/codeium")))
  ;; (defalias 'my/codeium-complete
  ;;   (cape-interacive-capf #'codeium-completion-at-point))

  ;; (map! :localleader
  ;;       :map evil-normal-state-map
  ;;       "c e" #'my/codeium-complete)

  (setq codeium-api-enabled
        (lambda (api)
          (memq api '(GetCompletions Heartbeat CancelRequest
                      GetAuthToken RegisterUser auth-redirect
                      AcceptCompletion))))

  ;; ----------
  (setq use-dialog-box nil) ;; do not use popup boxes

  ;; if you don't want to use customize to save the api-key
  ;; (setq codeium/metadata/api_key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

  ;; get codeium status in the modeline
  (setq codeium-mode-line-enable
        (lambda (api) (not (memq api '(CancelRequest Heartbeat AcceptCompletion)))))
  (add-to-list 'mode-line-format '(:eval (car-safe codeium-mode-line)) t)
  ;; alternatively for a more extensive mode-line
  ;; (add-to-list 'mode-line-format '(-50 "" codeium-mode-line) t)

  ;; use M-x codeium-diagnose to see apis/fields that would be sent to the local language server
  (setq codeium-api-enabled
        (lambda (api)
          (memq api '(GetCompletions Heartbeat CancelRequest GetAuthToken RegisterUser auth-redirect AcceptCompletion))))
  ;; you can also set a config for a single buffer like this:
  ;; (add-hook 'python-mode-hook
  ;;     (lambda ()
  ;;         (setq-local codeium/editor_options/tab_size 4)))

  ;; You can overwrite all the codeium configs!
  ;; for example, we recommend limiting the string sent to codeium for better performance
  (defun my-codeium/document/text ()
    (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (min (+ (point) 1000) (point-max))))
  ;; if you change the text, you should also change the cursor_offset
  ;; warning: this is measured by UTF-8 encoded bytes
  (defun my-codeium/document/cursor_offset ()
    (codeium-utf8-byte-length
     (buffer-substring-no-properties (max (- (point) 3000) (point-min)) (point))))
  (setq codeium/document/text 'my-codeium/document/text)
  (setq codeium/document/cursor_offset 'my-codeium/document/cursor_offset))

(use-package! go-mode
  ;; :hook (prog-mode . company-mode)
  :hook (go-mode . rainbow-delimiters-mode))

;; (use-package! erc-hl-nicks)
;; (use-package! erc-colorize)

;; (use-package! erc-twitch
;;   :config
;;   (add-hook! erc-twitch-mode-hook #'erc-colorize-enable)
;;   (add-hook! erc-twitch-mode-hook #'erc-hl-nicks-enable))

;; (use-package! hidepw)

;; (use-package! helm-pass)

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Password list" "p" #'helm-pass))

(load! "./blw-func/goto.el")

(load! "./blw-func/diary.el")

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Diary entry" "d" #'blw/create-or-access-diary))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("n" . "navigate to")
                    :desc "Evil Deeds" "n" #'blw/find-evildeeds)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("n" . "navigate to")
                    :desc "Function at point" "f" #'find-function-at-point)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("n" . "navigate to")
                    :desc "Emacs.org" "e"  #'blw/goto-emacs-org
                    :desc "my-func.org" "F" #'blw/goto-my-func-org)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("n" . "navigate to")
                    :desc "Active CS book" "a"  #'blw/goto-cs-active
                    :desc "CS books" "c" #'blw/goto-cs-books)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("n" . "navigate to")
                    :desc "Book notes" "n"  #'blw/goto-book-notes)))

(map! :leader
      :desc "Magit" "m" #'magit)

;; (use-package! company-coq)
;; (use-package! coq-commenter)
;; (use-package! proof-general
;;   :config
;;   (add-hook! 'coq-mode-hook #'company-coq-mode)
;;   (add-hook! 'coq-mode-hook #'coq-commenter-mode))

(load! "./blw-func/ein-babel.el")

(use-package! elm-mode
  :hook (elm-mode . rainbow-delimiters-mode))

;; (use-package! elm-oracle
;;   :config
;; (with-eval-after-load 'company
;;         (add-to-list 'company-backends 'company-elm))
;; (add-hook 'elm-mode-hook #'elm-oracle-setup-completion)

;; (use-package! eaf
;;   :load-path "~/.doom.d/site-lisp/emacs-application-framework"
;;   :custom
;;   ; See https://github.com/emacs-eaf/emacs-application-framework/wiki/Customization
;;   (eaf-browser-continue-where-left-off t)
;;   (eaf-browser-enable-adblocker t)
;;   (browse-url-browser-function 'eaf-open-browser)
;;   :config
;;   (defalias 'browse-web #'eaf-open-browser))
;;   ;; (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
;;   ;; (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
;;   ;; (eaf-bind-key take_photo "p" eaf-camera-keybinding)
;;   ;; (eaf-bind-key nil "M-q" eaf-browser-keybinding)) ;; unbind, see more in the Wiki

(add-to-list 'load-path "~/.doom.d/site-lisp/emacs-application-framework/")

(use-package! conda
  :config
  (custom-set-variables '(conda-anaconda-home "~/.conda/")))
;; (setq
;;  conda-env-home-directory (expand-file-name "~/opt/miniconda3/")
;;  conda-env-subdirectory "envs/")
;; (conda-env-initialize-interactive-shells)
;; (conda-env-initialize-eshell)
;; (conda-env-autoactivate-mode t))

;; (use-package! ein)
;; (require 'ein)

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "python environment" "e" #'pyvenv-activate))

(require 'project)

(defun project-find-go-module (dir)
  (when-let ((root (locate-dominating-file dir "go.mod")))
    (cons 'go-module root)))

(cl-defmethod project-root ((project (head go-module)))
  (cdr project))

(add-hook 'project-find-functions #'project-find-go-module)

(setq gofmt-command "goimports")
(add-hook 'before-save-hook 'gofmt-before-save)

(use-package! janet-mode)

(use-package! doom-modeline
  :config
  ;; (setq doom-modeline-height 20)
  ;; (setq doom-modeline-bar-width 3)
  ;; (setq doom-modeline-height 1) ; optional
  ;; (setq doom-modeline-buffer-file-name-style 'truncate-upto-root)
  (custom-set-faces
   '(mode-line ((t (:family "Gayathri" :size 10)))) ;; Free Sans
   '(mode-line-active ((t (:family "Gayathri" :size 10)))) ; For 29+
   '(mode-line-inactive ((t (:family "Gayathri" :size 10))))))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-monokai-pro t)

  ;; Enable flashing mode-line on errors
  ;; (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; (doom-themes-neotree-config)
  ;; or for treemacs users
  ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  ;; (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; (use-package! w3m
;;   :config
;;   (setq w3m-search-default-engine "duckduckgo"))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("s" . "search")
                    :desc "w3m search" "s" #'w3m-search
                    :desc "dictionary search" "d" #'dictionary-search)))

(use-package! sqlformat
  :config
  (setq sqlformat-command 'sleek)
  (add-hook 'sql-mode-hook 'sqlformat-on-save-mode))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "centered-cursor-mode" "C-l" #'centered-cursor-mode)
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("u" . "utilities")
                    :desc "cfw with google calendar sync" "a" #'blw/calendar)))
;;      (:prefix-map ("b" . "buddhi")
;;       :desc "ace follow link" "a" #'ace-link))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("m" . "Multiple Cursors")
                    :desc "mc/mark-next-like-this" "n" #'mc/mark-next-like-this
                    :desc "mc/mark-previous-like-this" "p" #'mc/mark-previous-like-this
                    :desc "mc/mark-all-like-this" "a" #'mc/mark-all-like-this)))

(map! :after multiple-cursors-mode
      :map multiple-cursors-map
      "C-n" 'mc/mark-next-like-this
      "C-p" 'mc/mark-previous-like-this
      "C-a" 'mc/mark-all-like-this)
;; (when (modulep! :editor multiple-cursors)
;;   (map! "C->"   #'mc/mark-next-like-this
;;         "C-<"   #'mc/mark-previous-like-this
;;         "C-M->" #'mc/skip-to-next-like-this
;;         "C-M-<" #'mc/skip-to-previous-like-this
;;         "M-<mouse-1>" #'mc/add-cursor-on-click)
;;   (map! :leader
;;         :prefix "m"
;;         :desc "Pop mark"                        "SPC"   #'mc/mark-pop
;;         :desc "Mark all above"                  "<"     #'mc/mark-all-above
;;         :desc "Mark all below"                  ">"     #'mc/mark-all-below
;;         :desc "Mark words like this"            "W"     #'mc/mark-all-words-like-this
;;         :desc "Mark symbols like this"          "S"     #'mc/mark-all-symbols-like-this
;;         :desc "Mark words like this in defun"   "C-w"   #'mc/mark-all-words-like-this-in-defun
;;         :desc "Mark symbols like this in defun" "C-s"   #'mc/mark-all-symbols-like-this-in-defun
;;         :desc "Mark next sexps"                 "C-M-f" #'mc/mark-next-sexps
;;         :desc "Mark previous sexps"             "C-M-b" #'mc/mark-previous-sexps
;;         :desc "Mark regexp"                     "%"     #'mc/mark-all-in-region-regexp)
;;   (after! multiple-cursors-core
;;     (dolist (cmd '(doom/delete-backward-word
;;                    doom/forward-to-last-non-comment-or-eol mark-sexp
;;                    eros-eval-last-sexp eval-last-sexp cae-eval-last-sexp
;;                    forward-sentence backward-sentence kill-sentence
;;                    sentex-forward-sentence sentex-backward-sentence
;;                    sentex-kill-sentence parrot-rotate-next-word-at-point
;;                    cae-delete-char cae-modeline-rotate-next-word-at-point
;;                    cae-modeline-rotate-prev-word-at-point
;;                    forward-sexp backward-sexp backward-list forward-list))
;;       (add-to-list 'mc/cmds-to-run-for-all cmd))
;;     (dolist (cmd '(+workspace/new +workspace/load +workspace/save
;;                    +workspace/cycle +workspace/other +workspace/delete
;;                    +workspace/rename +workspace/display +workspace/new-named
;;                    +workspace/swap-left +workspace/switch-to
;;                    +workspace/swap-right +workspace/switch-left
;;                    +workspace/switch-to-0 +workspace/switch-to-1
;;                    +workspace/switch-to-2 +workspace/switch-to-3
;;                    +workspace/switch-to-4 +workspace/switch-to-5
;;                    +workspace/switch-to-6 +workspace/switch-to-7
;;                    +workspace/switch-to-8 +workspace/kill-session
;;                    +workspace/switch-right +workspace/switch-to-final
;;                    +workspace/restore-last-session +workspace/kill-session-and-quit
;;                    +workspace/close-woutdow-or-workspace read-only-mode
;;                    save-buffers-kill-terminal))
;;       (add-to-list 'mc/cmds-to-run-once cmd))
;;     (dolist (mode '(cae-completion-mode symbol-overlay-mode goggles-mode
;;                     lispy-mode corfu-mode hungry-delete-mode
;;                     worf-mode isearch-mb-mode))
;;       (add-to-list 'mc/unsupported-minor-modes mode))
;;     (define-key mc/keymap (kbd "C-. .")     #'mc/move-to-column)
;;     (define-key mc/keymap (kbd "C-. =")     #'mc/compare-chars)
;;     (define-key mc/keymap (kbd "C-. C-.")   #'mc/freeze-fake-cursors-dwim)
;;     (define-key mc/keymap (kbd "C-. C-d")   #'mc/remove-current-cursor)
;;     (define-key mc/keymap (kbd "C-. C-k")   #'mc/remove-cursors-at-eol)
;;     (define-key mc/keymap (kbd "C-. C-o")   #'mc/remove-cursors-on-blank-lines)
;;     (define-key mc/keymap (kbd "C-. d")     #'mc/remove-duplicated-cursors)
;;     (define-key mc/keymap (kbd "C-. l")     #'mc/insert-letters)
;;     (define-key mc/keymap (kbd "C-. n")     #'mc/insert-numbers)
;;     (define-key mc/keymap (kbd "C-. s")     #'mc/sort-regions)
;;     (define-key mc/keymap (kbd "C-. r")     #'mc/reverse-regions)
;;     (define-key mc/keymap (kbd "C-. [")     #'mc/vertical-align-with-space)
;;     (define-key mc/keymap (kbd "C-. {")     #'mc/vertical-align)))

(load! "./blw-func/vocabulary.el")

(load! "./blw-func/define-modules.el")

(load! "./blw-func/load-modules.el")

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("l" . "load module")
                    :desc "Chinese" "c" #'blw/load-chinese
                    :desc "LaTeX" "l" #'blw/load-latex)))

(load! "./blw-func/isosec.el")

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("z" . "Zettle funcs")
                    :desc "Isosec" "i" #'blw/insert-current-isosec)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix-map ("r" . "read")
                    :desc "EPUB refresh size" "r" #'nov-render-document)))

(load! "./blw-func/fast-input-method.el")
(evil-mode)

(require 'ox-reveal)

;; (use-package impatient-mode)

(add-hook 'typescript-mode-hook 'eslint-rc-mode)
(add-hook 'js2-mode-hook 'eslint-rc-mode)
(add-hook 'web-mode-hook 'eslint-rc-mode)

(add-hook 'rjsx-mode-hook 'tide-mode)

;; use web-mode for .jsx files
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))

;; http://www.flycheck.org/manual/latest/index.html
(require 'flycheck)

;; turn on flychecking globally
(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(javascript-jshint)))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(json-jsonlist)))

;; https://github.com/purcell/exec-path-from-shell
;; only need exec-path-from-shell on OSX
;; this hopefully sets up path and other vars better
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; (add-hook 'web-mode-hook 'lsp-defered)

;; (use-package! slime
;;   :config (setq inferior-lisp-program "sbcl"))

(defun insert-file-name ()
  "Insert the full path file name into the current buffer."
  (interactive)
  (insert (concat (buffer-file-name (window-buffer (minibuffer-selected-window))) " " (what-line))))

(map! :after evil-mode
      :map tide-mode-map
      "C-." nil)

(map! :map tide-mode-map
      "C-." 'tide-jump-to-definition
      "C-," 'tide-jump-back)

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("j" . "javascript")
                    :desc "go-to definition" "." #'tide-jump-to-definition
                    :desc "go-to implementation" "," #'tide-jump-implementation
                    :desc "back from go-to" "," #'tide-jump-back)))

;; Insert file name:
;; To easily point out stuff in files, in documentation processes
;; and team alignments etc.

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "insert file name" "n" #'insert-file-name))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("w" . "web")
                    :desc "attribute match" "m" #'web-mode-tag-match)))

;; accept completion from copilot and fallback to company
;; (use-package! copilot
;;   :hook (prog-mode . copilot-mode)
;;   :bind (("C-TAB" . 'copilot-accept-completion-by-word)
;;          ("C-<tab>" . 'copilot-accept-completion-by-word)
;;          :map copilot-completion-map
;;          ("<tab>" . 'copilot-accept-completion)
;;          ("TAB" . 'copilot-accept-completion)))

;; (map! :leader
;;       (:prefix-map ("b" . "buddhi")
;;        (:prefix ("c" . "Complete")
;;         :desc "Accept full completion" "TAB" #'copilot-accept-completion)))

;; (map! :leader
;;       (:prefix-map ("b" . "buddhi")
;;         :desc "Accept full completion" "TAB" #'copilot-accept-completion))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Yasnippet" "y" #'company-yasnippet))

;; (map! :leader
;;       (:prefix-map ("b" . "buddhi")
;;        (:prefix ("c" . "Complete")
;;         :desc "Accept full completion" "TAB" #'+company/complete)))

;; From  time.el -> display-time-mode
(defun blw/display-time-event-handler ()
  (display-time-update)
  (let* ((current (current-time))
	 (timer display-time-timer)
	 ;; Compute the time when this timer will run again, next.
	 (next-time (timer-relative-time
		     (list (aref timer 1) (aref timer 2) (aref timer 3))
		     (* 5 (aref timer 4)) 0)))
    ;; If the activation time is not in the future,
    ;; skip executions until we reach a time in the future.
    ;; This avoids a long pause if Emacs has been suspended for hours.
    (or (time-less-p current next-time)
	(progn
	  (timer-set-time timer (timer-next-integral-multiple-of-time current display-time-interval) display-time-interval)
	  (timer-activate timer)))))

(defun blw/timer-pomo ()
  (let ((pomo-output (shell-command-to-string "sb-pomo | tr -d '\n'")))
    (if (equal "" pomo-output)
        (progn
          (cancel-function-timers 'blw/timer-pomo)
          (setq-default mode-line-misc-info "No pomodoro running"))
      (setq-default mode-line-misc-info pomo-output))))

(defun blw/pomodoro-echo ()
  (interactive
   (run-with-timer 0 1 'blw/timer-pomo)
   (run-at-time t 1 'blw/display-time-event-handler)))

(defun blw/kill-pomo-updates ()
  (interactive
   (progn
     (cancel-function-timers 'blw/timer-pomo)
     (cancel-function-timers 'blw/display-time-event-handler)
     (setq-default mode-line-misc-info nil))))

;; (set-face-attribute 'default nil :font "DejaVu Sans Mono-12")
;; (set-fontset-font t 'arabic (font-spec :family "DejaVu Sans Mono"))
;; (setq org-superstar-headline-bullets-list '("ن" "ل" "ا" "م" "هـ" "ي" "ص"))

;; (use-package! org-bullets
;;   :after org
;;   ;; :hook (org-mode . org-bullets)
;;   :custom
;;   ;; (org-superstar-remove-leading-stars t)
;;   (org-bullets-bullet-list '("家" "ॐ" "同" "Ø" "א" "҉ " "҈ ")))
;; ("ن" "ل" "ا" "م" "هـ" "ي" "ص")

;; (set-fontset-font t 'arabic "Noto Sans Arabic")
;; (font-family-list)
(use-package! org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("ن" "ل" "ا" "م" "هـ" "ي" "ص")))

;; (with-eval-after-load 'org-superstar
;;   (set-face-attribute 'org-superstar-item nil :font "Noto Sans Arabic"))

(with-eval-after-load 'org-superstar
  (set-face-attribute 'org-superstar-item nil :family "Noto Sans Arabic" :weight 'regular))

;; (org-bullets-bullet-list '("ن" "ل" "ا" "م" "هـ" "ي" "ص")))
;; Make sure org-indent face is available
(require 'org-indent)
;; (require 'org-indent
;; Ensure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; Get rid of the background on column views
(set-face-attribute 'org-column nil :background nil)
(set-face-attribute 'org-column-title nil :background nil)
;; (set-face-attribute 'org-superstar-item nil :font "Noto Sans Arabic")

;; Install visual-fill-column
;;(unless (package-installed-p 'visual-fill-column)
;;  (package-install 'visual-fill-column))


(defun dw/org-present-start ()
  ;; Center the presentation and wrap lines
  (visual-fill-column-mode 1)
  (visual-line-mode 1))

(defun dw/org-present-end ()
  ;; Stop centering the document
  (visual-fill-column-mode 0)
  (visual-line-mode 0))


(defun dw/org-present-prepare-slide ()
  (org-overview)
  (org-show-entry)
  (org-show-children))

(defun dw/org-present-hook ()
  ;; Configure fill width
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t)
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
				     (header-line (:height 4.0) variable-pitch)
				     (org-document-title (:height 1.75) org-document-title)
				     (org-code (:height 1.55) org-code)
				     (org-verbatim (:height 1.55) org-verbatim)
				     (org-block (:height 1.40) org-block)
				     (org-block-begin-line (:height 0.7) org-block)))
  (setq header-line-format " ")
  (org-appear-mode -1)
  (org-display-inline-images)
  (dw/org-present-prepare-slide))

(defun dw/org-present-quit-hook ()
  (setq-local face-remapping-alist '((default variable-pitch default)))
  (setq header-line-format nil)
  (org-present-small)
  (org-remove-inline-images)
  (org-appear-mode 1))

(defun dw/org-present-prev ()
  (interactive)
  (org-present-prev)
  (dw/org-present-prepare-slide))

(defun dw/org-present-next ()
  (interactive)
  (org-present-next)
  (dw/org-present-prepare-slide))

(use-package! org-present
  :bind (:map org-present-mode-keymap
	      ("C-c C-j" . dw/org-present-next)
	      ("C-c C-k" . dw/org-present-prev))
  :hook ((org-present-mode . dw/org-present-hook)
         (org-present-mode-quit . dw/org-present-quit-hook)
         (org-present-mode-hook . dw/org-present-start)
         (org-present-mode-quit-hook . dw/org-present-end)))
;; Register hooks with org-present
;; (add-hook 'org-present-mode-hook 'my/org-present-start)
;; (add-hook 'org-present-mode-quit-hook 'my/org-present-end)

;;; Theme and Fonts ----------------------------------------

;; ;; Install doom-themes
;; (unless (package-installed-p 'doom-themes)
;;   (package-install 'doom-themes))

;; ;; Load up doom-palenight for the System Crafters look
;; (load-theme 'doom-palenight t)

;; ;; Set reusable font name variables
;; (defvar my/fixed-width-font "JetBrains Mono"
;;   "The font to use for monospaced (fixed width) text.")

;; (defvar my/variable-width-font "Iosevka Aile"
;;   "The font to use for variable-pitch (document) text.")

;; ;; NOTE: These settings might not be ideal for your machine, tweak them as needed!
;; (set-face-attribute 'default nil :font my/fixed-width-font :weight 'light :height 100)
;; (set-face-attribute 'fixed-pitch nil :font my/fixed-width-font :weight 'light :height 110)
;; (set-face-attribute 'variable-pitch nil :font my/variable-width-font :weight 'light)

;;; Org Mode Appearance ------------------------------------

;; Load org-faces to make sure we can set appropriate faces
(require 'org-faces)

;; Hide emphasis markers on formatted text
(setq org-hide-emphasis-markers t)

;; Resize Org headings
(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1))))
;; (set-face-attribute (car face) nil :font my/variable-width-font :weight 'medium :height (cdr face)))

;; Make the document title a bit bigger
;; (set-face-attribute 'org-document-title nil :font my/variable-width-font :weight 'bold :height 1.3)

;; Make sure certain org faces use the fixed-pitch face when variable-pitch-mode is on
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;;; Centering Org Documents --------------------------------

;; Install visual-fill-column
;;(unless (package-installed-p 'visual-fill-column)
;;  (package-install 'visual-fill-column))

;; Configure fill width
(setq visual-fill-column-width 110
      visual-fill-column-center-text t)

;;; Org Present --------------------------------------------

;; Install org-present if needed
;;(unless (package-installed-p 'org-present)
;;  (package-install 'org-present))

(defun my/org-present-prepare-slide (buffer-name heading)
  ;; Show only top-level headlines
  (org-overview)

  ;; Unfold the current entry
  (org-show-entry)

  ;; Show only direct subheadings of the slide but don't expand them
  (org-show-children))

(defun my/org-present-start ()
  ;; Tweak font sizes
  (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                     (header-line (:height 2.0) variable-pitch)
                                     (org-document-title (:height 1.75) org-document-title)
                                     (org-code (:height 1.55) org-code)
                                     (org-verbatim (:height 1.55) org-verbatim)
                                     (org-block (:height 1.25) org-block)
                                     (org-block-begin-line (:height 0.7) org-block)))

  ;; Set a blank header line string to create blank space at the top
  (setq header-line-format " ")

  ;; Display inline images automatically
  (org-display-inline-images)

  ;; Center the presentation and wrap lines
  (visual-fill-column-mode 1)
  (visual-line-mode 1))

(defun my/org-present-end ()
  ;; Reset font customizations
  (setq-local face-remapping-alist '((default variable-pitch default)))

  ;; Clear the header line string so that it isn't displayed
  (setq header-line-format nil)

  ;; Stop displaying inline images
  (org-remove-inline-images)

  ;; Stop centering the document
  (visual-fill-column-mode 0)
  (visual-line-mode 0))

;; Turn on variable pitch fonts in Org Mode buffers
(add-hook 'org-mode-hook 'variable-pitch-mode)

;; Register hooks with org-present
(add-hook 'org-present-mode-hook 'my/org-present-start)
(add-hook 'org-present-mode-quit-hook 'my/org-present-end)
(add-hook 'org-present-after-navigate-functions 'my/org-present-prepare-slide)

(setq org-hide-emphasis-markers t)

(defun blw/insert-code-file-line-number ()
  (interactive)
  (insert (format "%s-%s"
                  (buffer-file-name)
                  (what-line))))

;; '(require 'clojure-mode-extra-font-locking)
;; (eval-after-load 'clojure-mode '(require 'clojure-mode-extra-font-locking))
;; (add-hook! clojure-mode #'clojure-mode-extra-font-locking)

(defmacro blw/define-user-eval-reitit (fn-name command)
  `(defun ,fn-name ()
     (interactive)
     (cider-eval-file (format (concat (getenv "CLJ_PLAYGROUND") "dev/src/user.clj"))) ;; "/path-to/dev/src/user.clj"
     (cider-interactive-eval
      (format (concat "(" ,command ")")
              (cider-last-sexp)))))

(blw/define-user-eval-reitit blw/eval-go "go")
(blw/define-user-eval-reitit blw/eval-halt "halt")
(blw/define-user-eval-reitit blw/eval-reset "reset")
;; (define-key cider-mode-map (kbd "C-c g") 'blw/eval-go)

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("c" . "clojure")
                    :desc "go - start reitit" "g" #'blw/eval-go
                    :desc "halt reitit server" "h" #'blw/eval-halt
                    :desc "reset reitit server" "r" #'blw/eval-reset)))

;; (getenv "CLJ")
;; (format (concat (getenv "CLJ_PLAYGROUND") "dev/src/user.clj"))
;; (getenv "CLJ_PLAYGROUND")

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("c" . "clojure")
                            (:prefix ("t" . "tests")
                             :desc "Run all tests" "p" #'cider-test-run-project-tests
                             :desc "Run tests in namespace" "n" #'cider-test-run-ns-tests
                             :desc "Run test under point" "t" #'cider-test-run-test))))

;; config.el
(use-package! dartclojure
  :config
  (setq dartclojure-opts "-m \"m\" -f \"f\""))

;; config.el
(map! :leader
      (:prefix ("d" . "dartclojure")
       :desc "dartclojure to buffer"
       "b" #'dartclojure-paste-buffer
       :desc "dartclojure to clipboard"
       "c" #'dartclojure-to-clipboard
       :desc "dartclojure converter"
       "x" #'dartclojure-convert))

;; config.el
;; Major mode for .cljel files
(use-package! clojure-elisp-mode
  :load-path "~/PP/clojure-elisp/resources/clojure-elisp/"
  :mode "\\.cljel\\'")

;; CIDER integration for ClojureElisp - provides eval keybindings
;; C-c C-e  — eval last sexp
;; C-c C-c  — eval defun at point
;; C-c C-k  — compile/eval entire buffer
(after! cider
  (add-to-list 'load-path "~/PP/clojure-elisp/resources/clojure-elisp/")
  (require 'cider-clojure-elisp)
  ;; Auto-enable cider-cljel-mode in clojure-elisp-mode buffers
  (add-hook 'clojure-elisp-mode-hook #'cider-cljel-mode))

;; Enable Clojure mode
(use-package! clojure-mode
  :config
  ;; Enable automatic alignment of forms
  (setq clojure-align-forms-automatically t))

(use-package! cider
  :ensure t
  :config
  (setq cider-repl-display-help-banner nil))

(add-hook 'clojure-mode-hook 'cider-mode)
(add-hook 'cider-mode-hook 'eldoc-mode) ;; Optional: for showing function arg info

(use-package! web-server)

;; Load hive-mcp AI bridge and addons
(when (locate-library "hive-mcp-ai-bridge")
  (require 'hive-mcp-ai-bridge)

  ;; gptel integration - inject memory context, store notable responses
  (when (locate-library "hive-mcp-gptel")
    (require 'hive-mcp-gptel)
    (hive-mcp-gptel-mode 1)))

;; Use HIVE_MCP_DIR env var (set in shell profile)
(defvar hive-mcp-root (or (getenv "HIVE_MCP_DIR")
                          (expand-file-name "gitthings/hive-mcp" (getenv "DOTFILES")))
  "Root directory of hive-mcp installation.")

(add-to-list 'load-path (concat hive-mcp-root "/elisp"))
(add-to-list 'load-path (concat hive-mcp-root "/elisp/addons"))
  
;
; Pre-configure before loading
;; Don't start separate nREPL - MCP server now embeds it (commit 7123de0)
;; This ensures bb-mcp hivemind calls go to the correct JVM with channel server
(setq hive-mcp-cider-auto-start-nrepl nil)
(setq hive-mcp-cider-auto-connect t)  ; Connect to MCP server's embedded nREPL
(setq hive-mcp-cider-nrepl-port 7910)  ; Must match deps.edn :nrepl alias
(setq hive-mcp-cider-project-dir hive-mcp-root)  ; Use hive-mcp project for nREPL
(setq hive-mcp-addon-always-load '(cider org-kanban swarm projectile magit chroma docs))

;; Org-kanban configuration
(setq hive-mcp-kanban-org-file (concat hive-mcp-root "/kanban.org"))
(setq hive-mcp-kanban-default-project "b70720e8-3a52-41ba-a115-964b81369bb5")

;; Claude-code-ide configuration (for swarm sessions with MCP integration)
;; Package loaded from straight.el (BuddhiLW/claude-code-ide.el, branch: main)
(setq claude-code-ide-enable-mcp-server t)
;; Workaround: empty tool list causes broken --allowedTools flag
;; Set to nil to disable the flag entirely (Claude uses all tools)
(setq claude-code-ide-mcp-allowed-tools nil)

;; Swarm orchestration configuration
(setq hive-mcp-swarm-presets-dir (concat hive-mcp-root "/presets"))
(setq hive-mcp-swarm-terminal 'claude-code-ide)  ; Full MCP WebSocket integration
(setq hive-mcp-swarm-max-slaves 30)    ; max concurrent lings
(setq hive-mcp-swarm-max-depth 3)      ; recursion limit (master→child→grandchild→great-grandchild)
(setq hive-mcp-swarm-prompt-mode 'human) ; human-in-the-loop for permission prompts

;; Melpazoid integration for MELPA submission testing
(setq hive-mcp-melpazoid-path (expand-file-name "gitthings/melpazoid" (getenv "DOTFILES")))

;; Chroma vector database for semantic memory search
(setq hive-mcp-chroma-auto-start t)        ; Auto-start Chroma container on init
(setq hive-mcp-chroma-host "localhost")
(setq hive-mcp-chroma-port 8000)
(setq hive-mcp-chroma-embedding-provider 'ollama)
(setq hive-mcp-chroma-ollama-model "nomic-embed-text")

;; Disable old Unix socket channel (using WebSocket instead)
(setq hive-mcp-channel-auto-connect nil)

;; Load hive-mcp
(require 'hive-mcp)
(hive-mcp-mode 1)  ; Enable hive-mcp-mode for mcp_get_context and other context tools

;; Load addons explicitly
(require 'hive-mcp-addons)
(require 'hive-mcp-transient)
(require 'hive-mcp-cider nil t)

;; Defer org-kanban until evil is loaded (uses evil-define-key)
(after! evil
  (require 'hive-mcp-org-kanban nil t))

(require 'hive-mcp-swarm nil t)
;; human in the loop: default to *lings* forwarding requests to *hive-mind* (then to you).
(setq hive-mcp-swarm-prompt-mode 'human)

(require 'hive-mcp-melpazoid nil t)
(require 'hive-mcp-projectile nil t)
(require 'hive-mcp-magit nil t)
(require 'hive-mcp-chroma nil t)
(require 'hive-mcp-docs nil t)

;; Olympus grid view for swarm lings
(require 'hive-mcp-olympus nil t)
(hive-mcp-olympus-mode 1)  ; Enable global grid keybindings + notifications

;; WebSocket channel for push-based hivemind events (replaces unreliable bencode channel)
(require 'hive-mcp-channel-ws nil t)
(setq hive-mcp-channel-ws-url "ws://localhost:9999")  ; Must match Clojure server port
(setq hive-mcp-channel-ws-auto-connect t)             ; Connect after startup
(setq hive-mcp-channel-ws-startup-delay 5.0)          ; Wait for MCP server to be ready

;; Register handlers for hivemind push events
(with-eval-after-load 'hive-mcp-channel-ws
  ;; Notify on hivemind progress/completion events
  (hive-mcp-channel-ws-on "hivemind-progress"
    (lambda (msg)
      (message "[Hivemind] %s: %s"
               (cdr (assoc 'agent-id msg))
               (cdr (assoc 'message (cdr (assoc 'data msg)))))))
  (hive-mcp-channel-ws-on "hivemind-completed"
    (lambda (msg)
      (message "[Hivemind] %s completed: %s"
               (cdr (assoc 'agent-id msg))
               (cdr (assoc 'message (cdr (assoc 'data msg))))))))

;; Auto-load addons when their packages are detected
(hive-mcp-addons-auto-load)

;; Keybinding for MCP transient menu (under SPC b m for "buddhi/mcp")
(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("m" . "mcp")
        :desc "MCP menu" "m" #'hive-mcp-transient-main
        :desc "CIDER menu" "c" #'hive-mcp-cider-transient
        :desc "Kanban menu" "k" #'hive-mcp-kanban-transient
        :desc "Swarm menu" "s" #'hive-mcp-swarm-transient
        :desc "Melpazoid menu" "z" #'hive-mcp-melpazoid-transient
        :desc "Projectile menu" "p" #'hive-mcp-projectile-transient
        :desc "Magit/Git menu" "g" #'hive-mcp-magit-transient
        :desc "Chroma/Vector menu" "v" #'hive-mcp-chroma-transient
        :desc "Docs menu" "d" #'hive-mcp-docs-transient
        :desc "Olympus grid" "o" #'hive-olympus
        :desc "Olympus dashboard" "O" #'hive-mcp-olympus-dashboard)))

;; if you are using the "pass" password manager
;; (setq chatgpt-shell-openai-key
;;         (nth 0 (process-lines "pass" "show" "AI/open")))
;; (setq openai-key (nth 0 (process-lines "pass" "show" "Open/AI")))

;; (add-to-list 'load-path "~/.emacs.d/openai/")
;; (add-to-list 'load-path "~/.emacs.d/chatgpt/")
;; (add-to-list 'load-path "~/.emacs.d/lisp/")
;; (require 'codegpt)
;; (require 'chatgpt)
;; (package! chatgtp
;;   :recipe (:host jcs-elpa
;;            :repo "https://jcs-emacs.github.io/jcs-elpa/packages/")) ;; Optional: specify a specific commit or version

;; :recipe (:host jcs-elpa))
;; :repo "https://github.com/emacs-openai/codegpt")) ;; Optional: specify a specific commit or version

;; (package! codegtp)

(add-to-list 'package-archives '( "jcs-elpa" . "https://jcs-emacs.github.io/jcs-elpa/packages/") t)
(setq package-archive-priorities '(("melpa"    . 5)
                                   ("jcs-elpa" . 0)))

;; (require 'chatgpt-shell)
;; (require 'dall-e-shell)

(eval-after-load "tex"
  '(setcdr (assoc "LaTeX" TeX-command-list)
    '("%`%l%(mode) -shell-escape%' %t"
      TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX")))

;; (use-package! calfw-ical)
(defun blw/calendar ()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "Green")  ; orgmode source
    ;; (cfw:howm-create-source "Blue")  ; howm source
    ;; (cfw:cal-create-source "Orange") ; diary source
    ;; (cfw:ical-create-source "Moon" "~/moon.ics" "Gray")  ; ICS source1
    ;; (cfw:ical-create-source "gcal" (nth 0 (process-lines "pass" "show" "CALFW/gmail-ical-url-facti" "Red")))
    (cfw:ical-create-source "gcal" (nth 0 (process-lines "pass" "show" "CALFW/gmail-ical-url")) "Blue") ;; google calendar ICS
    (cfw:ical-create-source "gcal" (nth 0 (process-lines "pass" "show" "CALFW/orasis-ical-url")) "Red"))))  ;; Orasis

(use-package! indent-bars
  :hook ((prog-mode yaml-mode go-mode clojure-mode clojurescript-mode python-mode elm-mode) . indent-bars-mode)
  ;; or whichever modes you prefer
  :config
  (setq indent-bars-pattern "."
        ;; indent-bars-pattern ".*.*.*.*.*.*.*.*"
        indent-bars-width-frac 0.25
        indent-bars-pad-frac 0.3
        ;; indent-bars-pad-frac 0.2
        ;; indent-bars-zigzag 0.1
        indent-bars-color-by-depth '(:palette ("black" "white" "green" "red") :blend 0.5)
        indent-bars-highlight-current-depth '(:blend 1.0 :width 0.4 :pad 0.1 :pattern "!.!.!." :zigzag 0.1)
        indent-bars-ts-highlight-current-depth '(no-inherit) ; equivalent to nil
        indent-bars-ts-color-by-depth '(no-inherit)
        indent-bars-ts-color '(inherit fringe :face-bg t :blend 0.2)
        ;; indent-bars-highlight-current-depth '(:background "red10")
        ;; indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 0.5)
        indent-bars-highlight-current-depth '(:face default :blend 0.9)))

;; EXWM init function
(load! "./blw-func/exwm-init.el")

(add-hook 'exwm-init 'blw/exwm-init)

;; Make sure the server is started (better to do this in your main Emacs config!)
(server-start)

(defvar efs/polybar-process nil
  "Holds the process of the running Polybar instance, if any")

(defun efs/kill-panel ()
  (interactive)
  (when efs/polybar-process
    (ignore-errors
      (kill-process efs/polybar-process)))
  (setq efs/polybar-process nil))

(defun efs/start-panel ()
  (interactive)
  (efs/kill-panel)
  (setq efs/polybar-process (start-process-shell-command "polybar" nil "polybar panel")))

(defun efs/send-polybar-hook (module-name hook-index)
  (start-process-shell-command "polybar-msg" nil (format "polybar-msg hook %s %s" module-name hook-index)))

(defun efs/send-polybar-exwm-workspace ()
  (efs/send-polybar-hook "exwm-workspace" 1))

;; Update panel indicator when workspace changes
(add-hook 'exwm-workspace-switch-hook #'efs/send-polybar-exwm-workspace)

;; "/run/user/1000/tmux-1000/default"

;; (use-package! evil-nerd-commenter)

(use-package! corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator)
  (corfu-preselect 'directory))

(use-package! cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'codeium-completion-at-point))
(global-set-key (kbd "M-<return>") (cape-capf-interactive #'codeium-completion-at-point))

;; ;; (use-package! go-translate
;; ;;   :config
;; (setq gt-langs '(en zh))
;;                  ;; ("en" "ru")
;;                  ;; ("en" "pt-br")
;;                  ;; ("pt-br" "en")))

;; (setq gt-default-translator
;;         (gt-translator
;;          :taker   (gt-taker :text 'buffer :pick 'paragraph)
;;          :engines  (list
;;                    (gt-bing-engine)
;;                    (gt-google-engine)
;;                    (gt-google-rpc-engine))
;;          :render
;;          (gt-buffer-render)))

;; ;; (setq gt-langs '(en fr))        ; Default translation languages, at least two ​​must be specified
;; (setq gt-taker-text 'word)      ; By default, the initial text is the word under the cursor. If there is active region, the selected text will be used first
;; (setq gt-taker-pick 'paragraph) ; By default, the initial text will be split by paragraphs. If you don't want to use multi-parts translation, set it to nil
;; (setq gt-taker-prompt nil)
;; ;; (setq gt-default-translator (gt-translator :engines (gt-google-engine)))

;; (setq gt-buffer-evil-leading-key "x")
;;        ;; (gt-posframe-pop-render))

(setq telega-server-libs-prefix "~/dotfiles/gitthigs/td/")

;; (setq treesit-extra-load-path "/home/kolmogorov/.emacs.d/.local/straight/build-30.0.50/tree-sitter-langs/")

(setq +tree-sitter-hl-enabled-modes t)

(use-package! treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode)
  :hook (prog-mode . treesit-auto-mode))

;; (require 'tree-sitter)
;; (require 'tree-sitter-langs)
;; ;; (treesit-auto-add-to-auto-mode-alist 'all)
;; (global-tree-sitter-mode)
;; (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
;; (add-to-list 'tree-sitter-major-mode-language-alist '(go-ts-mode . go))
;; (dolist (entry tree-sitter-major-mode-language-alist)
;;   (let ((mode (car entry)))
;;     (add-hook (intern (concat (symbol-name mode) "-hook")) #'lsp-deferred)))

(load! "./blw-func/ewal.el")

;; defines blw/run-yazi
(load! "./blw-func/yazi.el")

;; binding
(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("i" . "(system's) Integrations")
                    :desc "Yazi launch" "y" #'blw/run-yazi)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("x" . "command")
                    :desc "Yazi-find" "f" #'blw/run-yazi)))

;; defines blw/run-kitty
(load! "./blw-func/terminal.el")

;; binding
(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("i" . "(system's) Integrations")
                    :desc "Kitty terminal launch" "t" #'blw/run-kitty)))

;; (defun eglot-format-buffer-before-save ()
;;    (add-hook 'before-save-hook #'eglot-format-buffer -10 t))

;; (use-package! eglot
;;   :ensure t
;;   :hook ((typescript-mode typescript-tsx-mode web-mode) . eglot-ensure)
;;   :config
;;   (add-to-list 'eglot-server-programs
;;                '((typescript-mode typescript-tsx-mode) . ("typescript-language-server" "--stdio")))
;;   (setq web-mode-markup-indent-offset 2
;;         web-mode-code-indent-offset 2
;;         web-mode-sql-indent-offset 2
;;         web-mode-css-indent-offset 2
;;         tab-width 2
;;         evil-shift-width 2)
;;   (add-hook! go-mode-hook #'eglot-ensure)
;;   ;; Optional: install eglot-format-buffer as a save hook.
;;   ;; The depth of -10 places this before eglot's willSave notification,
;;   ;; so that that notification reports the actual contents that will be saved.
;;   ;; (add-hook! go-mode-hook #'eglot-format-buffer-before-save)
;;   (add-hook! before-save-hook
;;     (lambda ()
;;         (call-interactively 'eglot-code-action-organize-imports))
;;     nil t))

(use-package! rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package! citre
  :defer t
  :init
  ;; This is needed in `:init' block for lazy load to work.
  (require 'citre-config)
  ;; Bind your frequently used commands.  Alternatively, you can define them
  ;; in `citre-mode-map' so you can only use them when `citre-mode' is enabled.
  (global-set-key (kbd "C-x c j") 'citre-jump)
  (global-set-key (kbd "C-x c J") 'citre-jump-back)
  (global-set-key (kbd "C-x c p") 'citre-ace-peek)
  (global-set-key (kbd "C-x c u") 'citre-update-this-tags-file)
  :config
  (setq
   ;; Set these if readtags/ctags is not in your PATH.
   ;; citre-readtags-program "/path/to/readtags"
   ;; citre-ctags-program "/path/to/ctags"
   ;; Set these if gtags/global is not in your PATH (and you want to use the
   ;; global backend)
   ;; citre-gtags-program "/path/to/gtags"
   ;; citre-global-program "/path/to/global"
   ;; Set this if you use project management plugin like projectile.  It's
   ;; used for things like displaying paths relatively, see its docstring.
   citre-project-root-function #'projectile-project-root
   ;; Set this if you want to always use one location to create a tags file.
   citre-default-create-tags-file-location 'global-cache
   ;; Set this if you'd like to use ctags options generated by Citre
   ;; directly, rather than further editing them.
   citre-edit-ctags-options-manually nil
   ;; If you only want the auto enabling citre-mode behavior to work for
   ;; certain modes (like `prog-mode'), set it like this.
   citre-auto-enable-citre-mode-modes '(prog-mode)))

;; (global-set-key (kbd "C-x c j") 'citre-jump)
;; (global-set-key (kbd "C-x c J") 'citre-jump-back)
;; (global-set-key (kbd "C-x c p") 'citre-ace-peek)
;; (global-set-key (kbd "C-x c u") 'citre-update-this-tags-file)
;;; Change to these kinds of bindings
(map! :leader
      (:prefix-map ("b" . "buddhi")
                   (:prefix ("c" . "Code|Citre|Clojure")
                            (:prefix ("c" . "Citre")
                             :desc "Jump" "j"               #'citre-jump
                             :desc "Jump back" "J"          #'citre-jump-back
                             :desc "Ace peek" "p"           #'citre-ace-peek
                             :desc "Update `tags` file" "u" #'citre-update-this-tags-file))))

;; (use-package! company
;;     :defer 0.1
;;     :config
;;     (global-company-mode t)
;;     (setq-default
;;         company-idle-delay 0.5
;;         company-require-match nil
;;         company-minimum-prefix-length 0

;;         ;; get only preview
;;         ;; company-frontends '(company-preview-frontend)))
;;         ;; also get a drop down
;;         company-frontends '(company-pseudo-tooltip-frontend company-preview-frontend)))

(use-package! lsp-mode
  :hook (prog-mode . lsp)
  :commands lsp)

(require 'dap-mode)
(require 'dap-ui)
(require 'dap-dlv-go)

(setq dap-auto-configure-features '(sessions locals controls tooltip))
(dap-mode 1)
;; The modes below are optional
(dap-ui-mode 1)
;; enables mouse hover support
(dap-tooltip-mode 1)
;; use tooltips for mouse hover
;; if it is not enabled `dap-mode' will use the minibuffer.
(tooltip-mode 1)
;; displays floating panel with debug buttons
;; requies emacs 26+
(dap-ui-controls-mode 1)

;; Optionally, set up a keybinding for debugging
(global-set-key (kbd "<f5>") #'dap-debug)

(dap-register-debug-template "Go Debug"
                             (list :type "go"
                                   :request "launch"
                                   :name "Launch Go Program"
                                   :mode "auto"
                                   :program "${workspaceFolder}/main.go"
                                   :buildFlags ""
                                   :args []
                                   ;; :env '(("GOPATH" . "${home}/go"))
                                   :envFile nil
                                   :dlvToolPath "dlv")) ;; Ensure `dlv` is in PATH

;; Core gptel setup with multiple Ollama models
(use-package! gptel
  :ensure t
  :init
  (setq gptel-default-mode 'org-mode)
  :config
  ;; Main Ollama backend with all models
  (setq gptel-backend
        (gptel-make-ollama "Ollama"
          :host "localhost:11434"
          :stream t
          :models '(deepseek-r1:latest
                    qwen3:latest
                    llama3.2:latest
                    gemma3:latest
                    gpt-oss:latest
                    nomic-embed-text:latest)))

  ;; Model presets for different use cases
  (defvar my/ollama-presets
    '((:name "deepseek-r1"  :model "deepseek-r1:latest"  :temp 0.1 :max 4096 :use-case "Hard reasoning, multi-file refactors, complex analysis")
      (:name "qwen3"        :model "qwen3:latest"        :temp 0.2 :max 2048 :use-case "General coding assistant, Go/Clojure/TypeScript")
      (:name "llama3.2"     :model "llama3.2:latest"     :temp 0.3 :max 1536 :use-case "Quick drafts, low latency interactions")
      (:name "gemma3"       :model "gemma3:latest"       :temp 0.5 :max 2048 :use-case "Summarization, documentation polish")
      (:name "gpt-oss"      :model "gpt-oss:latest"      :temp 0.3 :max 2048 :use-case "Fallback generalist, agentic tasks"))
    "Model presets with their optimal configurations and use cases.")

  (defun my/gptel-apply-preset (preset)
    "Apply PRESET plist to gptel for this buffer."
    (interactive
     (list (let* ((names (mapcar (lambda (p) 
                                   (format "%s - %s" 
                                           (plist-get p :name)
                                           (plist-get p :use-case))) 
                                 my/ollama-presets))
                  (choice (completing-read "Model: " names nil t))
                  (name (car (split-string choice " - "))))
             (seq-find (lambda (p) (equal (plist-get p :name) name)) my/ollama-presets))))
    (let* ((model (plist-get preset :model))
           (temp  (or (plist-get preset :temp) 0.2))
           (max   (or (plist-get preset :max) 1024)))
      (setq-local gptel-model model
                  gptel-temperature temp
                  gptel-max-tokens max)
      (message "gptel → %s (T=%.1f, max=%d)" model temp max)))

  (defun my/gptel-route ()
    "Heuristic model routing based on region/buffer content and major-mode."
    (interactive)
    (let* ((text (if (use-region-p)
                     (buffer-substring-no-properties (region-beginning) (region-end))
                   (buffer-substring-no-properties (point-min) (min (point-max) (+ (point-min) 2000)))))
           (len (length text))
           (lang (symbol-name major-mode))
           (pick (cond
                  ;; Heavy reasoning or long prompts
                  ((or (> len 1500)
                       (string-match-p "\\b(refactor|rewrite|test|architecture|explain.*step|analyze|debug)" text))
                   "deepseek-r1")
                  ;; Code modes for languages you use frequently
                  ((string-match-p "\\b(go-mode\\|go-ts-mode\\|clojure-mode\\|clojurescript-mode\\|typescript-\\|tsx-\\|js-\\|web-mode\\|elm-mode)" lang)
                   "qwen3")
                  ;; Summarization and documentation tasks
                  ((string-match-p "\\b(summarize\\|summary\\|bullets?\\|title\\|abstract\\|tl;?dr\\|polish\\|rewrite)" text)
                   "gemma3")
                  ;; Low-latency default for quick interactions
                  (t "llama3.2"))))
      (let ((preset (seq-find (lambda (p) (equal (plist-get p :name) pick)) my/ollama-presets)))
        (my/gptel-apply-preset preset)
        (message "Auto-routed to %s: %s" pick (plist-get preset :use-case)))))

  ;; Keybindings for gptel mode
  (define-key gptel-mode-map (kbd "C-c m r") #'my/gptel-route)
  (define-key gptel-mode-map (kbd "C-c m s") #'my/gptel-apply-preset))

;; Transient menu for easy model selection
(use-package! transient
  :ensure t
  :config
  (transient-define-prefix my/llm-menu ()
    "LLM Model Selection and Actions"
    ["Models (Ollama)"
     ("d" "DeepSeek-R1 (reasoning)" 
      (lambda () (interactive) 
        (my/gptel-apply-preset (seq-find (lambda (p) (equal (plist-get p :name) "deepseek-r1")) my/ollama-presets))))
     ("q" "Qwen3 (coding)" 
      (lambda () (interactive) 
        (my/gptel-apply-preset (seq-find (lambda (p) (equal (plist-get p :name) "qwen3")) my/ollama-presets))))
     ("l" "Llama3.2 (quick)" 
      (lambda () (interactive) 
        (my/gptel-apply-preset (seq-find (lambda (p) (equal (plist-get p :name) "llama3.2")) my/ollama-presets))))
     ("g" "Gemma3 (docs)" 
      (lambda () (interactive) 
        (my/gptel-apply-preset (seq-find (lambda (p) (equal (plist-get p :name) "gemma3")) my/ollama-presets))))
     ("o" "GPT-OSS (agentic)" 
      (lambda () (interactive) 
        (my/gptel-apply-preset (seq-find (lambda (p) (equal (plist-get p :name) "gpt-oss")) my/ollama-presets))))]
    ["Actions"
     ("r" "Auto Route" my/gptel-route)
     ("s" "Select Model" my/gptel-apply-preset)
     ("RET" "Send Message" gptel-send)
     ("c" "New Chat" gptel)]))

;; Global keybinding for the LLM menu
(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("ai" . "LLM/AI")
        :desc "LLM Menu" "m" #'my/llm-menu
        :desc "Quick Chat" "c" #'gptel
        :desc "Auto Route Model" "r" #'my/gptel-route
        :desc "Select Model" "s" #'my/gptel-apply-preset
        :desc "Aidermacs (Pair Programming)" "a" #'aidermacs-transient-menu)))

(use-package! llm)

(use-package! ellama
  :bind ("C-c e" . ellama-transient-main-menu)
  :init
  ;; language you want ellama to translate to
  (setopt ellama-language "Brazilian Portuguese")
  ;; use the ollama provider from llm
  (require 'llm-ollama)
  
  ;; Default provider - use llama3.2 for general tasks (fast)
  (setopt ellama-provider
          (make-llm-ollama
           :chat-model "llama3.2:latest"
           :embedding-model "nomic-embed-text:latest"
           :default-chat-non-standard-params '(("num_ctx" . 8192))))
  
  ;; Summarization - use gemma3 for document processing
  (setopt ellama-summarization-provider
          (make-llm-ollama
           :chat-model "gemma3:latest"
           :embedding-model "nomic-embed-text:latest"
           :default-chat-non-standard-params '(("num_ctx" . 16384))))
  
  ;; Coding - use qwen3 for code-related tasks
  (setopt ellama-coding-provider
          (make-llm-ollama
           :chat-model "qwen3:latest"
           :embedding-model "nomic-embed-text:latest"
           :default-chat-non-standard-params '(("num_ctx" . 16384))))
  
  ;; Predefined llm providers for interactive switching
  (setopt ellama-providers
          '(("deepseek-r1" . (make-llm-ollama
                              :chat-model "deepseek-r1:latest"
                              :embedding-model "nomic-embed-text:latest"
                              :default-chat-non-standard-params '(("num_ctx" . 32768))))
            ("qwen3" . (make-llm-ollama
                        :chat-model "qwen3:latest"
                        :embedding-model "nomic-embed-text:latest"
                        :default-chat-non-standard-params '(("num_ctx" . 16384))))
            ("llama3.2" . (make-llm-ollama
                           :chat-model "llama3.2:latest"
                           :embedding-model "nomic-embed-text:latest"
                           :default-chat-non-standard-params '(("num_ctx" . 8192))))
            ("gemma3" . (make-llm-ollama
                         :chat-model "gemma3:latest"
                         :embedding-model "nomic-embed-text:latest"
                         :default-chat-non-standard-params '(("num_ctx" . 16384))))
            ("gpt-oss" . (make-llm-ollama
                          :chat-model "gpt-oss:latest"
                          :embedding-model "nomic-embed-text:latest"
                          :default-chat-non-standard-params '(("num_ctx" . 16384))))))
  
  ;; Naming new sessions - use llama3.2 for quick naming
  (setopt ellama-naming-provider
          (make-llm-ollama
           :chat-model "llama3.2:latest"
           :embedding-model "nomic-embed-text:latest"
           :default-chat-non-standard-params '(("stop" . ("\n")) ("num_ctx" . 4096))))
  (setopt ellama-naming-scheme 'ellama-generate-name-by-llm)
  
  ;; Translation - use gemma3 for language tasks
  (setopt ellama-translation-provider
          (make-llm-ollama
           :chat-model "gemma3:latest"
           :embedding-model "nomic-embed-text:latest"
           :default-chat-non-standard-params '(("num_ctx" . 16384))))
  
  ;; Extraction - use deepseek-r1 for complex analysis
  (setopt ellama-extraction-provider
          (make-llm-ollama
           :chat-model "deepseek-r1:latest"
           :embedding-model "nomic-embed-text:latest"
           :default-chat-non-standard-params '(("num_ctx" . 32768))))
  
  ;; customize display buffer behaviour
  (setopt ellama-chat-display-action-function #'display-buffer-full-frame)
  (setopt ellama-instant-display-action-function #'display-buffer-at-bottom)
  :config
  ;; send last message in chat buffer with C-c C-c
  (add-hook 'org-ctrl-c-ctrl-c-hook #'ellama-chat-send-last-message))

;; Add ellama to the LLM menu
(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("ai" . "LLM/AI")
        :desc "Ellama Menu" "e" #'ellama-transient-main-menu
        :desc "Ellama Chat" "E" #'ellama-chat
        :desc "Aidermacs Menu" "A" #'aidermacs-transient-menu)))

(use-package! elysium)

(use-package! org-ai
  :commands (org-ai-mode)
  :init
  (add-hook 'org-mode-hook #'org-ai-mode)
  :config
  (setq org-ai-default-chat-model "gpt-4o"))

;; Load hive-mcp AI bridge and addons
(when (locate-library "hive-mcp-ai-bridge")
  (require 'hive-mcp-ai-bridge)

  ;; gptel integration - inject memory context, store notable responses
  (when (locate-library "hive-mcp-gptel")
    (require 'hive-mcp-gptel)
    (hive-mcp-gptel-mode 1)))

(use-package aider
  :config
  ;; For latest claude sonnet model
  ;; (setq aider-args '("--model" "sonnet" "--no-auto-accept-architect"))
  ;; (setenv "ANTHROPIC_API_KEY" anthropic-api-key)
  ;; Or chatgpt model
  ;; (setq aider-args '("--model" "o4-mini"))
  ;; (setenv "OPENAI_API_KEY" <your-openai-api-key>)
  ;; Or use your personal config file
  ;; (setq aider-args `("--config" ,(expand-file-name "~/.aider.conf.yml")))
  ;; ;;
  ;; Optional: Set a key binding for the transient menu
  (global-set-key (kbd "C-c a") 'aider-transient-menu) ;; for wider screen
  ;; or use aider-transient-menu-2cols / aider-transient-menu-1col, for narrow screen
  (aider-magit-setup-transients)) ;; add aider magit function to magit menu

(use-package! aidermacs
  :init
  ;; Set the OpenRouter API key from pass BEFORE loading
  (setenv "OPENROUTER_API_KEY" (nth 0 (process-lines "pass" "show" "openrouter/keys/ff")))
  
  :custom
  ;; Configure the default model - nousresearch/deephermes-3-llama-3-8b-preview:free
  (aidermacs-default-chat-mode 'architect)
  
  :config
  ;; Configure the model and provider
  (setq aidermacs-model "openrouter/nousresearch/deephermes-3-llama-3-8b-preview:free")
  (setq aidermacs-provider "openrouter")
  
  ;; Additional configuration options - specify the model explicitly in extra args
  (setq aidermacs-extra-args
        (list "--model" "openrouter/nousresearch/deephermes-3-llama-3-8b-preview:free"
              "--no-auto-commits"  ; Disable auto-commits for more control
              "--no-pretty"        ; Disable pretty formatting for cleaner output
              "--chat-language" "en" ; Set chat language to English
              "--no-show-model-warnings")) ; Suppress model warnings

  ;; Configure terminal backend (vterm is recommended for better performance)
  (setq aidermacs-backend 'vterm)

  ;; Enable automatic model discovery for OpenRouter
  (setq aidermacs-auto-discover-models t)

  ;; Set up keybindings
  (global-set-key (kbd "C-c A") 'aidermacs-transient-menu)
  
  ;; Create a default .aider.conf.yml file if it doesn't exist
  (let ((aider-config-file (expand-file-name "~/.aider.conf.yml")))
    (unless (file-exists-p aider-config-file)
      (with-temp-file aider-config-file
        (insert "# Aidermacs default configuration\n")
        (insert "model: openrouter/nousresearch/deephermes-3-llama-3-8b-preview:free\n")
        (insert "no-auto-commits: true\n")
        (insert "no-pretty: true\n")
        (insert "chat-language: en\n")
        (insert "no-show-model-warnings: true\n")
        (insert "architect: true\n")))))

;; Keybindings (set up immediately, autoload handles lazy loading)
(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("ai" . "LLM/AI")
        :desc "Claude Code" "C" #'claude-code
        :desc "Claude Continue" "x" #'claude-code-continue
        :desc "Claude Resume" "R" #'claude-code-resume
        :desc "Claude Menu" "M" #'claude-code-transient
        :desc "Send Region to Claude" "S" #'claude-code-send-region
        :desc "Fix Error with Claude" "F" #'claude-code-fix-error-at-point)))

;; Global keybinding for quick access
(global-set-key (kbd "C-c C") #'claude-code-transient)

;; Configure claude-code after it loads
(after! claude-code
  ;; Use eat as the terminal backend (default, more modern)
  (setq claude-code-terminal-backend 'eat)
  ;; Enable notifications when Claude needs attention
  (setq claude-code-enable-notifications t)
  ;; Ask before killing Claude sessions
  (setq claude-code-confirm-kill t)
  ;; RET sends, Shift-RET for newlines (default)
  (setq claude-code-newline-keybinding-style 'newline-on-shift-return)

  ;; ============================================================
  ;; Evil-compatible keybindings for seamless editing experience
  ;; ============================================================

  ;; Timer for jk escape sequence
  (defvar claude-code--jk-timer nil)
  (defvar claude-code--j-pressed nil)

  (defun claude-code--handle-j ()
    "Handle 'j' press for jk escape sequence."
    (interactive)
    (setq claude-code--j-pressed t)
    ;; Send j to terminal
    (claude-code--term-send-string claude-code-terminal-backend "j")
    ;; Set timer to clear j-pressed flag
    (when claude-code--jk-timer (cancel-timer claude-code--jk-timer))
    (setq claude-code--jk-timer
          (run-at-time 0.3 nil
                       (lambda () (setq claude-code--j-pressed nil)))))

  (defun claude-code--handle-k ()
    "Handle 'k' press - toggle read-only if j was pressed recently."
    (interactive)
    (if claude-code--j-pressed
        (progn
          ;; Delete the 'j' we already sent
          (claude-code--term-send-string claude-code-terminal-backend "\177") ; backspace
          (setq claude-code--j-pressed nil)
          (when claude-code--jk-timer (cancel-timer claude-code--jk-timer))
          (claude-code-toggle-read-only-mode))
      ;; Normal k press
      (claude-code--term-send-string claude-code-terminal-backend "k")))

  ;; Override keymap setup to add our Evil-friendly bindings
  (defun claude-code--setup-evil-friendly-keymap ()
    "Add Evil-friendly keybindings to claude-code buffer."
    (when (derived-mode-p 'eat-mode)
      (let ((map (current-local-map)))
        ;; jk escape sequence
        (define-key map (kbd "j") #'claude-code--handle-j)
        (define-key map (kbd "k") #'claude-code--handle-k)
        ;; C-z as alternative toggle (doesn't conflict with terminal)
        (define-key map (kbd "C-z") #'claude-code-toggle-read-only-mode)
        ;; Double-tap C-g for keyboard-quit (first one sends ESC)
        (define-key map (kbd "C-c C-g") #'keyboard-quit))))

  ;; Hook into claude buffer creation
  (add-hook 'claude-code-mode-hook #'claude-code--setup-evil-friendly-keymap)

  ;; When in read-only mode, make ESC return to interactive mode
  (defun claude-code--evil-escape-handler ()
    "Return to interactive mode when pressing ESC in read-only mode."
    (interactive)
    (when (and (claude-code--buffer-p (current-buffer))
               (claude-code--term-in-read-only-p claude-code-terminal-backend))
      (claude-code-exit-read-only-mode)))

  ;; Add to evil-escape-functions for Doom integration
  (after! evil
    (add-hook 'evil-normal-state-entry-hook
              (lambda ()
                (when (and (claude-code--buffer-p (current-buffer))
                           (boundp 'eat--semi-char-mode)
                           (not eat--semi-char-mode)) ; in read-only/emacs mode
                  ;; We're in read-only mode in a Claude buffer
                  ;; ESC exits read-only mode
                  (local-set-key [escape]
                                 (lambda () (interactive)
                                   (claude-code-exit-read-only-mode))))))))

(server-force-delete)
(server-start)
