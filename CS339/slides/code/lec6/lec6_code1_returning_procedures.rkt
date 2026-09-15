#lang sicp
; returning procedures

(define (make-inc) ; this binds make-inc to a procedure itself -> this returns a procedure which itself takes 1 argument and returns the successor
  (lambda (x) (+ x 1)))
; vs
(define make-inc1 ; this binds make-inc1 to the code of the procedure -> this takes 1 argument and returns its successor
  (lambda (x) (+ x 1)))

make-inc ; #<procedure:make-inc>
(make-inc) ; #<procedure>
make-inc1 ; #<procedure:make-inc1>
; (make-inc1) - this gives error
; make-inc1: arity mismatch;
; the expected number of arguments does not match the given number
;  expected: 1
;  given: 0

((make-inc) 5) ; 6
(make-inc1 5) ; 6

; now let us see a MAGIC :) hehe
(define x 14)
(define (foo y)
  (define x 4)
  (define (bar z)(+ x  y z))
  bar)
((foo 5) 40) ; 49, not 59

(define (foobar f x)(f x)) ; what's special about foobar?
(define (foo1 y) 
    (define x 4) 
    (define (bar1 z) 
      (+ x y z)) 
    (foobar bar1 40))
(foo1 5) ; 49

; square root again!!!
(define (fixed-point f start) 
  (define tolerance 0.001) 
  (define (close-enough? u v) 
    (< (abs (- u v)) tolerance)) 
  (define (iter old new) 
    (if (close-enough? old new) 
        new 
        (iter new (f new)))) 
  (iter start (f start)))
(define (avg x y) (/ (+ x y) 2)) 
(define (avg-damp f) 
  (lambda (z) (avg z (f z))))

(define (sqrt x) 
(fixed-point (avg-damp (lambda (y) (/ x y))) ; what's so good about this? well, it’s not a random improve function that we use while computing square-root.
               1.0))

(sqrt 3) ; 1.7320508100147274

; avg-damp returning a function allowed us to express average-damping as a general concept, and abstracted away the specific logic for sqrt.
