(in-package #:instalag)

(defparameter *running* nil)
(defparameter *vertex-stream* nil)
(defparameter *gpu-array* nil)
(defparameter *loop* 0.0)
(defparameter *transform* (m4:identity))

(defvar +triangle+
  (list (v!  0.0   0.2  0.0  1.0)
        (v! -0.2  -0.2  0.0  1.0)
        (v!  0.2  -0.2  0.0  1.0)))

(defun-g compute-position ((position :vec4) (id :float))
  (let ((pos (v! (* (s~ position :xyz) 2.0) 50.0))
	(i (float id)))
    (* *transform*
       (+ pos (v! (sin (+ i *loop*)) i 0.0 0.0)))))

(setf *transform*
      (m4:+
       (m4:translation (v! 0.0 0.0 10.0))
       (destructuring-bind (width height)
	   (viewport-dimensions (current-viewport))
	 (let ((near 10)
	       (far 100)
	       (fov 90))
	   (rtg-math.projection:perspective
	    (coerce width 'single-float)
	    (coerce height 'single-float)
	    (coerce near 'single-float)
	    (coerce far 'single-float)
	    (coerce fov 'single-float))))))

#+nil
(setf *transform*
      (m4:+
       *transform*
       (m4:translation (v! .2 .2 .2))))

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


