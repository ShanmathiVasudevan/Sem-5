#lang sicp
(define (filter pred l)
  (if (null? l)
      nil
      (let ((x (car l)))
        (if (pred x)
            (cons x (filter pred (cdr l)))
            (filter pred (cdr l))))))

(define (map f l)
  (if (null? l)
      nil
      (cons (f (car l)) (map f (cdr l)))))

(define (foldr f v l)
  (if (null? l) v
      (f (car l)(foldr f v (cdr l)))))

(define (foldl f v l)
  (if (null? l) v
      (foldl f (f v (car l)) (cdr l))))

(define (oink l)
  (foldr cons (map (lambda (x) (* x x)) (filter even? l)) (map (lambda (x) (* x x)) (filter odd? l))))

(oink (list 1 2 7 5 3 7 4 6 3 4 5))