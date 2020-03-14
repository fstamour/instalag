(in-package #:instalag)

(defparameter *fullscreen-p* nil)

(defun event-loop (window)
  (cepl.sdl2::%case-events (event)
    (:windowevent
     (:event event :data1 data1 :data2 data2)
     (when (eq event #.sdl2-ffi:+SDL-WINDOWEVENT-RESIZED+)
       (format t "Windows resized to ~dx~d" data1 data2)
       (setf (viewport-dimensions (cepl:current-viewport))
	     (list data1 data2))))
    (:keydown
     (:keysym keysym)
     (let ((scancode (sdl2:scancode-value keysym))
           (sym (sdl2:sym-value keysym))
           (mod-value (sdl2:mod-value keysym)))
       (cond
         ((sdl2:scancode= scancode :scancode-f11)
          (format t "~&About to toggle fullscreen~%")
          (sdl2:set-window-fullscreen
           window
           (if *fullscreen-p*
               :window
               :fullscreen))
          (setf *fullscreen-p* (not *fullscreen-p*))))))
    (:quit
     () (quit))))

