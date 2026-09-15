#lang sicp

(define (Rational x y) 
  (lambda (msg) 
    (cond ((eq? msg 'numer) x) 
          ((eq? msg 'denom) y) 
          ((eq? msg 'mult-rat) 
           (lambda (other) 
             (Rational (* x (other 'numer)) 
                       (* y (other 'denom)))))))) 
(define n1 (Rational 2 3)) 
(define n2 (Rational 3 4)) 
(define n3 ((n1 'mult-rat) n2))