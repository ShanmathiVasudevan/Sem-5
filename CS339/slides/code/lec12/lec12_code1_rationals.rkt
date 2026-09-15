#lang sicp
; the OO paradigm
; so what do we want in the OO paradigm?
; 1. Ability to group multiple items into a single abstraction -> encapsulate data, abstraction for giving name for a group of things
; 2. Ability to create multiple objects of a certain kind -> more instances of the same groups of things, constructor functions
; 3. Ability to perform operations on the object abstraction -> define operations supported on objects of this "type" -> abstract data types -> we need methods for this
; 4. Ability to say that some objects are like others in some sense but different in their own ways -> inheritance and polymorphism

(define (make-rat x y) 
  (lambda (which) 
    (if (= which 0) x y))) 
(define (numer n) (n 0)) 
(define (denom n) (n 1)) 
(define (mult-rat n1 n2) 
  (make-rat (* (numer n1) 
               (numer n2)) 
            (* (denom n1) 
               (denom n2)))) 
(define n1 (make-rat 2 3)) 
(define n2 (make-rat 3 4)) 
(define n3 (mult-rat n1 n2))

; what's missing rn?
; 1. scoping -> packaging (although, we did see something in nested procedures)
; 2. message passing/ dispatch on objects (implicit parameter, this pointer)
; 3. inheritance and polymorphism (relationship between different objects)