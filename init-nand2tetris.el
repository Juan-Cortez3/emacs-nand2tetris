;; init-nand2tetris.el --- Several major modes for the nand2tetris projects.	-*- lexical-binding: t -*-

;; Copyright (C) 2019 Juan Cortez

;; Author: Juan Cortez <juancortez0128@gmail.com>
;; URL: https://github.com/Juan-Cortez3/dot_emacs_dot_d

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;

;;; Commentary:
;;
;; Perspective:
;; This file provides major modes for languages used in the course nand2tetris:
;;
;; * .hdl  - Hardware description language
;; * .tst  - Test script for simulators in the software suite
;; * .vm   - The intermediate representation used by the VM translator
;; * .jack - The high level language
;;
;; Those languages are not meant for the real world but serve as tools to reveal
;; the computer engineering principles underlying modern computing systems
;;
;; Usage:
;; Currently, this file provides only basic functionalities:
;;
;; 1. Syntax highlighting
;; 2. Indentation
;; 3. Syntax table
;;
;; Just include this file in your init.el file: (require 'init-nand2tetris)

;;; Code:

;;
;; Major mode for hardware description language
;;
(defvar hdl-mode-hook nil)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.hdl\\'" . hdl-mode))

;; Syntax highlighting
(defconst hdl-font-lock-keywords-builtin
  (list
   '("Nand\\|\
And[[:digit:]]*\\(Way\\)*[[:digit:]]*\\|\
Or[[:digit:]]*\\(Way\\)*[[:digit:]]*\\|\
Not[[:digit:]]*\\|\
Xor[[:digit:]]*\\(Way\\)*[[:digit:]]*\\|\
Mux[[:digit:]]*\\(Way\\)*[[:digit:]]*\\|\
DMux[[:digit:]]*\\(Way\\)*[[:digit:]]*\\|\
Add[[:digit:]]*\\|\
ALU\\|\
FullAdder\\|\
HalfAdder\\|\
Inc[[:digit:]]*\\|\
Bit\\|\
A*D*Register\\|\
RAM[[:digit:]]*K*\\|\
ROM[[:digit:]]*K*\\|\
PC\\|\
DFF\\|\
Screen\\|\
Keyboard\\|\
CPU\\|\
Memory" . font-lock-function-name-face))
  "Highlighting expressions for builtin logic gates.")

(defconst hdl-font-lock-keywords-1
  (append hdl-font-lock-keywords-builtin
          (list
           '("\\<CHIP\\|IN\\|OUT\\|PARTS\\|CLOCKED\\|BUILTIN\\>" . font-lock-keyword-face)
           '("true\\|false" . font-lock-constant-face)))
  "Basic highlighting expressions for HDL mode, including keywords and constant.")

(defconst hdl-font-lock-keywords-2
  (append hdl-font-lock-keywords-1
          (list
           '("CHIP[[:blank:]]+\\(\\w*\\)[[:blank:]]+{" 1 font-lock-type-face)
           '("=[[:blank:]]*\\(\\w+\\)[[:blank:]]*\\(,\\|\\;\\|)\\|\\[\\)" 1 font-lock-variable-name-face)
           '("\\(\\[\\)[[:digit:]]+\\.*[[:digit:]]*\\(\\]\\)" 1 font-lock-type-face)
           '("\\(\\[\\)[[:digit:]]+\\.*[[:digit:]]*\\(\\]\\)" 2 font-lock-type-face)))
  "Highlighting expressions for variables.")

(defvar hdl-font-lock-keywords hdl-font-lock-keywords-2
  "Defautl highlighting expressions for HDL mode.")

;; Intentation
(defun hdl-indent-line ()
  "Indent current line as HDL code."
  (interactive)
  (beginning-of-line)
  (if (bobp)
      (indent-line-to 0)
    (let ((not-indented t) cur-indent)
      (if (looking-at ".*}")
          (progn
            (save-excursion
              (forward-line -1)
              (setq cur-indent (- (current-indentation) tab-width)))
            (if (< cur-indent 0)
                (setq cur-indent 0)))
        (save-excursion
          (while not-indented
            (forward-line -1)
            (if (looking-at ".*}")
                (progn
                  (setq cur-indent (current-indentation))
                  (setq not-indented nil))
              (if (looking-at ".*{")
                  (progn
                    (setq cur-indent (+ (current-indentation) tab-width))
                    (setq not-indented nil))
                (if (bobp)
                    (setq not-indented nil)))))))
      (if cur-indent
          (indent-line-to cur-indent)
        (indent-line-to 0)))))

;; The syntax table
;; A syntax table tells Emacs how it should treat various tokens in your text for various functions
(defvar hdl-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    st)
  "Syntax table for ‘hdl-mode’.")

;; The entry function
;; Create the function that will be called by Emacs when the mode is started
(define-derived-mode hdl-mode ()
  "Major mode for editing Hardware Description Language files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table hdl-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults) '(hdl-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'hdl-indent-line)
  (setq major-mode 'hdl-mode)
  (setq mode-name "HDL")
  (run-hooks 'hdl-mode-hook))


;;
;; Major mode for test script language
;;

(defvar tst-mode-hook nil)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.tst\\'" . tst-mode))

;; Syntax highlighting
(defconst tst-font-lock-keywords-1
  (append hdl-font-lock-keywords-builtin
          (list
           '("\\<load\\|output-file\\|output-list\\|compare-to\\|!\\>" . font-lock-keyword-face)))
  "Setup commands.")

(defconst tst-font-lock-keywords-2
  (append tst-font-lock-keywords-1
          (list
           '("set\\|eval\\|output\\|tick\\|tock\\|repeat\\|while\\|echo\\|clear-echo\\|breakpoint\\|clear-breakpoints" . font-lock-function-name-face)))
  "Simulation commands.")

(defconst tst-font-lock-keywords-3
  (append tst-font-lock-keywords-2
          (list
           '("\\(%[[:alpha:]]\\)\\([[:digit:]]+\\)\\([[:blank:]]+\\|,\\|\\;\\|$\\|\\.\\)" 1 font-lock-variable-name-face)
           '("[[:blank:]]+\\([[:digit:]]+\\)\\([[:blank:]]+\\|,\\|\\;\\)" 1 font-lock-constant-face)
))
  "Others.")

(defvar tst-font-lock-keywords tst-font-lock-keywords-3
  "Defautl highlighting expressions for TST mode.")

;; The entry function
;; Create the function that will be called by Emacs when the mode is started
(define-derived-mode tst-mode ()
  "Major mode for editing Test Scripting Language files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table hdl-mode-syntax-table) ;; Use the same indentation function as hdl for tst
  (set (make-local-variable 'font-lock-defaults) '(tst-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'hdl-indent-line) ;; Use the same syntax table function as hdl for tst
  (setq major-mode 'tst-mode)
  (setq mode-name "TST")
  (run-hooks 'tst-mode-hook))


;;
;; Major mode for the intermediate representation used by the vm translator
;;
(defvar vm-mode-hook nil)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.vm\\'" . vm-mode))

;; Syntax highlighting
(defconst vm-font-lock-keywords-1
  (list
   '("add\\|\
sub\\|\
neg\\|\
eq\\|\
gt\\|\
lt\\|\
and\\|\
or\\|\
not" . font-lock-function-name-face))
  "Highlighting expressions for arithmetic and logical commands.")

(defconst vm-font-lock-keywords-2
  (append vm-font-lock-keywords-1
          (list
           '("push\\|pop" . font-lock-keyword-face)
           '("argument\\|local\\|static\\|constant\\|this\\|that\\|pointer\\|temp" . font-lock-constant-face)))
  "Highlighting expressions for memory access commands and constants.")

(defconst vm-font-lock-keywords-3
  (append vm-font-lock-keywords-2
          (list
           '("label\\|goto\\|if-goto\\|function\\|call\\|return" . font-lock-type-face)))
  "Highlighting expressions for program flow and function calling commands.")

(defvar vm-font-lock-keywords vm-font-lock-keywords-3
  "Defautl highlighting expressions for HDL mode.")

;; The entry function
(define-derived-mode vm-mode ()
  "Major mode for editing .vm files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table hdl-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults) '(vm-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'hdl-indent-line)
  (setq major-mode 'vm-mode)
  (setq mode-name "VM")
  (run-hooks 'vm-mode-hook))


;;
;; Major mode for the high level language Jack
;;
(defvar jack-mode-hook nil)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.jack\\'" . jack-mode))

;; Syntax highlighting
(defconst jack-font-lock-keywords-1
  (list
   '("class\\|\
constructor\\|\
method\\|\
function\\|\
var\\|\
static\\|\
field\\|\
let\\|\
do\\|\
if\\|\
else\\|\
while\\|\
return\\|\
this" . font-lock-keyword-face))
  "Highlighting expressions for program components, variable declaration, statements, constant values, object reference")

(defconst jack-font-lock-keywords-2
  (append jack-font-lock-keywords-1
          (list
           '("class[[:blank:]]+\\(\\w+\\)[[:blank:]]+{" 1 font-lock-function-name-face)
           '("\\(\\w+\\)[[:blank:]]*=[[:blank:]]*" 1 font-lock-variable-name-face)
           '("[^a-zA-Z0-9]\\(int\\|boolean\\|char\\|void\\)[^a-zA-Z0-9]" 1 font-lock-type-face)
           '("true\\|false\\|null" . font-lock-constant-face)))
  "Highlighting expressions for memory access commands and constants.")

(defconst jack-font-lock-keywords-3
  (append jack-font-lock-keywords-2
          (list
           '("[^a-zA-Z0-9]\\(Math\\|String\\|Array\\|Output\\|Screen\\|Keyboard\\|Memory\\|Sys\\)[^a-zA-Z0-9]" 1 font-lock-function-name-face)
           '("\\(constructor\\|method\\|function\\)[[:blank:]]+\\(\\w+\\)[[:blank:]]+\\(\\w+\\)[[:blank:]]*(" 3 font-lock-constant-face)))
  "Highlighting expressions for Jack standard libraries.")

(defvar jack-font-lock-keywords jack-font-lock-keywords-3
  "Defautl highlighting expressions for HDL mode.")

;; The entry function
(define-derived-mode jack-mode ()
  "Major mode for editing .jack files"
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table hdl-mode-syntax-table) ;; use old hdl syntax table
  (set (make-local-variable 'font-lock-defaults) '(jack-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'hdl-indent-line) ;; use old hdl indent rule
  (setq major-mode 'jack-mode)
  (setq mode-name "Jack")
  (run-hooks 'jack-mode-hook))


(provide 'init-nand2tetris)

;;; init-nand2tetris.el ends here
