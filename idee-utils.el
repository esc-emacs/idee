;;; idee-utils.el --- Emacs IDE Utilities.

;; Copyright (C) 2018 Ioannis Canellos

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at

;;       http://www.apache.org/licenses/LICENSE-2.0

;;Unless required by applicable law or agreed to in writing, software
;;distributed under the License is distributed on an "AS IS" BASIS,
;;WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;See the License for the specific language governing permissions and
;;limitations under the License.

;; Author: Ioannis Canellos

;; Version: 0.0.1

;; Package-Requires: ((emacs "25.1"))

;;; Commentary:

;;; Code:
(require 'seq)
(require 'f)
(require 'yasnippet)
(require 'editorconfig)

(defun idee-read-file (f)
  "Read the content of file F."
  (with-temp-buffer
    (insert-file-contents f)
    (buffer-substring-no-properties
     (point-min)
     (point-max))))


(defun idee-read-and-eval-template (f)
  "Read the template from F and evaluate quotes."
  (if (file-exists-p f)
      (with-temp-buffer
        (insert-file-contents f)
        (yas--restore-backquotes (yas--save-backquotes))
        (buffer-substring-no-properties
         (point-min)
         (point-max))
        )
    nil)
  )

;;; String Functions
(defun idee-starts-with (string prefix)
  "Return t if STRING start with PREFIX."
  (and (string-match (rx-to-string `(: bos ,prefix) t)
                     string)
       t))

(defun idee-ends-with (string suffix)
  "Return t if STRING ends with SUFFIX."
  (and (string-match (rx-to-string `(: ,suffix eos) t)
                     string)
       t))

(defun idee-http-post (url args callback)
  "Send ARGS to URL as a POST request."
  (let ((url-request-method "POST")
        (url-request-extra-headers
         '(("Content-Type" . "application/x-www-form-urlencoded")))
        (url-request-data
         (mapconcat (lambda (arg)
                      (concat (url-hexify-string (car arg))
                              "="
                              (url-hexify-string (cdr arg))))
                    args
                    "&")))
    (url-retrieve url callback)))

(defun idee--point-beginning-of-line()
  "Return the point of the beginning of the current line."
  (save-excursion
    (beginning-of-line)
    (point)
    )
  )

(defun idee--point-end-of-line()
  "Return the point of the end of the current line."
  (save-excursion
    (end-of-line)
    (point)
    )
  )

(defun idee-indent-file (f)
  "Indent file F."
    (find-file f)
    (set-auto-mode t)
    (indent-region (point-min) (point-max))
    (write-file f)
  )

(defun idee-indent-all-project-files()
  "Indend all files in the project."
  (interactive)
  (idee-visit-project-files 'idee-indent-file)
  )

(defun idee-visit-project-files (visitor &optional dir)
  "Call VISITOR with all project files or DIR files."
  (let* ((current (or dir (projectile-project-root))))
    (dolist (extension idee-source-file-extensions)
         (mapc (lambda (x) (funcall visitor x))
          (directory-files-recursively current (format "\\.%s$" extension))))
    )
  )

;; Credits: https://emacs.stackexchange.com/questions/12613/convert-the-first-character-to-uppercase-capital-letter-using-yasnippet
(defun idee-capitalize-first(&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat (capitalize first) rest-str))))

;;; Misc Functions
  (defun idee-screenshot ()
    "Get a screenshot."
    (interactive)
    (shell-command "scrot -s '/home/iocanel/Photos/screenshots/%Y-%m-%d_%H:%M:%S_$wx$h.png'")
    )

  (global-set-key (kbd "C-c i s") 'idee-screenshot)

  (provide 'idee-utils)
;;; idee-utils.el ends here
