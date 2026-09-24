#lang sicp
; introducing our new friend?enemy?

; the special form "set!" - pronounced set-bang
; (set! <name> <new-value>)
; it's not a binding! it's an assignment
; set! returns a garbage value - we can say it doesn't return at all, but don't rely on this

;  Mutations enabled by assignments lead to the notion of a state after each assignment

; An assignment updates the state. 
; A sequence of assignments leads to a sequence of states. 
; Hence, assignments are *state*ments (against expressions). Each assignment is like a command to change the state.  
; The practice of giving a sequence of commands to update states, in the form of assignment statements, defines the paradigm of imperative programming.

; difference between define and set!

(define (make-counter-set) 
  (define count 0) 
  (define (bump) 
    (set! count (+ count 1)) 
    count) 
  bump) 
(define c-set (make-counter-set)) 
(c-set) ; 1
(c-set) ; 2
(c-set) ; 3
; the above works. set can mutate the count properly

;(define (make-counter-def) 
;  (define count 0) 
;  (define (bump) 
;    (define count (+ count 1)) ; this gives error - count: undefined;
    ;cannot use before initialization
;    count) 
;  bump) 
;(define c-def (make-counter-def)) 
;(c-def) ; this gives error at the line shown in above comment

; why? the count which is supposed to "update" the count, binds to the count it's supposed to update, it doesn't go above to the parent environment and check
; but since the count that is here hasn't been initialized yet, there's an error

(define (f n) 
  (define (even? n) 
    (if (= n 0) #t 
        (odd? (- n 1)))) ; it anyway binds to the odd? which is defined below it
  (define (odd? n) 
    (if (= n 0) #f 
        (even? (- n 1)))) 
  (even? n)) 
(f 5) ; #f
; why does the above work? Sequential define bindings are not really sequenced! they just search for the binding in the closure

; set! assignments are sequenced though :O
; define is implemented using letrec - recursive
; (what does this mean?) there are 3 types of let - let, let* and letrec
; normal let - all the bindings are simultaneous, the values are evaluated before the binding is done
; let* - to sequence the bindings without having to nest lets
; (define (bar x y)
;   (let* ((diff (- x y))
;          (diff-squared (* diff diff))
;          (diff-cubed (* diff-squared diff)))
;     ...)
; is the same as
; (define (bar x y)
;   (let ((diff (- x y)))
;      (let ((diff-squared (* diff diff)))
;         (let ((diff-cubed (* diff-squared diff)))
;            ...))))
;
; so in let*, the order matters
; letrec - creates an environment before evaluating initial value expressions
;        - it is also simultaneous binding like let
;        - it's like if you first do let bindings with some dummy values and then set! them inside the let body with the real values
; https://docs.scheme.org/schintro/schintro_126.html#SEC161 for details :)

; When we define top-level variables and procedures, the procedures we create can refer to other variables in the same top-level environment.
; It is as though all of the top-level bindings were created by a single big letrec,
; so that the initial value expressions create procedures that can "see" each others' name bindings.
; Expressions that aren't definitions make up the "body" of this imaginary letrec.

; defines in the global environment are sequenced because that's how the interpreter works, but this kinda explains why usually defines are not sequenced
; https://docs.scheme.org/schintro/schintro_67.html#SEC74 for examples :)





