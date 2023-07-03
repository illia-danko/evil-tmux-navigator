;;; navigate.el --- Seamlessly navigate between Emacs and tmux

;; Author:   Keith Smiley <keithbsmiley@gmail.com>
;; Created:  April 25 2014
;; Version:  0.1.5
;; Keywords: tmux, evil, vi, vim

;;; Commentary:

;; This package is inspired by vim-tmux-navigator.
;; It allows you to navigate splits in evil mode
;; Along with tmux splits with the same commands
;; Include with:
;;
;;    (require 'navigate)
;;

;;; Code:

(require 'evil)

(defgroup navigate nil
  "seamlessly navigate between Emacs and tmux"
  :prefix "navigate-"
  :group 'evil)

(defvar tmux-fallback-directory "~"
  "Tmux path to be used as a last resort.")

(defvar tmux-prefix-key "C-@" ; C-SPC (see tmux.conf)
  "Tmux tmux.conf prefix-key.")

                                        ; Without unsetting C-h this is useless
(global-unset-key (kbd "C-h"))
(global-unset-key (kbd tmux-prefix-key))

                                        ; This requires windmove commands
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(defun tmux-navigate (direction)
  (let
      ((cmd (concat "windmove-" direction)))
    (condition-case nil
        (funcall (read cmd))
      (error
       (tmux-command direction)))))

(defun tmux-command (direction)
  (shell-command-to-string
   (concat "tmux select-pane -"
           (tmux-direction direction))))

(defun tmux-direction (direction)
  (upcase
   (substring direction 0 1)))

(defun tmux-current-directory (mode)
  (pcase mode
    ('dired-mode (dired-current-directory))
    (_ default-directory)))

(defun tmux-pane-directory ()
  (expand-file-name
   (or (vc-root-dir)
       (tmux-current-directory major-mode)
       tmux-fallback-directory)))

(define-key evil-normal-state-map
  (kbd "C-h")
  (lambda ()
    (interactive)
    (tmux-navigate "left")))
(define-key evil-normal-state-map
  (kbd "C-j")
  (lambda ()
    (interactive)
    (tmux-navigate "down")))
(define-key evil-normal-state-map
  (kbd "C-k")
  (lambda ()
    (interactive)
    (tmux-navigate "up")))
(define-key evil-normal-state-map
  (kbd "C-l")
  (lambda ()
    (interactive)
    (tmux-navigate "right")))
(define-key evil-normal-state-map
  (kbd (concat tmux-prefix-key " c"))
  (lambda ()
    (interactive)
    (shell-command-to-string
     (concat "tmux new-window -c "
             (tmux-pane-directory)))))
(define-key evil-normal-state-map
  (kbd (concat tmux-prefix-key " %"))
  (lambda ()
    (interactive)
    (shell-command-to-string
     (concat "tmux split-window -h -c "
             (tmux-pane-directory)))))
(define-key evil-normal-state-map
  (kbd (concat tmux-prefix-key " \""))
  (lambda ()
    (interactive)
    (shell-command-to-string
     (concat "tmux split-window -v -c "
             (tmux-pane-directory)))))

(provide 'navigate)

;;; navigate.el ends here
