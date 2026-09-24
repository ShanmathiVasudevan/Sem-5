#lang sicp
; till line 109, the code is as it was in lec21
; =============== CS339 Autumn 2026 =================

(define-syntax delay
  (syntax-rules ()
    ((delay expr) (lambda () expr))))

(define-syntax cons-stream
  (syntax-rules ()
    ((cons-stream a b) (cons a (delay b)))))

(define (stream-car s)
  (car s))

(define (force promise) (promise))

(define (stream-cdr s) (force (cdr s)))

(define the-empty-stream '())

(define (stream-null? s) (eq? s the-empty-stream))

(define (stream-map proc s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (proc (stream-car s))
                         (stream-map proc (stream-cdr s)))))

(define (stream-filter pred s)
  (cond ((stream-null? s) the-empty-stream)
        ((pred (stream-car s))
         (cons-stream (stream-car s)
                      (stream-filter pred (stream-cdr s))))
        (else (stream-filter pred (stream-cdr s)))))

(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream low
                   (stream-enumerate-interval (+ low 1) high))))

(define (enumerate-interval low high)
  (if (> low high)
    nil
    (cons low (enumerate-interval (+ low 1) high))))

(define (map f l)
  (if (null? l)
    nil
    (cons (f (car l))
          (map f (cdr l)))))

(define (filter pred l)
  (cond ((null? l) nil)
        ((pred (car l)) (cons (car l) (filter pred (cdr l))))
        (else (filter pred (cdr l)))))

(define (square x)
  (* x x))

(define (average x y) (/ (+ x y) 2))
(define (sqrt-improve guess x)
    (average guess (/ x guess)))

(define (sqrt x tolerance)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) tolerance))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (sqrt-improve guess x))))
  (sqrt-iter 1.0))

(define (prime? n)
  (define (divides? a b) (= (remainder b a) 0))
  (define (smallest-divisor n) (find-divisor n 2))
  (define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))
  (= n (smallest-divisor n)))

;; (car (cdr
;;       (filter prime?
;;               (enumerate-interval 10000 1000000))))

;; (stream-car (stream-cdr
;;               (stream-filter
;;                 prime?
;;                   (stream-enumerate-interval 10000 1000000))))

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

(define (divisible? x y) (= (remainder x y) 0))
   
(define nd5
  (stream-filter
   (lambda (x) (not (divisible? x 5)))
   integers))

;; (stream-ref nd5 15)

; now comes lec 22 :)
; Sieve of Eratosthenes - what's the logic?
; take out the car of the stream, and remove all the numbers divisible by the car, repeat 

(define ints (integers-starting-from 2))

(define (sieve s)
  (cons-stream (stream-car s)
               (sieve ; always the best part about functional programming - the code looks how we speak hehe
                    (stream-filter (lambda (x) (not (divisible? x (stream-car s))))
                                   (stream-cdr s)))))

(define primes (sieve ints))

(define primes2 (cons-stream 2
                             (stream-filter is-prime? (integers-starting-from 3))))

(define (is-prime? n)
  (define (iter ps)
    (cond ((> (square (stream-car ps)) n) true)
          ((divisible? n (stream-car ps)) false)
          (else (iter (stream-cdr ps)))))
  (iter primes2))

; wait, primes2 is using is-prime? and is-prime? is using primes2... hein??
; it's not magic, trust.
(stream-ref primes2 100) ; 547
; k = 100
; (stream-ref (stream-cdr primes2) 99)
;             (force (cdr primes2))
;             (force (lambda () (stream-filter is-prime? (integers-starting-from 3))))
;             (stream-filter is-prime? (integers-starting-from 3))
;             (stream-filter is-prime? (3. #<procedure: (lambda () (integers-starting-from 4))>))
;                            ; evaluating (is-prime? 3)
;                            ;            ( > 4 3) is true, so this returns true
;             (cons-stream 3 (stream-filter is-prime? (lambda () (integers-starting-from 4))))
;             (3. (lambda () (stream-filter is-prime? (lambda () (integers-starting-from 4)))))
; k = 99
; (stream-ref (stream-filter is-prime? (integers-starting-from 4)) 98)

; ... and so on! it works so neatly hehe



; now see streams as another way of iteration!
(define (sqrt-stream x)
  (define guesses
    (cons-stream 1.0
                 (stream-map (lambda (guess)
                               (sqrt-improve guess x))
                             guesses)))
  guesses)

(define sqrt-2 (sqrt-stream 2))

(stream-ref sqrt-2 3) ; 1.4142156862745097
(stream-ref sqrt-2 8) ; 1.414213562373095

;  hmmm, can we get rid of time with streams, as we promised we would? (the chalk example - the chalk is not an object moving through space and time, but it is the path it took while moving
; let's go back to bank account. with assignment statements, we had...
(define (make-simplified-withdraw balance)
  (lambda (amount)
    (set! balance (- balance amount))
    balance))
; now with streams, we have...
(define (stream-withdraw balance amt-stream)
  (cons-stream balance (stream-withdraw (- balance (stream-car amt-stream)) (stream-cdr amt-stream))))
; now, we don't need to have the entire list of amts with us, as it is delayed evaluation! when the amt is entered, the balance is evaluated :) the output is the balance history

(define A1 (make-simplified-withdraw 20))
(A1 1) ; 19
(A1 5) ; 14
(define A2 (stream-withdraw 20 (cons-stream 1 (cons-stream 5 the-empty-stream))))
(stream-ref A2 1) ; 19
(stream-ref A2 2) ; 14
; (stream-ref A2 5) ; this gives error - in the stream-ref function only, the car causing issue
; mcar: contract violation
;  expected: mpair?
;  given: ()

; now, what if A and Y both want to share the same account, and we want to merge both the streams?
; well we could give turns, so that each one gets a turn and gives to the other...
; but what if one of them doesn't withdraw for ages? the other gets starved :(
; how to ensure fairness here?

; from the concepts of OS, we know "timeout" is a solution... but wait! We got time back when we wanted to get rid of it ;-; sad lyf...
; so finally, _this_ is the limitation of streams. in ensuring fairness type scenarios, it breaks :(

; final thoughts... streams look messy because we aren't really used to handling infinite data structures.
; but they do preserve abstraction barriers and modularity :)
; (wtv that means T-T)













  
