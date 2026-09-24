#lang sicp

; copy pasted from moodle
; as we saw in the last lecture, the below code line
;(define (cons-stream a b) (cons a (delay b)))
; has a problem - due to eager evaluation of arguments / applicative order of evaluation, the expression inside delay gets evaluated anyway, leading to no advantage of streams :(

; remember how delay is defined earlier:
; (delay <expr>) => (lambda() <expr>)
; we end up evaluating <expr> anyway though, before substituting it in delay :(
; not only that, but in cons-stream itself you will evaluate both a and b anyway. too eager! cashewnut.

; How can we fix this ;-;
; 2 ways:
; make macros - why? so that we can just substitute "(lambda () <expr>)" in place of "(delay <expr>)", without any evaluation of <expr>
;               now, <expr> won't be evaluated! yay!!
;               also need to do this for cons-stream so that b isn't evaluated as well.
; make Scheme lazy - normal form of evaluation fixes everything, but how to change this in scheme? suspense.....

; anyway :)

;(define (delay expr) (lambda() expr))
;delay ;#<procedure:delay>

(define-syntax delay ; way to add special forms :) define-syntax creates the binding <delay, the syntax-rules>
  (syntax-rules () ; this is called a syntax transformer
    ((delay expr) (lambda () expr))))
; here, (delay expr) is the rule's pattern and the (lambda () expr) is the rule's template. the syntax transformer makes it like a macro - just does pattern matching and replaces the pattern variables to the actual expressions

; delay ; delay: bad syntax in: delay
(delay (+ 3 1)); ; #<procedure:...ec21/lec21_code.rkt:31:0> 
((delay (+ 3 1))); 4

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

(define (prime? n)
  (define (divides? a b) (= (remainder b a) 0))
  (define (smallest-divisor n) (find-divisor n 2))
  (define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))
  (= n (smallest-divisor n)))

(car (cdr
      (filter prime?
              (enumerate-interval 10000 1000000)))) ; 10009

(stream-car (stream-cdr
              (stream-filter
                prime?
                  (stream-enumerate-interval 10000 1000000)))) ; 10009

; the previous things are using finite streams. Now let's create infinite streams :)

(define (integers-starting-from n)
  (cons-stream n (integers-starting-from (+ n 1))))
(define integers (integers-starting-from 1))
integers ; (1 . #<procedure:...ec21/lec21_code.rkt:36:31>)
; this is an infinite stream!

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))
(stream-ref integers 10) ; 11

(define (divisible? x y) (= (remainder x y) 0))
   
(define nd5
  (stream-filter
   (lambda (x) (not (divisible? x 5)))
   integers))

(stream-ref nd5 15) ; 19