#lang sicp

;The right procedures will be called automagically based on which dispatch procedure lies inside 'z'!
; op is our message, passed to z by apply-generic
; z is a dispatch procedure, and it takes the message and "dispatches" the correct procedure inside it :)


(define (make-from-real-imag x y)
  (define (dispatch op)
    (cond ((eq? op 'real-part) x)
          ((eq? op 'imag-part) y)
          ((eq? op 'magnitude) (sqrt (+ (* x x) (* y y))))
          ((eq? op 'angle) (atan y x))
          (else (error "Unknown op: MAKE-FROM-REAL-IMAG" op))))
  dispatch)

(define (make-from-mag-ang x y) 
(lambda (op) 
    (cond ((eq? op 'magnitude) x) 
          ((eq? op 'angle) y) 
          ((eq? op 'real-part) (* x (cos y)))
          ((eq? op 'imag-part) (* x (sin y)))
          (else (error "Unknown op: MAKE-FROM-MAG-ANG" op)))))

(define (apply-generic op arg) (arg op))

(define (real-part z) (apply-generic 'real-part z))
(define (imag-part z) (apply-generic 'imag-part z))
(define (magnitude z) (apply-generic 'magnitude z))
(define (angle z) (apply-generic 'angle z))

(define (add-complex z1 z2) 
  (make-from-real-imag (+ (real-part z1) (real-part z2)) 
                       (+ (imag-part z1) (imag-part z2))))

(define n1 (make-from-real-imag 2 3)) 
(define n2 (make-from-real-imag 3 4)) 
(define n3 (add-complex n1 n2))

(real-part n1)(imag-part n1)
;2
;3
(real-part n2)(imag-part n2)
;3
;4
(real-part n3)(imag-part n3)
;5
;7