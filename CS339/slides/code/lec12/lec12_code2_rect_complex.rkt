#lang sicp

(define (make-from-real-imag x y) (cons x y))
(define (make-from-mag-ang r a) 
  (cons (* r (cos a)) (* r (sin a))))
(define (real-part z) (car z)) 
(define (imag-part z) (cdr z))
(define square (lambda (x) (* x x)))
(define (magnitude z) 
  (sqrt (+ (square (real-part z)) 
           (square (imag-part z))))) 
(define (angle z) 
  (atan (imag-part z) (real-part z)))

(define (mult-complex z1 z2) 
  (make-from-mag-ang (* (magnitude z1) (magnitude z2)) 
                       (+ (angle z1) (angle z2))))

(define (add-complex z1 z2) 
  (make-from-real-imag (+ (real-part z1) (real-part z2)) 
                       (+ (imag-part z1) (imag-part z2))))

; problems?
; 1. well the reason it's two different files is because one will override the other if we keep together :)
; 2. if we tag, how to make sure rectangular functions get only rectangular input? it could silently throw errors...
; solutions? tagging (attach a tag to every complex number), overloading (message passing :))