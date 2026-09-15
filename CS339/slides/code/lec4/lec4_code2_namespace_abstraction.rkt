#lang sicp
(define (average x y) 
  (/ (+ x y) 2))  
(define (square x)
  (* x x)) 
(define (sqrt x) 
  (define (improve guess) 
    (average guess (/ x guess))) 
  (define (good-enough? guess) 
    (< (abs (- (square guess) x)) 0.001)) 
  (define (sqrt-iter guess) 
    (if (good-enough? guess) 
        guess 
        (sqrt-iter (improve guess)))) 
  (sqrt-iter 1.0))
(sqrt 2) ;1.4142156862745097

; we nested procedures -> they are packaged together now -> namespace abstraction
; we got rid of unnecessary arguments (improve guess x) vs (improve guess) -> lexical scoping