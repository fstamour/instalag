
(in-package #:instalag)

(defclass camera ()
  ((viewport
    :initform (make-viewport)
    :accessor viewport
    :type viewport)
   (far
    :initform -1.0
    :type single-float
    :accessor far)
   (fov
    :initform 90
    :type single-float
    :accessor fov)
   (near
    :initform 1.0
    :type single-float
    :accessor near)
   (translation
    :initform (v! 0.0 0.0 1.0)
    :initarg
    :translation
    :accessor translation)
   (rotation
    :initform (v! 0.0 0.0 0.0 0.0)
    :initarg
    :rotation
    :accessor rotation
    :documentation "The rotation as a quaternion")))

(defvar *camera* (make-instance 'camera))

