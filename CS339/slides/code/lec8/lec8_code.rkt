#lang sicp
; church numerals -> apply a function n number of times, to get the nth church numberal
; zero = (lambda f. lambda x x)
; one = (lambda f. lambda x (f x))
; two = (lambda f. lambda x (f (f x)))
; succ = (lambda n. lambda f. lambda x (f ((n f) x)))

; church-int = (lambda n. ((n (lambda (x) (+ x 1))) 0))

(define czero
  (lambda (f)
    (lambda (x) x)))

(define cone
  (lambda (f)
    (lambda (x) (f x))))

(define csucc
  (lambda (n)
    (lambda (f)
      (lambda (x)
        (f ((n f) x))))))

(define cpred
  (lambda (n)
    (lambda (f)
      (lambda (x)
        (((n (lambda (g) (lambda (h) (h (g f)))))
          (lambda (u) x)) ; 
         (lambda (u) u))))))

(define church-int
  (lambda (n)
    ((n (lambda (x) (+ x 1))) 0)))

(church-int czero) ; 0
(church-int (csucc czero)) ; 1
(church-int (cpred (csucc cone))) ; 1
(church-int (cpred cone)) ; 0

; let's beta reduce (cpred cone)
; ((lambda (n) (lambda (f) (lambda (x) (((n (lambda (g) (lambda (h) (h (g f))))) (lambda (u) x)) (lambda (u) u))))) (lambda (f) (lambda (x) (f x))))
; =(alpha)-> =(beta)(lambda (f1) (lambda (x1) ((((lambda (f) (lambda (x) (f x))) (lambda (g) (lambda (h) (h (g f1))))) (lambda (u) x1)) (lambda (u) u))))
; =(beta)(lambda (f1) (lambda (x1) (((lambda (x) ((lambda (g) (lambda (h) (h (g f1)))) x)) (lambda (u) x1)) (lambda (u) u))))
; =(beta)(lambda (f1) (lambda (x1) ((((lambda (g) (lambda (h) (h (g f1)))) (lambda (u) x1)))(lambda (u) u))))
; =(beta)(lambda (f1) (lambda (x1) ((lambda (h) (h ((lambda (u) x1) f1)))(lambda (u) u))))
; =(beta)(lambda (f1) (lambda (x1) ((lambda (h) (h x1))(lambda (u) u))))
; =(beta)(lambda (f1) (lambda (x1) ((lambda (u) u) x1)))
; =(beta)(lambda (f1) (lambda (x1) x1)) = czero :)


; church-plus and church-mult
(define church-plus
  (lambda (m)
    (lambda (n)
      (lambda (f)
        (lambda (x)
          ((m f)((n f) x)))))))
(church-int ((church-plus cone) (csucc cone))) ; 3

(define church-mult
  (lambda (m)
    (lambda (n)
      (lambda (f)
        (lambda (x)
          ((m (n f)) x))))))

(church-int ((church-mult (csucc cone)) (csucc (csucc cone)))) ; 6

; recursion in lambda calculus is hard, because there are no names!
; we have a ~hulk~ Y-combinator
; Y = (lambda f. (lambda x. f (x x)) (lambda x. f (x x)))
; YF = ((lambda x. F(x x))(lambda x. F (x x)))
;    = F((lambda x. F (x x))(lambda x. F (x x)))
;    = F(YF) -> yooo recursion :)

; ((lambda (f) ((lambda (x) (f (x x))) (lambda (x) (f (x x))))) (lambda (f1) (lambda (y) (if (= y 0) 0 (if (= y 1) 1 (+ (f1 (- y 1)) (f1 (- y 2)))))))) - this gives out of memory error, because Y combinator only works in normal order

; so we use the z combinator
; Z = lambda f. (lambda x. (f (lambda v. x x v))(lambda x. (f (lambda v. x x v))
(((lambda (f) ((lambda (x) (f (lambda (v) ((x x) v)))) (lambda (x) (f (lambda (v) ((x x) v)))))) (lambda (f1) (lambda (y) (if (= y 0) 0 (if (= y 1) 1 (+ (f1 (- y 1)) (f1 (- y 2)))))))) 8) ; 21

; let's beta reduce this devilish code
; applicative order - innermost redex first
; (((lambda (f) ([(lambda (x) (f (lambda (v) ((x x) v)))]) (lambda (x) (f (lambda (v) ((x x) v)))))) (lambda (f1) (lambda (y) (if (= y 0) 0 (if (= y 1) 1 (+ (f1 (- y 1)) (f1 (- y 2)))))))) 8)
; =(beta) (((lambda (f) (f (lambda (v) (((lambda (x) (f (lambda (v) ((x x) v)))) (lambda (x) (f (lambda (v) ((x x) v))))) v))) ) (lambda (f1) (lambda (y) (if (= y 0) 0 (if (= y 1) 1 (+ (f1 (- y 1)) (f1 (- y 2)))))))) 8)
; =(beta) (((lambda (f) (f (lambda (v) (f (lambda (v) (((lambda (x) (f (lambda (v) ((x x) v)))) (lambda (x) (f (lambda (v) ((x x) v))))) v)))v))) (lambda (f1) (lambda (y) (if (= y 0) 0 (if (= y 1) 1 (+ (f1 (- y 1)) (f1 (- y 2)))))))) 8)
; got stuck, need help :(

