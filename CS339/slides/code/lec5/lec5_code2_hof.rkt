#lang sicp
; higher order functions :) - functions can have other functions as arguments
(define (sum-series term a next b) ; common structure for summing a series from lower bound a to upper bound b
  (if (> a b)
      0
      (+ (term a) (sum-series term (next a) next b))))

(define (sum a b)
  (sum-series (lambda (x) x) a (lambda (x) (+ x 1)) b))

(define (sum-pi8 a b)
  (sum-series (lambda (x) (/ 1.0 (* x (+ x 2)))) a (lambda (x) (+ x 4)) b))

(sum 2 10) ; 54
(sum-pi8 1 8) ; 0.3619047619047619

(define (fixed-point f start) ; we are now consuming procedures...
  (define tolerance 0.001) 
  (define (close-enough? u v) 
    (< (abs (- u v)) tolerance)) 
  (define (iter old new) 
    (if (close-enough? old new) 
        new 
        (iter new (f new)))) 
  (iter start (f start))) 
(define (avg x y) (/ (+ x y) 2)) 
(define (sqrt x) ; and producing procedures !
  (fixed-point (lambda (y) (avg y (/ x y))) 1.0)) ; works thanks to lexical scoping :)

(define (cube-root x)
  (fixed-point (lambda (y) (avg y (/ x  (* y y)))) 1.0))

(sqrt 2) ; 1.4142135623746899
(cube-root 2) ; 1.2596412994629174

;In a PL, a value is first-class if it can be: ;
;1. named 
;2. taken as an argument by a procedure 
;3. returned back from a procedure 
;4. stored into data structures
; procedures are first-class in scheme :)