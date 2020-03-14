(in-package #:instalag)

(defparameter *running* nil)
(defparameter *vertex-stream* nil)
(defparameter *gpu-array* nil)
(defparameter *loop* 0.0)
(defparameter *transform* (m4:identity))

(defconstant +triangle+
  (list (v!  0.0   0.2  0.0  1.0)
        (v! -0.2  -0.2  0.0  1.0)
        (v!  0.2  -0.2  0.0  1.0)))

(defun-g compute-position ((position :vec4) (id :float))
  (let ((pos (v! (* (s~ position :xyz) 2.0) 1.0))
	(i (float id)))
    (+ pos (v! (sin (+ i *loop*)) i 0.0 0.0))))

(defun-g compute-color ()
  (v! (sin *loop*) (cos *loop*) 0.5 1.0))

(defpipeline-g prog-1 ()
  (lambda-g ((position :vec4) &uniform (id :float))
    (compute-position position id))
  (compute-color))

(defun run-step ()
  (step-host)
  (update-repl-link)
  (incf *loop* 0.01)
  (clear)
  (loop :for id :below 100 :do
       (map-g #'prog-1 *vertex-stream* :id (float id)))
  (swap))

(defun run-loop ()
  (setf *running* t)
  (setf *gpu-array* (make-gpu-array +triangle+
                                    :element-type :vec4
                                    :dimensions 3))
  (setf *vertex-stream* (make-buffer-stream *gpu-array*))
  (loop :while (and *running*
		    (not (shutting-down-p)))
     :do (continuable (run-step))))

(defun stop-loop ()
  (setf *running* nil))

