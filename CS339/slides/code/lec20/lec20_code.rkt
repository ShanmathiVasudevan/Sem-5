#lang sicp
; file by 2.18.AA.26
;; some helper functions from lec 11
(define (filter pred l)
  (if (null? l) nil
      (let ((x (car l)))
        (if (pred x) ; if x satisfies the condition...
            (cons x (filter pred (cdr l))) ; we keep it in the new list we are constructing by consing...
            (filter pred (cdr l)))))) ; else, we ignore it in the new list we are constructing!

(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))

; checking if a number is prime

(define (smallest-divisor n) (find-divisor n 2)) 
(define (find-divisor n test-divisor) 
  (cond ((> (square test-divisor) n) n) 
        ((divides? test-divisor n) test-divisor) 
        (else (find-divisor n (+ test-divisor 1))))) 
(define (square x) (* x x)) 
(define (divides? a b) (= (remainder b a) 0)) 
(define (prime? n) 
  (= n (smallest-divisor n)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; hehe now when we know set, why not count the number of times prime is called to prove our arguments.
(define count 0)
(define (prime-with-count? n)
  (set! count (+ count 1))
  (prime? n))

; Second prime between 10000 and 1000000
(car (cdr (filter prime-with-count? 
                  (enumerate-interval 10000 1000000)))) ;; 10009
count ;;990001
(set! count 0)
;; highly inefficient as we need to create the complete list from 10000 to 1000000 while the actual answer we are looking for doesn't require us to commpute it fully.


;; Streams (God) is here for our rescue

; (cons-stream a b)   ==>   (cons a (delay b))
;(define (cons-stream a b) (cons a (delay b)))
; Commented the above coz scheme is applicative order and writing it explicitily like this will lead us to not use the benefits of streams,
; scheme already has cons-stream and delay and force that are implemented as MACROS, more on this in Lec 21 and Lec 22
; Note - Uncommenting this line is giving output as 990001 at line 76 also, I am not sure what is the reason behind it tho.
(define (stream-car s) (car s))
(define (stream-cdr s) (force (cdr s)))

(define (stream-enumerate-interval low high)
  (if (> low high)
      the-empty-stream
      (cons-stream low (stream-enumerate-interval (+ low 1) high))))

(define (stream-map f s)
  (if (stream-null? s)
      the-empty-stream
      (cons-stream (f (stream-car s)) (stream-map f (stream-cdr s)))))

(define (stream-filter pred s)
  ;(display (stream-car s))
  ;(newline)
  ;; Uncomment these if you want to see for which elements is stream-filter actually called
  (cond ((stream-null? s) the-empty-stream)
        ((pred (stream-car s))
         (cons-stream (stream-car s) (stream-filter pred (stream-cdr s))))
        (else (stream-filter pred (stream-cdr s)))))

(define second-prime
  (stream-car
   (stream-cdr
    (stream-filter prime-with-count?
                   (stream-enumerate-interval 10000 1000000)))))

second-prime  ; 10009
count    ; 10 as the function was called only from 10000....10009
