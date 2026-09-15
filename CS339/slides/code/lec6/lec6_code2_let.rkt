#lang sicp
; local names - the special form "let"
(let
    ((a 1)(b 2)); let bindings, created simultaneously
  (+ a b); let body, evaluated with respect to those bindings
  ); 3

(define x 2)
(let ((x 3)(y (+ x 2))) (* x y)) ; 12, (* 3 (+ 2 2)), as let bindings are created simultaneously
; original scheme had let* for sequential let bindings :)

(define (f x y)
  (let ((a (+ 1 (* x y)))
        (b (- 1 y)))
    (+ (* x (* a a)) (* y b) (* a b))))
(f 2 4); 123

; let is a syntactic sugar for lambdas -> arguments are evaluated simultaneously
(define (f1 x y) 
((lambda (a b) 
       (+ (* x (* a a)) 
          (* y b) 
          (* a b))) 
(+ 1 (* x y)) 
     (- 1 y)))
(f1 2 4) ; 123

; lambda lambda everywhere!
((lambda (x y) ; replace the define also!
    ((lambda (a b) 
       (+ (* x ((lambda (x) (* x x)) a)) 
          (* y b) 
          (* a b))) 
     (+ 1 (* x y)) 
     (- 1 y))) 
2 4) ; 123