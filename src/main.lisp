(in-package #:instalag)

(defun run ()
  "Start Swank, CEPL and the application's loop."
  (bt:make-thread
   (lambda () (swank:create-server :dont-close t))
   :name "SWANK")
  (cepl:repl)
  (cepl.host:set-step-func 'event-loop)
  (run-loop))

