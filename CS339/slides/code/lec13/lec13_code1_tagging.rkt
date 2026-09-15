#lang sicp
; well, tagging solves the problem, but breaks the abstraction barrier when we want to add things
; actually happened to Java's JVM! They had to rewrite the whole thing because no one knew what was happening anymore, due to lack of abstraction barriers; it was too big, no one could add anything
; bootstrapping - JVM written in Java itself, gcc is written in C :O
; it actually hurts more to redefine the generic procedures :(  

 
(define (attach-tag type-tag contents) 
  (cons type-tag contents)) 
(define (type-tag datum) (car datum)) 
(define (contents datum) (cdr datum))

(define (rectangular? z) (eq? (type-tag z) 'rectangular)) 
(define (polar? z) (eq? (type-tag z) 'polar))

; rectangular
(define (make-from-real-imag-rectangular x y) (attach-tag 'rectangular (cons x y)))
(define (make-from-mag-ang-rectangular r a) 
  (attach-tag 'rectangular (cons (* r (cos a)) (* r (sin a)))))
(define (real-part-rectangular z) (car z)) 
(define (imag-part-rectangular z) (cdr z))
(define square (lambda (x) (* x x)))
(define (magnitude-rectangular z) 
  (sqrt (+ (square (real-part-rectangular z)) 
           (square (imag-part-rectangular z))))) 
(define (angle-rectangular z) 
  (atan (imag-part-rectangular z) (real-part-rectangular z)))
; polar
(define (make-from-mag-ang-polar r a) (attach-tag 'polar (cons r a)))
(define (make-from-real-imag-polar x y) 
  (attach-tag 'polar (cons (sqrt (+ (square x) (square y))) 
        (atan y x))))
(define (magnitude-polar z) (car z)) 
(define (angle-polar z) (cdr z))
(define (real-part-polar z) (* (magnitude-polar z) (cos (angle-polar z)))) 
(define (imag-part-polar z) (* (magnitude-polar z) (sin (angle-polar z))))

(define (real-part z) ; generic procedure
  (cond ((rectangular? z) (real-part-rectangular (contents z))) ((polar? z) (real-part-polar (contents z))) (else (error "unknown type" z))))
(define (imag-part z) 
  (cond ((rectangular? z) (imag-part-rectangular (contents z))) ((polar? z) (imag-part-polar (contents z))) (else (error "unknown type" z))))
(define (magnitude z)
  (cond ((rectangular? z) (magnitude-rectangular (contents z))) ((polar? z) (magnitude-polar (contents z))) (else (error "unknown type" z))))
(define (angle z) 
  (cond ((rectangular? z) (angle-rectangular (contents z))) ((polar? z) (angle-polar (contents z))) (else (error "unknown type" z))))

(define c1 (make-from-real-imag-rectangular 2 5))
(define c2 (make-from-real-imag-polar 2 5))
(define c3 (make-from-mag-ang-rectangular 2 5))
(define c4 (make-from-mag-ang-polar 2 5))

(define (mult-complex z1 z2) 
  (make-from-mag-ang-polar (* (magnitude z1) (magnitude z2)) 
                       (+ (angle z1) (angle z2))))

(define (add-complex z1 z2) 
  (make-from-real-imag-rectangular (+ (real-part z1) (real-part z2)) 
                       (+ (imag-part z1) (imag-part z2))))

(define c5 (add-complex c1 c4))
(define c6 (mult-complex c2 c3))
(define c7 (add-complex c5 c6))

c1 ; (rectangular 2 . 5)
c2 ; (polar 5.385164807134504 . 1.1902899496825317)
c3 ; (rectangular 0.5673243709264525 . -1.917848549326277)
c4 ; (polar 2 . 5)
c5 ; (rectangular 2.5673243709264524 . 3.082151450673723)
c6 ; (polar 10.770329614269006 . -0.0928953574970548)
c7 ; (rectangular 13.291215859410737 . 2.0830762066534314)
  