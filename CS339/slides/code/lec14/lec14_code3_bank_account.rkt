#lang sicp

(define balance 100)
(define (make-withdraw balance)
  (lambda (amount)
  (if (>= balance amount)
      (begin (set! balance (- balance amount)) balance) ; begin keywords for sequencing multiple statements
      "Insufficient funds")))

(define W1 (make-withdraw 100))
(define W2 (make-withdraw 100))
(W1 50) ; 50
(W2 70) ; 30
(W2 40) ; "Insufficient funds"
(W1 40) ; 10

; putting it together
(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount)) balance) ; 
      "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request: MAKE-ACCOUNT" m))))
  dispatch)

(define A1 (make-account 100))
(define A2 (make-account 200))
((A1 'withdraw) 20) ; 80
((A2 'deposit) 20) ; 220

; pros of assignments
; 1. model the real world in terms of objects with local state
; 2. modularity - independence of objects and users (now we don't need to remember everytime)

; imperative programs - sequencing assignments and non-assignments
; imperative paradigm is necessary for OO paradigm to have time varying states

; cons of assignments
; 1. byebye substitution model - now we have states to take care of, so simple substitution may lead to unexpected results
; 2. byebye referential transparency - procedures are no longer just mathematical functions
;                                      earlier, things that looked the same behaved the same. now, we have to think of memory
;                                      can't reason about correctness by "looking" at the program
; 3. inducing order in life - difficult to parallelize :( set! are sequenced
; 4. identity crisis! - accounts with same balance can be different
;                     - account with changing balance is same account only
;                     - b-but rationals didn't do that...
;                     - so now... what is a bank account? how do we say two accounts are equal? (need to use addresses, hash values etc)

        