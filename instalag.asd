
(asdf:defsystem #:instalag
  :description "playing around with cepl"
  :author "Francis St-Amour"
  :license "Public"
  :depends-on (#:cepl
               #:cepl.sdl2
               #:rtg-math #:rtg-math.vari
               #:swank
               #:livesupport

               #:alexandria
               #:anaphora
               #:bordeaux-threads
               #:random-state)
  :serial t
  :components
  ((:module src
    :serial t
    :components
            ((:file package)
	     (:file event)
             (:file moving-triangles)
             (:file main)))))

