;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smsn-serde.el -- Serializers and deserializers for use with Gremlin Server
;;
;; Part of the SmSn-mode package for Emacs:
;;   https://github.com/synchrony/smsn-mode
;;
;; Copyright (C) 2011-2017 Joshua Shinavier and collaborators
;;
;; You should have received a copy of the GNU General Public License
;; along with this software.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun get-data (json)
  (if json
    (let ((data-array (smsn-env-json-get 'data (smsn-env-json-get 'result json))))
      (if data-array
        (if (= 1 (length data-array))
          (json-read-from-string (aref data-array 0))
          (error "unexpected data array length"))
        nil))
    nil))

(defun smsn-serde-format-args (args)
  (json-encode (list
    (cons 'language "smsn")
    (cons 'gremlin (json-encode args)))))

(defun smsn-serde-format-request (args)
  (json-encode (list
    ;;(cons 'requestId "123e4567-e89b-12d3-a456-426655440000")
    (cons 'op "eval")
    (cons 'processor "session")
    (cons 'args (list
      (cons 'language "smsn")
      (cons 'session "undefined")
      (cons 'gremlin (json-encode args)))))))

(defun smsn-serde-handle-response (response callback context)
  ;;(message "%s" (concat "handling response: " response))
  (let ((json (json-read-from-string response)))
    (let ((message (smsn-env-json-get 'message (smsn-env-json-get 'status json)))
          (payload (get-data json)))
      (if (and message (> (length message) 0))
        (error "%s" (concat "request failed: " message))
        (if payload
          (funcall callback payload context)
          (error  "no response data"))))))


(provide 'smsn-serde)

