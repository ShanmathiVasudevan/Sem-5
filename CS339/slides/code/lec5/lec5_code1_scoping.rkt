#lang sicp
(define x 20)
(define (foo)
  (define x 30)
  (define (bar y)
    (+ x y)); here, y is bound variable, x is free variable
  (bar 40))
(foo) ; 70 -> static scoping, so x is looked up in the environment in which bar is defined

(define x1 20)
(define (bar1 y)
  (+ x1 y))
(define (foo1)
  (define x1 30)
  (bar1 40)) 
(foo1) ; 60 -> static scoping, x is looked up in the environment in which bar is defined
; this would be 70 in dynamic scoping, x would be looked up in the environment in which bar is called

; static scoping can be determined by just looking at the code, eg scheme
; dynamic scoping is weird as a procedure can be called in multiple places, eg shell script, original lisp. easier to implement, tougher to reason abt programs
; gcc is a static compiler
; there is also static typed languages (eg C) and dynamic typed languages (eg python)