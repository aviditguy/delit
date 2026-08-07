;; --------------------------------------------------------------------------------
;; PACKAGE-SYSTEN INITIALIZATION
;; --------------------------------------------------------------------------------
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)  ;; auto-install packages


;; --------------------------------------------------------------------------------
;; BASIC SETUP
;; --------------------------------------------------------------------------------
;; UI Settings
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq ring-bell-function 'ignore)

;; Line Numbers
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Disable Line Numbers for certain modes
(dolist (mode '(org-mode-hook
		vterm-mode-hook
		pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode -1))))

;; Other Useful settings
(require 'ido)
(ido-mode 1)
(ido-everywhere 1)
(show-paren-mode 1)
(save-place-mode 1)          ;; Remember cursor positions in files
(global-auto-revert-mode 1)  ;; if file changes on disk reload its buffer

(setq auto-save-default nil)   ;; Disable auto-saving
(setq make-backup-files nil)   ;; Disable backup~ files
(setq create-lockfiles nil)     ;; Disable .#lock files

;; Something Performace Wise via ChatGPT
(setq gc-cons-threshold (* 50 1000 1000))
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 2 1000 1000))))

;; Set Font
(set-face-attribute 'default nil :font "Hasklug Nerd Font Light" :height 120)


;; --------------------------------------------------------------------------------
;; ORG-MODE SETUP
;; --------------------------------------------------------------------------------
(require 'org)
(require 'org-tempo)

(use-package visual-fill-column)

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

(setq org-hide-emphasis-markers t)
(setq org-startup-folded 'overview)
(setq org-confirm-babel-evaluate nil)

(setq org-src-window-setup 'current-window)
(setq org-src-preserve-indentation t)
(setq org-edit-src-content-indentation 0)
(setq org-ellipsis " ▼ ")

(setq org-indent-indentation-per-level 3)

(defun my/org-visual-setup ()
  (setf visual-fill-column-width 110
	visual-fill-column-center-text t)
  (visual-fill-column-mode 1)
  (visual-line-mode 1))

(add-hook 'org-mode-hook 'my/org-visual-setup)
(add-hook 'org-mode-hook 'org-indent-mode)

(setq org-structure-template-alist
      '(("c"      . "src C")
        ("cpp"    . "src cpp")
        ("py"     . "src python")
        ("sh"     . "src shell")
	("awk"    . "src awk")
        ("js"     . "src js")
        ("el"     . "src emacs-lisp")
	("lisp"   . "src lisp")))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)))

(with-eval-after-load 'org
  (dolist (face '(org-level-1 org-level-2 org-level-3 org-level-4
			      org-level-5 org-level-6 org-level-7 org-level-8))
    (set-face-attribute face nil :weight 'bold :height 1.1))

  (add-to-list 'org-file-apps '("\\.png\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.jpg\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.jpeg\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.gif\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.webp\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.svg\\'" . "feh %s"))
  (add-to-list 'org-file-apps '("\\.mp4\\'" . "mpv %s")))


;; --------------------------------------------------------------------------------
;; THEME SETUP
;; --------------------------------------------------------------------------------
(use-package doom-themes)

(defvar *my-themes*
  '(default
    doom-material-dark
    doom-1337
    doom-acario-dark
    doom-ir-black))

(defvar *my-theme-index* 0)

(defvar *my-theme-state-file* "~/.emacs.d/theme-state.el")

(defun my-load-theme (index)
  (let* ((len   (length *my-themes*))
	 (idx   (mod index len))
	 (theme (nth idx *my-themes*)))

    (mapc #'disable-theme custom-enabled-themes)
    (unless (eq theme 'default)
      (load-theme theme t))
    (setf *my-theme-index* idx)
    (message "Theme Loaded: %s" theme)))

(defun my-cycle-themes ()
  (interactive)
  (my-load-theme (1+ *my-theme-index*)))

(global-set-key (kbd "<f5>") #'my-cycle-themes)


(add-hook 'kill-emacs-hook
	  (lambda ()
		 (with-temp-file *my-theme-state-file*
		   (insert (format "(setf *my-theme-index* %d)" *my-theme-index*)))))

(when (file-exists-p *my-theme-state-file*)
  (load-file *my-theme-state-file*))

(my-load-theme *my-theme-index*)





(use-package vterm)

(defvar *my-vterm-below* t)

(defconst *my-vterm-min-width-for-right* 180)

(defun my-vterm-show (&optional switch)
  (save-window-excursion
    (vterm))

  (let ((win (get-buffer-window "*vterm*")))
    (unless win
      (when (< (frame-width) *my-vterm-min-width-for-right*)
	(setf *my-vterm-below* t))
      
      (setf win (if *my-vterm-below*
		    (split-window nil -15 'below)
		  (split-window nil -80 'right)))
      (set-window-buffer win "*vterm*"))
    (when switch (select-window win))))

(defun my-vterm-is-focused ()
  (let ((win (get-buffer-window "*vterm*")))
    (if (eq win (selected-window))
	win
      nil)))

(defun my-vterm-hide ()
  (let ((win (my-vterm-is-focused)))
    (when win (delete-window win))))

(defun my-vterm-toggle ()
  (interactive)
  (if (my-vterm-is-focused)
      (my-vterm-hide)
    (my-vterm-show t)))

(global-set-key (kbd "C-`") #'my-vterm-toggle)

(defun my-vterm-move ()
  (interactive)
  (my-vterm-show t)

  (setf my-vterm-below
	(not my-vterm-below))

  (my-vterm-hide)
  (my-vterm-show t))

(global-set-key (kbd "C-M-`") #'my-vterm-move)

(defun my-vterm-send (command)
  (my-vterm-show)
  (with-current-buffer "*vterm*"
    (goto-char (point-max))
    (vterm-send-string command t)
    (vterm-send-return)))






(defun my-lang-context-p (mode lang)
  (or
   (derived-mode-p mode)
   (and (derived-mode-p 'org-mode)
	(org-in-src-block-p)
	(string=
	 (org-element-property :language (org-element-context))
	 lang))))

(defun my-highlight (beg end)
  (pulse-momentary-highlight-region beg end))

(defun my-quotes-balanced-p (expr)
  (let ((single 0)
	(double 0))

    (dotimes (i (length expr))
      (cond
       ((eq (aref expr i) ?')  (setf single (1+ single)))
       ((eq (aref expr i) ?\") (setf double (1+ double)))))

    (and (= (% single 2) 0)
	 (= (% double 2) 0))))

(defun my-eval-last-exp-shell ()
  (interactive)
  (let ((end  (point))
	(expr nil)
	(done nil))

    (save-excursion
      (while (and (not done)
		  (re-search-backward "\n" nil t))
	(setf expr (string-trim
		    (buffer-substring-no-properties
		     (1+ (point)) end)))

	(when (my-quotes-balanced-p expr)
	  (my-highlight (1+ (point)) end)
	  (setf done t))))

    expr))

(defun my-eval-last-exp ()
  (interactive)
  (when (my-lang-context-p 'sh-mode 'shell)
    (my-vterm-send (my-eval-last-exp-shell))))

(global-set-key (kbd "C-M-e") #'my-eval-last-exp)






(defun my-org-src-create-file ()
  (interactive)
  (unless (org-in-src-block-p)
    (user-error "Not inside a source block"))

  (let* ((element (org-element-context))
         (params  (org-babel-parse-header-arguments
                   (org-element-property :parameters element)))
         (file    (cdr (assq :create params)))
         (content (org-element-property :value element)))

    (unless file
      (user-error "No :create header argument"))

    (with-temp-file file
      (insert content))

    (message "Created: %s" file)))


(with-eval-after-load 'org
  (define-key org-mode-map
              (kbd "<C-return>")
              #'my-org-src-create-file))
