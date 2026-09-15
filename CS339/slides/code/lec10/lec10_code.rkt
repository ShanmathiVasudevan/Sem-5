#lang sicp
; programming with lists

; index a list like an array
(define (get n lst) 
  (cond ((null? lst) nil) 
        ((= n 0) (car lst)) 
        (else (get (- n 1) (cdr lst)))))
; what if we didn't take care of the null condition?
(define (get-not-null n lst)
  (if (= n 0) (car lst)
      (get-not-null (- n 1) (cdr lst))))

(get 3 (list 1 2)) ; ()
; (get-not-null 3 (list 1 2)) - this gives error
; mcdr: contract violation
;  expected: mpair?
;  given: ()
; in a typed language, we can deduce the errors easily and convert the error into something useful

; writing iterative programs as beautifully as recursive ones... how?
; length of a list
(define (length lst) 
  (define (length-iter n lst) 
    (if (null? lst) n 
        (length-iter (+ 1 n) (cdr lst)))) 
  (length-iter 0 lst))

; sum the elements of a list
(define (sum lst) 
  (if (null? lst) 
      0 
(+ (car lst) (sum (cdr lst)))))

; take the first n elements of a list
(define (take n lst) 
  (if (= n 0) 
      nil 
      (cons (car lst) (take (- n 1) (cdr lst)))))

; drop the first n elements of a list
(define (drop n lst) 
  (if (= n 0) 
      lst 
      (drop (- n 1) (cdr lst))))

; insertion sort
(define (insert-sort num lst) ; place a number in its right place in a sorted list
  (cond ((null? lst) (cons num nil)) 
        ((<= num (car lst)) (cons num lst)) 
        (else (cons (car lst) (insert-sort num (cdr lst))))))
(define (isort lst) 
  (if (null? lst) 
    nil 
    (insert-sort (car lst) (isort (cdr lst)))))

; binary search trees :o
(define (make-tree datum left right) ; constructor
  (list datum left right)) 
(define (datum t) (car t)) ; selectors
(define (left-tree t) (cadr t)) 
(define (right-tree t) (caddr t))

(define (insert e t) ; insert into a tree
  (cond ((null? t) (make-tree e nil nil)) 
        ((= e (datum t)) t) 
        ((< e (datum t)) (make-tree (datum t) 
                                    (insert e (left-tree t)) 
                                    (right-tree t))) 
        (else (make-tree (datum t) 
                         (left-tree t) 
                         (insert e (right-tree t))))))

(define (elem? e t) 
  (cond ((null? t) #f) 
        ((= e (datum t)) #t) 
        ((< e (datum t)) (elem? e (left-tree t))) 
        (else (elem? e (right-tree t)))))

(define (inorder-try t) ; ugly!
  (if (null? t) 
      nil 
      (cons (inorder-try (left-tree t)) 
            (cons (datum t) 
                  (inorder-try (right-tree t))))))

(define (concat l1 l2) 
  (if (null? l1) 
      l2 
      (cons (car l1) (concat (cdr l1) l2))))
(define (inorder t) 
  (if (null? t) 
      nil 
      (concat (inorder (left-tree t)) 
              (concat (list (datum t)) 
                      (inorder (right-tree t))))))
(define (list2tree l) 
  (define (l2t-iter t l) 
    (if (null? l) 
        t 
        (l2t-iter (insert (car l) t) (cdr l)))) 
  (l2t-iter (make-tree (car l) nil nil) (cdr l))) 
(define (tree-sort l) 
  (inorder (list2tree l))) 
(define l (list 56 47 89 23 100 27 38))
(define t (list2tree l))
t ; (56 (47 (23 () (27 () (38 () ()))) ()) (89 () (100 () ())))
(inorder-try t) ; (((() 23 () 27 () 38) 47) 56 () 89 () 100) - ah! all these leaves...
(inorder t) ; (23 27 38 47 56 89 100) - much better :)
(tree-sort l) ; (23 27 38 47 56 89 100)

