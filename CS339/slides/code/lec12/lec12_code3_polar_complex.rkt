#lang sicp
(define (make-from-mag-ang r a) (cons r a))
(define square (lambda (x) (* x x)))
(define (make-from-real-imag x y) 
  (cons (sqrt (+ (square x) (square y))) 
        (atan y x)))
(define (magnitude z) (car z)) 
(define (angle z) (cdr z))
(define (real-part z) (* (magnitude z) (cos (angle z)))) 
(define (imag-part z) (* (magnitude z) (sin (angle z))))

(define (mult-complex z1 z2) 
  (make-from-mag-ang (* (magnitude z1) (magnitude z2)) 
                       (+ (angle z1) (angle z2))))

(define (add-complex z1 z2) 
  (make-from-real-imag (+ (real-part z1) (real-part z2)) 
                       (+ (imag-part z1) (imag-part z2))))