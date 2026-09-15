#lang sicp
(define (sqrt x)
  (sqrt-iter 1.0 x))
(define (sqrt-iter guess x) 
  (if (good-enough? guess x) 
      guess 
      (sqrt-iter (improve guess x) x))) 
(define (improve guess x) 
  (average guess (/ x guess))) 
(define (average x y) 
  (/ (+ x y) 2)) 
(define (good-enough? guess x) 
  (< (abs (- (square guess) x)) 0.001)) 
(define (square x)
  (* x x))

(sqrt 2) ; 1.4142156862745097
(define (sqrt2 x)
  (sqrt-iter 1 x))
(sqrt2 2) ; 1 169/408 -> precise value is calculated for integer arithmetic

; what are the problems with the above?
; 1. names are in global scope - can't modify, can't reuse :(
; 2. can't associate code together
; how to fix? namespace abstraction
