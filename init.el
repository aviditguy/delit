(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)  ;; auto-install packages

;; Doom themes
(use-package doom-themes)
(load-theme 'doom-material-dark t)




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
(set-face-attribute 'default nil :font "Iosevka ExtraLight Extended" :height 115)




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

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit default :weight normal :height 1.5))))
 '(org-level-2 ((t (:inherit default :height 1.4))))
 '(org-level-3 ((t (:inherit default :height 1.3))))
 '(org-level-4 ((t (:inherit default :height 1.2))))
 '(org-level-5 ((t (:inherit default :height 1.1))))
 '(org-level-6 ((t (:inherit default :height 1.1))))
 '(org-level-7 ((t (:inherit default :height 1.1))))
 '(org-level-8 ((t (:inherit default :height 1.1)))))

(require 'org-tempo)
(setq org-structure-template-alist
      '(("c"      . "src c")
	("py"     . "src python")
        ("sh"     . "src shell")
        ("js"     . "src js")
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
;; CONFIG STATE & HELPERS
;; ────────────────────────────────────────────────────────────────────────────────────────────────────

(defvar my/config
  '(:term-name "*my-terminal*"
	       :term-below t
	       :python-cmd "python %f"))


;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; TERMINAL TOGGLE SYSTEM
;; ────────────────────────────────────────────────────────────────────────────────────────────────────

(defun my/terminal-visible-p ()
  "Checks if terminal buffer is visible in window. window or nil"
  (get-buffer-window (plist-get my/config :term-name)))

(defun my/terminal-focused-p ()
  "Checks if point is on terminal. t or nil"
  (eq (selected-window) (my/terminal-visible-p)))

(defun my/create-terminal ()
  "Creates a terminal buffer ansi-term"
  (unless (get-buffer (plist-get my/config :term-name))
    (save-window-excursion
      (let ((buf (ansi-term (getenv "SHELL"))))
	(with-current-buffer buf
	  (rename-buffer (plist-get my/config :term-name)))))))

(defun my/show-terminal (&optional switch)
  "Show terminal in split window below or right
If terminal buffer not created then first create it"
  (my/create-terminal)

  (let ((win (my/terminal-visible-p)))
    (unless win
      (setf win (if (plist-get my/config :term-below)
		    (split-window nil -15 'below)
		  (split-window nil -100 'right)))
      (set-window-buffer win (get-buffer (plist-get my/config :term-name))))
    (when switch (select-window win))))

(defun my/hide-terminal ()
  "Hides terminal if terminal is focused"
  (if (my/terminal-focused-p)
      (delete-window (get-buffer-window (plist-get my/config :term-name)))))

(defun my/toggle-terminal ()
  "Toggles terminal"
  (interactive)
  (if (my/terminal-focused-p)
      (my/hide-terminal)
    (my/show-terminal t)))

(defun my/move-terminal ()
  "Moves terminal between below <-> right"
  (interactive)

  (setf my/config
	(plist-put my/config :term-below
		   (not (plist-get my/config :term-below))))

  (when (my/terminal-visible-p)
    (my/hide-terminal))
  (my/show-terminal t))

(defun my/term-send-command (command)
  "Send COMMAND to ansi-term BUFFER-NAME."
  (my/show-terminal)
  (with-current-buffer (get-buffer (plist-get my/config :term-name))
    (goto-char (point-max))
    (term-send-raw-string (concat command "\n"))))




;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; EVAL LAST EXPRESSION
;; ────────────────────────────────────────────────────────────────────────────────────────────────────

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


(setq python-indent-guess-indent-offset nil)

(defun my/get-last-expression-python ()
  (let ((end (point)))
    (save-excursion
      (if (org-in-src-block-p)
	  (org-babel-do-in-edit-buffer
	   (python-nav-beginning-of-statement))
	(python-nav-beginning-of-statement))
      (my/indicate (point) end)
      (string-trim
       (buffer-substring-no-properties (point) end)))))
  

(defun my/eval-last-expression ()
  (interactive)
  (cond
   ((my/lang-context-p 'python-mode "python")
    (my/term-send-command (my/get-last-expression-python)))

   (t
    (message "context not supported"))))




;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; RUN ORG CODE BLOCKS
;; ────────────────────────────────────────────────────────────────────────────────────────────────────


(defun my/org-src-block-p ()
  (when (derived-mode-p 'org-mode)
    (let ((el (org-element-context)))
      (when (eq (org-element-type el) 'src-block)
	el))))


(defun my/create-file (path lang content)
  (let* ((ext (my/get-lang-extension lang))
	 (file (if path path (make-temp-file "my-" nil ext))))
    (when (and path (file-name-directory path))
      (make-directory (file-name-directory path) t))
    (with-temp-file file (insert content))
    file))


(defun my/get-lang-extension (lang)
  (cond
   ((string= lang "python") ".py")
   (t                       nil)))


(defun my/build-lang-command (file lang libs)
  (let ((cmd (plist-get my/config
			(intern (format ":%s-cmd" lang)))))
    (when cmd
      (let ((cmd1 (replace-regexp-in-string "%f" file cmd t t)))
	(if libs
	    (replace-regexp-in-string "&&" (concat libs " &&") cmd1 t t)
	  cmd1)))))


(defun my/extract-org-src-block ()
  (when-let ((el (my/org-src-block-p)))

    (let ((header (org-babel-parse-header-arguments
		   (org-element-property :parameters el))))

      (list
       :lang  (org-element-property :language el)
       :body  (org-element-property :value el)
       :path  (alist-get :path header)
       :libs  (alist-get :libs header)))))


(defun my/run-org-src-block ()
  (interactive)
  (let ((data (my/extract-org-src-block)))

    (let ((lang    (plist-get data :lang))
	  (path    (plist-get data :path))
	  (content (plist-get data :body))
	  (libs    (plist-get data :libs)))

      (let* ((file (my/create-file path lang content))
	     (cmd  (my/build-lang-command file lang libs)))

	(unless cmd
	  (error "No command for language %s" lang))

	(my/term-send-command cmd)))))


;; ────────────────────────────────────────────────────────────────────────────────────────────────────
;; KEYBINDINGS
;; ────────────────────────────────────────────────────────────────────────────────────────────────────

(global-set-key (kbd "C-`") #'my/toggle-terminal)
(global-set-key (kbd "C-M-`") #'my/move-terminal)

(global-set-key (kbd "C-M-e") #'my/eval-last-expression)

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-<return>")
	      #'my/run-org-src-block))
