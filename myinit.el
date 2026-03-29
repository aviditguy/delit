(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)  ;; auto-install packages





;; UI Settings
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq ring-bell-function 'ignore)

;; Line Numbers
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Other Useful settings
(ido-mode 1)
(ido-everywhere 1)
(show-paren-mode 1)
(save-place-mode 1)          ;; Remember cursor positions in files
(global-auto-revert-mode 1)  ;; if file changes on disk reload its buffer

;; Handle temporary files
(setq auto-save-default nil)   ;; Disable auto-saving
(setq make-backup-files nil)   ;; Disable backup~ files
(setq create-lockfiles nil)    ;; Disable .#lock files

;; Something Performace Wise via ChatGPT
(setq gc-cons-threshold (* 50 1000 1000))
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 2 1000 1000))))

;; Set Font
(set-face-attribute 'default nil :font "Iosevka Light Extended" :height 110)


;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; ORG-MODE SETUP
;; ────────────────────────────────────────────────────────────────────────────────────────────────────
(setq org-hide-emphasis-markers t)
(setq org-startup-folded 'overview)
(setq org-confirm-babel-evaluate nil)

(setq org-src-window-setup 'current-window)
(setq org-src-preserve-indentation t)
(setq org-edit-src-content-indentation 0)
(setq org-ellipsis " ▼ ")

(setq org-indent-indentation-per-level 3)
(add-hook 'org-mode-hook 'org-indent-mode)

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom
  ;; Headings & Lists
  (org-modern-star '("◉" "○" "◆" "◇" "▶" "▷"))
  (org-modern-list '((?- . "•") (?+ . "‣") (?* . "⁃")))
  ;; Checkboxes
  (org-modern-checkbox
   '((?X . "🟩") (?- . "▢") (?\s . "⬜")))
  ;; Tables & blocks
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 1)
  (org-modern-block-fringe 4)
  (org-modern-block-name t)
  (org-modern-block-border t)
  ;; Tags & todo keywords
  (org-modern-todo t)
  (org-modern-tag t))

(require 'org-tempo)
(setq org-structure-template-alist
      '(("c"      . "src c")
        ("el"     . "src emacs-lisp")
	("lisp"   . "src lisp")))

(with-eval-after-load 'org
  (add-to-list 'org-file-apps '("\\.png\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.jpg\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.jpeg\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.gif\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.webp\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.svg\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.mp4\\'" . "mpv %s")))


;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; THEME SETUP
;; ────────────────────────────────────────────────────────────────────────────────────────────────────
(use-package doom-themes
  :config
  (load-theme 'doom-1337 t))


;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; SLY SETUP
;; ────────────────────────────────────────────────────────────────────────────────────────────────────
(use-package sly
  :init
  (setq inferior-lisp-program "sbcl")
  :config
  (sly-setup '(sly-fancy)))


(defun my/indicate (beg end)
  (pulse-momentary-highlight-region beg end))

(defun my/lang-context-p (mode language)
  (or
   (derived-mode-p mode)
   (and (derived-mode-p 'org-mode)
	(org-in-src-block-p)
	(string=
	 (org-element-property :language (org-element-context))
	 language))))

(defun my/get-last-expression-lisp ()
  (with-syntax-table emacs-lisp-mode-syntax-table
    (thing-at-point 'sexp t)))

(defun my/eval-last-expression-lisp ()
  (let ((expr (my/get-last-expression-lisp)))
    (if (string-prefix-p "(defun " expr)
	(sly-eval-last-expression)
      (if-let ((buf (get-buffer "*sly-mrepl for sbcl*")))
	  (with-current-buffer buf
	    (goto-char (point-max))
	    (insert expr)
	    (sly-mrepl-return))
	(message "SLY REPL not running")))))

(defun my/eval-last-expression ()
  (interactive)
  (cond
   ((my/lang-context-p 'lisp-mode "lisp")
    (my/eval-last-expression-lisp))

   (t
    (message "context not supported"))))


(global-set-key (kbd "C-M-e") #'my/eval-last-expression)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("fffef514346b2a43900e1c7ea2bc7d84cbdd4aa66c1b51946aade4b8d343b55a"
     default)))
