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

(defun set-viewport ()
  (destructuring-bind (width height)
      (viewport-dimensions (viewport *camera*))
    (gl:viewport 0 0 width height)))

(defun update-camera ()
  (setf *transform*
	(with-slots (viewport near far fov)
	    *camera*
	  (destructuring-bind (width height)
	      (viewport-dimensions viewport)
	    (m4:+
	     (m4:translation (translation *camera*))
	     (m4:*
	      (m4:scale (v! 1.0 (float (/ width height)) 1.0))
	      (rtg-math.projection:perspective
	       (coerce width 'single-float)
	       (coerce height 'single-float)
	       (coerce near 'single-float)
	       (coerce far 'single-float)
	       (coerce fov 'single-float))))))))

(setf (translation *camera*) (v! 0.0 -1.0 1.0))

(defun-g compute-position ((position :vec4) (id :float))
  (let* ((i (float id))
	 (pos (v! (* (s~ position :xyz)
		     (+ 2.0 (sin (+ i *loop*))))
		  20.0)))
    (* *transform*
       (if (< i 50)
	   (+ pos (v! (sin (+ i *loop*)) i 0.0 0.0))
	   (+ pos (v! (cos (+ i *loop*)) (- i 50) 0.0 0.0))))))

(defun-g compute-color ()
  (v! (sin *loop*) (cos *loop*) 0.5 1.0))

(defpipeline-g prog-1 ()
  (lambda-g ((position :vec4) &uniform (id :float))
    (compute-position position id))
  (compute-color))

(defun run-step ()
  (with-viewport (viewport *camera*)
    (force-output)
    (step-host)
    (update-repl-link)
    (incf *loop* 0.01)
    (gl:clear-color 0.1 0.1 0.1 1.0)
    (clear)
    (set-viewport)
    (update-camera)
    (loop :for id :below 100 :do
	 (map-g 'prog-1 *vertex-stream* :id (float id)))
    (swap)))

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


