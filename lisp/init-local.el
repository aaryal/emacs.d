;;; Commentary :
;;; no comments

;; (defun my-erlang-mode-hook ()
;;   (local-set-key [(control c) (c)] 'compile-pkg))
(global-set-key [(control c) (c)] 'compile-pkg)

(defun compile-pkg (&optional command startdir)
    "Compile a package, moving up to the parent directory
  containing configure.ac, if it exists. Start in startdir if defined,
  else start in the current directory."
      (interactive)

        (let ((dirname)
              (dir-buffer nil))
              (setq startdir (expand-file-name (if startdir startdir ".")))
                  (setq command  (if command command compile-command))

                      (setq dirname (upward-find-file "Makefile" startdir))
                          (setq dirname (if dirname dirname (expand-file-name ".")))
                              ; We've now worked out where to start. Now we need to worry about
                              ; calling compile in the right directory
                              (save-excursion
                                      (setq dir-buffer (find-file-noselect dirname))
                                            (set-buffer dir-buffer)
                                                  (compile command)
                                                        (kill-buffer dir-buffer))))


(defun upward-find-file (filename &optional startdir)
    "Move up directories until we find a certain filename. If we
  manage to find it, return the containing directory. Else if we
  get to the toplevel directory and still can't find it, return
  nil. Start at startdir or . if startdir not given"

      (let ((dirname (expand-file-name
                        (if startdir startdir ".")))
            (found nil) ; found is set as a flag to leave loop if we find it
            (top nil))  ; top is set when we get
        ; to / so that we only check it once

        ; While we've neither been at the top last time nor have we found
        ; the file.
            (while (not (or found top))
              ; If we're at / set top flag.
                    (if (string= (expand-file-name dirname) "/")
                          (setq top t))

                    ; Check for the file
                          (if (file-exists-p (expand-file-name filename dirname))
                                (setq found t)
                            ; If not, move up a directory
                            (setq dirname (expand-file-name ".." dirname))))
            ; return statement
                (if found dirname nil)))

(add-to-list 'auto-mode-alist '("\\.yaws\\'" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.dtl\\'" . html-mode))


;;; redefining the flycheck method to use the include path (hardcoded for now)

(flycheck-define-checker erlang
  "An Erlang syntax checker using the Erlang interpreter.

See URL `http://www.erlang.org/'."
  :command ("erlc" "-o" temporary-directory "-Wall" "-I" "../include"  source)
  :error-patterns
  ((warning line-start (file-name) ":" line ": Warning:" (message) line-end)
   (error line-start (file-name) ":" line ": " (message) line-end))
  :modes erlang-mode)


(provide 'init-local)
