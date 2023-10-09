 ;;; azsl-mode.el --- major mode for Amazon Shading language files

;; Copyright (C) 2023 Free Software Foundation, Inc.
;;
;; Author: Xichen Zhou
;; Keywords: languages AZSL shader
;; Version: 1.0

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Major mode for editing azsl grammar files, usually files ending
;; with '(.azsl|.azsli)'.  Is is based on hlsl-mode plus minor features
;; and pre-specified fontifications.
;;; Code:

(eval-when-compile			; required and optional libraries
  (require 'cc-mode)
  (require 'hlsl-mode)
  (require 'find-file)
  (require 'align))


(defgroup azsl nil
  "DirectX Shading Language Major Mode"
  :group 'languages)

(defconst azsl-version "6.3"
  "AZSL major mode version number.") ;;conform to

(defvar azsl-mode-hook nil)

(defvar azsl-mode-menu nil "Menu for AZSL mode")


;; ;;define highlights
(eval-and-compile
  (defvar azsl-type-list hlsl-type-list)
  (defvar azsl-qualifier-list
    (append hlsl-qualifier-list '("ShaderResourceGroup"
				  "ShaderResourceGroupSemantic"
				  "partial")))
  (defvar azsl-keyword-list  hlsl-keyword-list)
  (defvar azsl-reserved-list hlsl-reserved-list)
  (defvar azsl-builtin-list  hlsl-builtin-list)
  (defvar azsl-const-list    hlsl-const-list)
  (defvar azsl-semantics-list
    (append hlsl-semantics-list '("SRG_PerDraw" "SRG_PerObject"
				  "SRG_PerMaterial" "SRG_PerSubPass"
				  "SRG_PerPass" "SRG_PerPass_WithFallback"
				  "SRG_PerView" "SRG_PerScene" "SRG_Bindless"
				  "SRG_RayTracingGlobal" "SRG_RayTracingScene"
				  "SRG_RayTracingMaterial")))
  (defvar azsl-preprocessor-directive-list hlsl-preprocessor-directive-list)
  (defvar azsl-preprocessor-builtin-list hlsl-preprocessor-builtin-list)
  (defvar azsl-mode-syntax-table hlsl-mode-syntax-table)

  ;; aliasing functions
  (defalias 'azsl-pp 'hlsl-pp)
  (defalias 'azsl-ppre 'hlsl-ppre)
  ) ;;eval-and-compile

(regexp-opt azsl-keyword-list)
(defconst azsl-font-lock-keywords-1
  `(
    ;; macros
    (,(azsl-ppre azsl-preprocessor-builtin-list) . font-lock-constant-face)
    (,(format  "^[ \t]*#[ \t]*\\<\\(%s\\)\\>"
	       (regexp-opt azsl-preprocessor-directive-list))
     . font-lock-preprocessor-face)
    ;;#if defined macro
    ("^#[ \t]*\\(elif\\|if\\)\\>"
     ("\\<\\(defined\\)\\>[ \t]*(?\\(\\sw+\\)?" nil nil
      (1 font-lock-preprocessor-face) (2 font-lock-variable-name-face nil t)))
    ;; words
    (,(azsl-ppre azsl-type-list)      . 'font-lock-type-face)
    (,(azsl-ppre azsl-qualifier-list) . 'font-lock-keyword-face)
    (,(azsl-ppre azsl-keyword-list)   . 'font-lock-keyword-face)
    (,(azsl-ppre azsl-reserved-list)  . 'font-lock-keyword-face)
    ;;function name
    ("\\<\\(\\sw+\\) ?(" (1 'font-lock-function-name-face))
    ;;others
    ("SV_[A-Za-z_]+"                  . 'font-lock-variable-name-face)
    (,(azsl-pp azsl-semantics-list)   . 'font-lock-variable-name-face)
    (,(azsl-ppre azsl-const-list)     . 'font-lock-constant-face)
    (,(azsl-ppre azsl-builtin-list)   . 'font-lock-builtin-face)
    )
  "syntax highlight for AZSL"
  )
(defvar azsl-font-lock-keywords azsl-font-lock-keywords-1
  "Default highlighting expressions for AZSL mode")


;;;###autoload
(progn
  (add-to-list 'auto-mode-alist '("\\.azsl\\'" . azsl-mode))
  (add-to-list 'auto-mode-alist '("\\.azsli\\'" . azsl-mode)))

;;;###autoload
(define-derived-mode azsl-mode hlsl-mode "AZSL"
  "major mode for editing AZSL shader files."
  (c-initialize-cc-mode t)
  (setq abbrev-mode t)
  (c-init-language-vars-for 'c-mode)
  (c-common-init 'c-mode)
  (cc-imenu-init cc-imenu-c++-generic-expression)
  (set (make-local-variable 'font-lock-defaults) '(azsl-font-lock-keywords))

  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-padding) "")
  ;; (easy-menu-add hlsl-menu) I think I have menu from hlsl
  (add-to-list 'align-c++-modes 'azsl-mode)
  (c-run-mode-hooks 'c-mode-common-hook)
  (run-mode-hooks 'azsl-mode-hook)
  :after-hook (progn (c-make-noise-macro-regexps)
		     (c-make-macro-with-semi-re)
		     (c-update-modeline))
  )

(provide 'azsl-mode)
