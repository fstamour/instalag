
(uiop:define-package #:instalag
    (:use #:cl #:alexandria #:anaphora
          #:cepl
          #:rtg-math
          #:livesupport)
  ;; Clamp is also exported by alexandria.
  (:shadowing-import-from #:rtg-math.base-maths #:clamp #:lerp)
  (:export #:run))

