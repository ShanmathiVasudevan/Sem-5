#lang sicp

; REPL - read, eval, print, loop :)

; primitive expressions in scheme
2 ; 2 
+ ; #<procedure:+>
#t ; #t

;2+3 - this gives error
; 2+3:  undefined;
; cannot reference an identifier before its definition
; it took 2+3 as an identifier lol

; infix notation not supported
2 + 3
;2
;#<procedure:+>
;3

; use prefix notation, (<operator bound to a procedure, or expression that evaluates to a procedure> <operands>)
(+ 2 3) ; 5

;(2 + 3) - this gives error
;application: not a procedure;
; expected a procedure that can be applied to arguments
;  given: 2

(+ 2 3 4) ; 9

; trying an operator with no operands :O
(+) ; 0
; it returned the identity of the operator

; (-) - this gives error
;-: arity mismatch;
; the expected number of arguments does not match the given number
;  expected: at least 1
;  given: 0
; subtraction doesn't have an identity lol

(*) ; 1

; (/) - this gives error
;/: arity mismatch;
; the expected number of arguments does not match the given number
;  expected: at least 1
;  given: 0

(+ 2 (* 3 4) (- 5 3)) ; 16

;(+ 2 #t) - this gives error
; +: contract violation
;  expected: number?
;  given: #t

(and #t #f) ; #f
(or #t #f #t) ; #t
(not #t) ; #f 

; 1. evaluate the operator - procedure
; 2. evaluate the operands - args
; 3. apply the procedure from step 1 to the args from step 2
; substitution model :) works for now

; some "special forms" exist which don't obey this standard evaluation
; define is our first special form
(define a 2) ; adds a binding to the environment
a ; 2
; b - this gives error
; b: undefined;
; cannot reference an identifier before its definition

; here, the binding <a,2> is added to the GLOBAL environment.
; procedures in scheme are "closures" = lambda + environment.
; the closure encapsulates bindings from the environment in which the lambda was defined, and we evaluate the body in the enclosed environment


(define c (+ 3 4))
c ; 7

(define (add3 x) (+ 3 x)) ; defining a procedure - what's this weird way of writing?
(add3 4) ; 7

(define foo (lambda (x y)(+ x y))) ; the above weird way is a syntactic sugar for a lambda.
; lambda is a tag for a procedure - whatever follows it is a procedure
; so here we are binding foo to a procedure - <foo, code of foo> is the binding
(foo 2 3) ; 5

; earlier we said evaluate the operator, right? here's an example
((lambda (x y) (+ x y)) 2 3) ; 5

; (foo 2) - this gives error
; foo: arity mismatch;
; the expected number of arguments does not match the given number
;  expected: 2
;  given: 1

; something nice - run it in the prompt.
; I have commented it out because when it's in the file it throws the error:
; module: identifier already defined in: a
;(define a 2)
;(define b a)
;(define a 3)
; b ; 2 is the output here in the prompt
; bindings are overwritten in the global environment

; something fun - run this in a different file or in the prompt, because here it gives error
; +: undefined;
; cannot reference an identifier before its definition
; above error is in the first place where I asked it to print +, to show it is a primitive expression

; (define + *)
; (+ 2 3) ; 6
; hehehehehe now + is gone forever :) 

; the below also gives error in the file, so run it in the prompt
;(define sub -)
;(define - /)
;(sub 6 2) ; 4
;(- 6 2) ; 3
;(define - sub)
;(- 6 2) ; 4

; you can even bind define to something else, but you cannot bind something to define, so no way to recover later!
; (define define 2) ; this works if you do it in a different file lol
; define ; 2

; in a different place, where you haven't fiddled with define's binding, try
; (define a define) - this gives error
; define: bad syntax in : define
; (define 2 3) - this gives error
; define: bad syntax in: 2
; this is due to some semantics :)

(define (foo1)
  (define (add x y)
    (+ x y))
  add)
foo1 ; #<procedure:foo1>
(foo1) ; #<procedure:.../lec2/lec2_code.rkt:128:2>
; so foo1 evaluates to a procedure :)
((foo1) 2 3) ; 5
; (foo1 2 3) - this gives error
;foo1: arity mismatch;
; the expected number of arguments does not match the given number
;  expected: 0
;  given: 2
(define bar (foo1))
(bar 2 3) ; 5

; lastly, some weird things
; see lists in full action in lectures 9, 10, 11
; i'm only adding this here as sir mentioned the "." notation to get "unknown number of args" in a function, and the " ' " character to take "programs as input to other programs", in lecture 2.
(define (sum1 args) ; here, args is a list
  (if (null? args) 0 (+ (car args) (sum1 (cdr args))))) ; car ==> first element of list. cdr ==> remaining part. more nuance in the list lectures.
(sum1 (list 1 3 5 6 7)) ; 22
(sum1 '(2 3 2 6 5)) ; 18 - see we used ' here. that is a quoted text - unevaluated

(define (foldr f v l) ; folds list from the right side
  (if (null? l) v
      (f (car l) (foldr f v (cdr l)))))

(define (foldl f v l) ; folds list from the left side
  (if (null? l) v
      (foldl f (f v (car l)) (cdr l))))

(define (sum2 . args) ; here is our magic dot! apparently it is used to pack whatever you give in args as a list
  (foldr + 0 args))
(sum2 1 4 7 2 7 9) ; 30 - see here I neither used (list 1 2 3 4 5) nor '(1 2 3 4 5) but thanks to the . it took all the args and made it as a list :)

(define (sum3 . args)
  (foldl + 0 args))
(sum3 1 4 7 2 7 9) ; 30

; the below was google ai overview's example when I asked how to use .
(define (sum4 . args)
  (if (null? args) 0 (+ (car args) (apply sum4 (cdr args))))) ; now what is apply? it's a procedure that takes an operator and a list and does accumulation. but what is the starting value (like v in foldr or foldl)? the car of the list itself ig :o
(sum4 5 4 7 9 10) ; 35

; difference between apply, foldl and foldr
(apply - '(1 2 3 4 5)); -13 = ((((1-2)-3)-4)-5)
(foldr - 0 '(1 2 3 4 5)) ; 3 = (1-(2-(3-(4-(5-0)))))
(foldl - 0 '(1 2 3 4 5)) ; -15 = (((((0-1)-2)-3)-4)-5)
