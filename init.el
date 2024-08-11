;; My Emacs configuration
;; Author: Raphael Jorge Ortolan <raphael.ortolan@protonmail.com>

(setq inhibit-startup-message t)

(tool-bar-mode -1)   ;; Disable tool bar
(menu-bar-mode -1)   ;; Disable menu bar
(tooltip-mode -1)    ;; Disable tooltips
(scroll-bar-mode -1) ;; Disable scroll bar

;; Numbers
(global-display-line-numbers-mode t)

;; Performance Settings
(setq read-process-output-max (* 10 1024 1024)) ;; 10mb
(setq gc-cons-threshold 200000000)


;; Font configuration
(set-face-attribute 'default nil :font "Iosevka Comfy Motion" :height 120)

(load-theme 'modus-vivendi)

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package vertico
  :ensure t
  :config
  (setq vertico-cycle t)
  :init
  (vertico-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :init
  (marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)))


;; Consult configurationn
(use-package consult
  :ensure t
  :bind (
	 ("M-s M-g" . consult-grep)
	 ("M-s M-f" . consult-find)
	 ("M-s M-o" . consult-outline)
	 ("M-s M-l" . consult-line)
	 ("M-s M-t" . consult-theme)
	 ("M-s M-b" . consult-buffer)))


;; Why not?? :3
(use-package nyan-mode
  :ensure t
  :init
  (nyan-mode))

(use-package nerd-icons
  :ensure t)

;; Doom modeline 

(use-package doom-modeline
  :ensure t
  :custom
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35)
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-time-icon t)
  (setq doom-modeline-time t)
  (setq doom-modeline-env-version t)
  (setq doom-modeline-battery t))

;; Doom themes

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-rouge t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; Corfu

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

;; Corfu icons

(use-package nerd-icons-corfu
  :ensure t)

(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)

;; Org config

(use-package org
  :ensure t
  :config
  (setq org-ellipsis " ¬"
	org-hide-emphasis-markers t))

(use-package org-modern
  :ensure t)

;; Shell configuration

(use-package eat
  :ensure t)

(use-package vterm
    :ensure t)

;; Paredit

(use-package paredit
  :ensure t)

;; LSP and languages configuration

(use-package tuareg
  :ensure t)

(use-package lsp-mode
  :commands
  (lsp lsp-deferred)

  :hook
  (tuareg-mode . lsp)

  :custom
  (lsp-keymap-prefix "C-c l")           ; Prefix for LSP actions
  (lsp-completion-provider :none)       ; Using Corfu as the provider
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)                      ; IMPORTANT! Use only for debugging! Drastically affects performance
  (lsp-keep-workspace-alive nil)        ; Close LSP server if all project buffers are closed
  (lsp-idle-delay 0.5)                  ; Debounce timer for `after-change-function'

  ;; completion
  (lsp-completion-enable t)
  (lsp-completion-enable-additional-text-edit t) ; Ex: auto-insert an import for a completion candidate
  (lsp-enable-snippet t)                         ; Important to provide full JSX completion
  (lsp-completion-show-kind t)                   ; Optional
 
  :init
  (setq lsp-use-plists t)
 
  :config
  (with-eval-after-load 'lsp-mode 
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection '("opam" "exec" "--" "ocamllsp"))
      :major-modes '(caml-mode tuareg-mode reason-mode)
      :server-id 'ocamllsp)))
 
  :preface
  (defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
     (when (equal (following-char) ?#)
       (let ((bytecode (read (current-buffer))))
	 (when (byte-code-function-p bytecode)
	   (funcall bytecode))))
     (apply old-fn args)))

  (advice-add (if (progn (require 'json)
			 (fboundp 'json-parse-buffer))
		  'json-parse-buffer
		'json-read)
	      :around
	      #'lsp-booster--advice-json-parse)

  (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?)                             ;; for check lsp-server-present?
	       (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
	       lsp-use-plists
	       (not (functionp 'json-rpc-connection))  ;; native json-rpc
	       (executable-find "emacs-lsp-booster"))
	  (progn
	    (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
	      (setcar orig-result command-from-exec-path))
	    (message "Using emacs-lsp-booster for %s!" orig-result)
	    (cons "emacs-lsp-booster" orig-result))
	orig-result)))

  (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command))

;; LSP ui
(use-package lsp-ui
  :commands lsp-ui-mode)

;; Magit
(use-package magit
  :ensure t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit tuareg lsp-ui lsp-mode paredit vterm org-modern nerd-icons-corfu corfu doom-themes doom-modeline nerd-icons all-the-icons nyan-mode orderless consult marginalia vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
