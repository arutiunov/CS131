#lang racket

(define(null-ld? obj)
  (if (not(pair? obj))
      #f
  (if (eq? (car obj)(cdr obj)) #t #f)))

(define(listdiff? obj)
  (if(not(pair? obj))
      #f
      (let((front(car obj))(rest(cdr obj)))
            (if (eq? front rest)
                #t
                (if(not(pair? front))
                    #f
                    (listdiff? (cons (cdr front) rest)))))))

(define (cons-ld obj listdiff)
  (let((newlistdiff(cons obj (car listdiff))))
    (cons newlistdiff(cdr listdiff))))

(define (car-ld listdiff)
  (if(listdiff? listdiff)
    (if (not(null-ld? listdiff))
        (car (car listdiff))
        (display "error! it is a null list pair (car)!\n"))
    (display "error! it is not a listdiff (car)!\n")))

(define(cdr-ld listdiff)
      (if (not(null-ld? listdiff))
          (let((front(cdr(car listdiff))))
              (cons front(cdr listdiff)))
              (display "error! it is a null list pair (cdr)!\n")))

(define (list->listdiff list)
  (cons list '()))

(define(listdiff current . argument)
  (let((currentList(list current)))
      (let((newList(append(cons current argument) currentList)))
         (cons newList currentList))))

(define(length-ld listdiff)
     (if(listdiff? listdiff)
        (if(not(null-ld? listdiff))
           (let((newHead(cdar listdiff)))
               (+ 1 (length-ld (cons newHead (cdr listdiff)))))
           0)
        (display "error here!\n")))
                            
(define(list-tail-ld listdiff k)
  (if(eq? k 0)
         listdiff 
         (let((lengthListDiff(length-ld listdiff)))
              (if(or(< k 0 ) (> k lengthListDiff))
                 (display "error! k is larger than the length of the listdiff!\n")
                      (let((newValue(- k 1)))
                       (list-tail-ld (cons (cdar listdiff) (cdr listdiff)) newValue))))))

(define(listdiff->list listdiff)
  (if (pair? listdiff)
      (if (eq? (car listdiff) (cdr listdiff))
          '()
          (let ((first (cdr (car listdiff))) (last (cdr listdiff)))
            (cons(caar listdiff)(listdiff->list(cons first last)))))
       (cons (car listdiff)'())))

(define (append-ld . arguments)
    (cons (helper-append-ld arguments) '()))

(define (helper-append-ld list)
    (if(not(null? list))
           (append (listdiff->list (car list)) (helper-append-ld (cdr list)))
           '()))