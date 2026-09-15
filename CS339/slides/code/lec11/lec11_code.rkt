#lang sicp
; higher order list functions
; we can write concurrent programs (eg fgpas) with this notation :O
; map-reduce paradigm :D

; 1. fold/reduce/accumulate
(define (foldr f v l) ; fold from the right -> keep applying f to car of the list and the resultant of the accumulation from its cdr.
  ; this doesn't at all contract till the base case, so it then starts at v, applies f on the last element of l and v, then on the 2nd last element of l and the resultant of previous step, and so on
  ; hence it is folding from the right side
  (if (null? l) v (f (car l) (foldr f v (cdr l)))))
(define (foldl f v l) ; fold from the left -> accumulate in the v term from the starting only and keep going. folds from the left therefore, as one would expect
  (if (null? l) v (foldl f (f v (car l)) (cdr l))))

; use of this?
(define sum-list
  (lambda (l)
    (foldr + 0 l)))

(sum-list '(1 4 2 0 7)) ; 14

(define (lengthr l)
  (foldr (lambda (x y) (+ 1 y)) 0 l))

(define (lengthl l)
  (foldl (lambda (x y) (+ 1 x)) 0 l)) ; if this was also y, it would just return 1+the last element of the list!

(lengthr '(1 2 4 2 4 4 3 2 )) ; 8
(lengthl '(1 2 4 2 4 4 3 2 )) ; 8

(define prod-list
  (lambda (l)
    (foldr * 1 l)))

(prod-list '( 1 38 13 73)) ; 36062

; 2. Transforming lists - map a list to another list by applying a common function to all elements
(define (map f l)
  (if (null? l) nil (cons (f (car l)) (map f (cdr l)))))

(define add10
  (lambda (l)
    (map (lambda (x) (+ x 10)) l)))

(add10 '(1 3 15 17 29)) ; (11 13 25 27 39)

;map based functions are usually great candidates for parallelization

; 3. filter lists
(define (filter pred l)
  (if (null? l) nil
      (let ((x (car l)))
        (if (pred x) ; if x satisfies the condition...
            (cons x (filter pred (cdr l))) ; we keep it in the new list we are constructing by consing...
            (filter pred (cdr l)))))) ; else, we ignore it in the new list we are constructing!

(define sum-of-even-squares
  (lambda (l)
    (foldr + 0 (map (lambda (x) (* x x)) (filter even? l)))))

(sum-of-even-squares '(10 3 6 17 8 9 1 13 2)) ; 204

; lists form conventional interfaces

; now when we want to generate a list from something else...
; enumerators - customise to our need

(define (enumerate-interval low high)
  (if (> low high)
      nil
      (cons low (enumerate-interval (+ low 1) high))))

(filter even? (map (lambda (x) (* x x)) (enumerate-interval 1 10))) ; (4 16 36 64 100)

(define (enumerate-tree-leaves l)
   (cond ((null? l) nil) 
        ((not (pair? l)) (list l)) 
        (else (append (enumerate-tree-leaves (car l)) 
                      (enumerate-tree-leaves (cdr l))))))

(foldr + 0 (map (lambda (x) (* x x)) (filter odd? (enumerate-tree-leaves (cons (cons 1 2) (cons (cons 3 4) 5)))))) ; 35





