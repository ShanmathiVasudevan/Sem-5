#lang sicp
; models of application of procedures
; to apply a compund procedure to args, evaluate the body of the procedure with each formal parameter replaced by the corresponding argument
; this is called the substitution model
(define (add x y)
  (+ x y))
(add 4 7) ; 11
;(+ 4 7)
; 11

(define (foo x y)
  (* x (+ (* x 2) y)))
(foo 4 5)
; (* 4 (+ (* 4 2) 5)))
; (* 4 (+ 8 5))
; (* 4 13)
; 52

(define (square x) (* x x))
(define (sum-of-squares x y)(+ (square x)(square y)))
(define (f a)(sum-of-squares (+ a 1)(* a 2)))
(f 5)

; normal form of evaluation - fully substitute, then reduce
; (sum-of-squares (+ 5 1)(* 5 2))
; (+ (square (+ 5 1)) (square (* 5 2)))
; (+ (* (+ 5 1)(+ 5 1)) (* (* 5 2)(* 5 2)))
; (+ (* 6 6)(* 10 10))
; (+ 36 100)
; 136

; applicative form of evaluation - evaluate arguments, then apply procedure
; (sum-of-squares 6 10)
; (+ (square 6) (square 10))
; (+ (* 6 6)(* 10 10))
; (+ 36 100)
; 136

; when is applicative better? avoids redundant computation. eg (+ 5 1) was evaluated only once in applicative but twice in normal
; used by C, Scheme
; also known as call by value

; when is normal better? in branching cases, evaluation of some arguments could be useless as we never use them - it can also avoid infinite loops in bad arguments :P
; used by Haskell
; also known as call by name/need

; conditionals in scheme
; more special forms! cond, if, else
(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))
; here, in ((< x 0) (- x)), this entire thing is a clause, (< x 0) is a predicate and (- x) is an action. so clause - (<predicate> <action>)
; clauses are evaluated one by one. if none of them are true, something of "no consequence" is returned

(define (abs1 x)
  (cond ((< x 0)(- x))
        (else x)))

(define (abs2 x)
  (if (< x 0)(- x) x))
; here, syntax is (if <predicate> <consequent> <alternate>)

(abs 10) ;10
(abs1 -1) ;1
(abs2 0) ;0

