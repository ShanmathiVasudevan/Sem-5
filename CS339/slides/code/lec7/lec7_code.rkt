#lang sicp
; turing machines (foundations of Von Neumann type computers) == lambda calculus (foundations of functional PLs)
; developing PLs? how?
; 1. can do everything a turing machine does
; 2. something to make it distinct
; 3. programs written will have a deterministic behaviour - semantics defined deterministically, defined based on Turing machines or lambda calculus
; it brings confidence in the language :)

; untyped lambda calculus has 3 ways to write an expression
; E -> x | (lambda x. E) | (E1 E2)
; E is expression
; x is a placeholder
; (lambda x. E) is (lambda (x) E) in scheme, a lambda with 1 argument
; (E1 E2) is a procedure application
; well we can get rid of () if we define the evaluation properly - in  order to make it an unambiguous context-free grammar

; currying - (lambda (x) (lambda (y) (+ x y))) -> works due to closures - the binding environment of inner function already has x - inner function is curried to outer function
; passing only 1 argument at a time = currying (named after Haskell Curry :))

; ((lambda x. + x 1) 2) == 3
; reduced via beta reduction to (+ 2 1)
; ((lambda x. M) N) =(beta) M[x=N]

; normal order of eval -> outermost reducible expression first
; applicative order of eval -> innermost reducible expression first
; normal form of an expression is one that can't be beta-reduced further anymore
; church rosser theorem -> if a lambda expression has a normal form, normal order of evaluation will lead to it (applicative order need not ;|). normal forms are unique for any expression in lambda calculus, if they exist

((lambda (x) x)((lambda (x) x)(lambda(z) (lambda (x) x) z))) ;#<procedure>
; normal order: i'm marking the part getting reduced in each step (the lambda x.M part) with [ ]
;([(lambda (x) x)]((lambda (x) x)(lambda(z) (lambda (x) x) z)))
; =(beta) ([(lambda (x) x)](lambda(z)(lambda(x) x) z))
; =(beta) (lambda (z) [(lambda(x) x)] z)
; =(beta) (lambda (z) z)

; applicative order:
; ((lambda (x) x)((lambda (x) x)(lambda(z) [(lambda (x) x)] z)))
; =(beta) ((lambda(x) x)([(lambda (x) x)] (lambda (z) z)))
; =(beta) ([(lambda(x) x)](lambda (z) z))
; =(beta) (lambda (z) z)
(define fun ((lambda (x) x)((lambda (x) x)(lambda(z) (lambda (x) x) z))))
(fun 5) ; 5

; f = (lambda x. xx)(lambda x. xx) would lead to infinite recursion in applicative order
; ((lambda x. lambda y. y) f w)
; in normal order, it would reduce to =(beta) ((lambda y. y) w) =(beta) w :) no infinite loop!

; now let's take ((lambda x. lambda y. x y) y) =(beta) (lambda y. y y)?? No... we accidentally bound a free variable :( the y from outside was not meant to be bound.
; let's change my own local (bound) variables... =(alpha) ((lambda x. lambda z. x z) y) =(beta) (lambda z. y z) :) yayyy

; time for church booleans!
(define ctrue ; ctrue = (lambda x. lambda y. x)
  (lambda (x)
    (lambda (y)
      x)))

(define cfalse ; cfalse = (lambda x. lambda y. y)
  (lambda (x)
    (lambda (y)
      y)))

(define cif
  (lambda (p) ; boolean
    (lambda (a) ; if branch
      (lambda (b) ; else branch
        ((p a) b))))) ; the boolean acts as a selector

(((cif ctrue) 'yes) 'no) ; yes
; what's the reduction here?
; ((lambda p. lambda a. lambda b. p a b) (lambda x. lambda y. x) 'yes 'no)
; =(beta) ((lambda a. lambda b. (lambda x. lambda y. x) a b) 'yes 'no)
; =(beta) ((lambda b. (lambda x. lambda y x) 'yes b) 'no)
; =(beta) ((lambda x. lambda y x) 'yes 'no)
; =(beta) ((lambda y 'yes) 'no)
; =(beta) 'yes
(((cif cfalse) 'yes) 'no) ; no

(define cnot
  (lambda (x)
      ((x cfalse) ctrue)))

(((cnot ctrue) 'yes) 'no) ; no
(((cnot cfalse) 'yes) 'no) ; yes

(define cxor
  (lambda (x)
    (lambda (y)
      ((x ((y cfalse) ctrue)) ((y ctrue) cfalse))))) ; lolz do LEM on each variable haha

((((cxor ctrue) ctrue) 'yes) 'no) ;no
((((cxor ctrue) cfalse) 'yes) 'no) ;yes
((((cxor cfalse) ctrue) 'yes) 'no) ;yes
((((cxor cfalse) cfalse) 'yes) 'no) ;no
