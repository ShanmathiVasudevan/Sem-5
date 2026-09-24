#lang sicp
; time-varying states how?
; task: write a function to 'withdraw' a given amount if an account has enough balance
;       and another function to simulate the following over the account:
;       initial balance: 100
;       amounts to withdraw: 20, 90, 30

(define (withdraw balance amount)
  (if (>= balance amount) (- balance amount) "Insufficient balance"))

(define (account-ops init-bal amounts)
  (if (null? amounts) init-bal
      (let ((bal (withdraw init-bal (car amounts))))
        (if (eq? bal "Insufficient balance") (account-ops init-bal (cdr amounts))
            (account-ops bal (cdr amounts))))))

(account-ops 100 '(20 90 30)) ; 50

; well what's wrong with this?
; the account isn't storing anything! the user has the burden to *recall* the balance everytime they want to run
; what if we had many accounts? so much a user can't remember...
; we need a way to remember the balance based on the history of transactions, which in turn needs a way to update the balance after each transaction

; how do we know that objects are evolving?
; time (snapshot)? - tough to compare
; behaviour? - what if only data changes, not the behaviour of the object?
; recall? ok, we can store objects somewhere and remember later, how to change the state now? modelling a time varying state like our balance in the above example..
; we want to remember the balance based on the history of transactions.