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
(setq user-full-name "Pedro Branquinho"
      user-mail-address "pedrogbranquinho@gmail.com")

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
(setq doom-theme 'doom-dark+)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Default face size
(set-face-attribute 'default nil :height 170)

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

(display-time-mode 1)                             ; Enable time in the mode-line

(unless (string-match-p "^Power N/A" (battery))   ; On laptops...
  (display-battery-mode 1))                       ; it's nice to know how much power you have

(global-subword-mode 1)                           ; Iterate through CamelCase words

;; Tecosaur snippet -- end --

(use-package! csv-mode)

;; (use-package! undo-tree)

(load! "./my-func/fast-input-method.el")
(load! "./my-func/org-roam.el")

(use-package! impatient-mode)


;; (use-package! org-roam
;;         :config
;;         (org-roam-directory "~/buddhi-roam")
;;         :bind! (("C-c n l" . org-roam-buffer-toggle
;;                  ("C-c n f" . org-roam-node-find)
;;                  ("C-c n g" . org-roam-graph)
;;                  ("C-c n i" . org-roam-node-insert)))
;;         :config
;;         (org-roam-db-autosyc-mode)
;;         (require 'org-roam-protocol))

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

(load! "./my-func/dashboard.el")

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))

(load! "./my-func/transparency.el")

(use-package! org
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-files
        '("~/PP/Notes/Agenda/Tasks.org"
          "~/PP/Notes/Agenda/Habits.org"
          "~/PP/Notes/Agenda/IMPA.org"
          "~/PP/Notes/Agenda/ProcSel.org"
          "~/PP/Notes/Agenda/University.org"
          "~/PP/Notes/Agenda/Research.org"
          "~/PP/Notes/Agenda/CafeDoBem")))

(load! "./my-func/define-modules.el")

(load! "./my-func/load-modules.el")

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("l" . "load module")
        :desc "Chinese" "c" #'lw/load-chinese
        :desc "LaTeX" "l" #'lw/load-latex)))

;; (use-package! conda
;;   :config
;;   (setq
;;    conda-env-home-directory (expand-file-name "~/.conda/")
;;    conda-env-subdirectory "envs")
;;   (custom-set-variables '(conda-anaconda-home "/opt/anaconda/"))
;;   (conda-env-initialize-interactive-shells)
;;   (conda-env-initialize-eshell)
;;   (conda-env-autoactivate-mode t))

(load! "./my-func/ein-babel.el")

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("f" . "font")
        :desc "New default size" "d" #'lw/defdoom
        :desc "New ch-default size" "c" #'lw/chdoom)))

(map! :leader
      :desc "Yank history" "y" #'consult-yank-from-kill-ring)

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

(use-package! celestial-mode-line
  :config
  (setq calendar-longitude "20.54S")
  (setq calendar-latitude "47.40W")
  (setq calendar-location-name "Franca, SP")
  (defvar celestial-mode-line-phase-representation-alist '((0 . "○") (1 . "☽") (2 . "●") (3 . "☾")))
  (defvar celestial-mode-line-sunrise-sunset-alist '((sunrise . "☀↑ ") (sunset . "☀↓ ")))
  (defvar celestial-mode-line-phase-representation-alist '((0 . "( )") (1 . "|)") (2 . "(o)") (3 . "|)")))
  (defvar celestial-mode-line-sunrise-sunset-alist '((sunrise . "*^") (sunset . "*v")))
  (celestial-mode-line-start-timer))

(defun lw/sunset ()
  (interactive)
  (display-message-or-buffer (message "`%s'" (solar-sunrise-sunset-string (calendar-current-date)))))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Sunrise sunset info" "µ" #'lw/sunset))

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
  (deft-default-extension "org")
  (deft-directory org-roam-directory))

(use-package! pdf-tools)

(setq org-format-latex-options (plist-put org-format-latex-options :scale 3.0))

(use-package! erc-hl-nicks)
(use-package! erc-colorize)

(use-package! erc-twitch
  :config
  (add-hook! erc-twitch-mode-hook #'erc-colorize-enable)
  (add-hook! erc-twitch-mode-hook #'erc-hl-nicks-enable))

(use-package! hidepw)

(use-package! helm-pass)

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Password list" "p" #'helm-pass))

(load! "./my-func/goto.el")

(load! "./my-func/diary.el")

(map! :leader
      (:prefix-map ("b" . "buddhi")
       :desc "Diary entry" "d" #'lw/create-or-access-diary))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("n" . "navigate to")
        :desc "Evil Deeds" "n" #'lw/find-evildeeds)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("n" . "navigate to")
        :desc "Function at point" "f" #'find-function-at-point)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("n" . "navigate to")
        :desc "Emacs.org" "e"  #'lw/goto-emacs-org
        :desc "my-func.org" "F" #'lw/goto-my-func-org)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("n" . "navigate to")
        :desc "Active CS book" "a"  #'lw/goto-cs-active
        :desc "CS books" "c" #'lw/goto-cs-books)))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("n" . "navigate to")
        :desc "Book notes" "n"  #'lw/goto-book-notes)))

(map! :leader
      :desc "Magit" "m" #'magit)

;; (use-package! company-coq)
;; (use-package! coq-commenter)
;; (use-package! proof-general
;;   :config
;;   (add-hook! 'coq-mode-hook #'company-coq-mode)
;;   (add-hook! 'coq-mode-hook #'coq-commenter-mode))

(use-package! elm-mode
  :hook (elm-mode . rainbow-delimiters-mode))

;; (use-package! elm-oracle
;;   :config
;; (with-eval-after-load 'company
;;         (add-to-list 'company-backends 'company-elm))
;; (add-hook 'elm-mode-hook #'elm-oracle-setup-completion)

(use-package! eaf
  :load-path "~/.doom.d/site-lisp/emacs-application-framework"
  :custom
  ; See https://github.com/emacs-eaf/emacs-application-framework/wiki/Customization
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t)
  (browse-url-browser-function 'eaf-open-browser)
  :config
  (defalias 'browse-web #'eaf-open-browser))
  ;; (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
  ;; (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
  ;; (eaf-bind-key take_photo "p" eaf-camera-keybinding)
  ;; (eaf-bind-key nil "M-q" eaf-browser-keybinding)) ;; unbind, see more in the Wiki

(add-to-list 'load-path "~/.doom.d/site-lisp/emacs-application-framework/")

(require 'eaf)
(require 'eaf-browser)

(use-package! conda
  :config
  (setq
   conda-env-home-directory (expand-file-name "~/opt/anaconda2/")
   conda-env-subdirectory "envs/")
  (custom-set-variables '(conda-anaconda-home "/opt/anaconda2/"))
  (conda-env-initialize-interactive-shells)
  (conda-env-initialize-eshell)
  (conda-env-autoactivate-mode t))

(use-package! ewal-doom-themes)
(use-package! doom-themes)
(use-package! doom-modeline-now-playing)
(use-package! doom-modeline)

(use-package! w3m
  :config
  (setq w3m-search-default-engine "duckduckgo"))

(map! :leader
      (:prefix-map ("b" . "buddhi")
       (:prefix ("s" . "search")
        :desc "w3m search" "s" #'w3m-search)))
