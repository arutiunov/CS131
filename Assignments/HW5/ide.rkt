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


(define ils (append '(a e i o u) 'y))
(define d1 (cons ils (cdr (cdr ils))))
(define d2 (cons ils ils))
(define d3 (cons ils (append '(a e i o u) 'y)))
(define d4 (cons '() ils))
(define d5 0)
(define d6 (listdiff ils d1 37))
(define d7 (append-ld d1 d2 d6))

display "testing listdiff?\n"

(listdiff? d1)                         
(listdiff? d2)                         
(listdiff? d3)                         
(listdiff? d4)                         
(listdiff? d5)                         
(listdiff? d6)
(listdiff? d7)  

display "testing null-ld\n"

(null-ld? d1)                          
(null-ld? d2)                          
(null-ld? d3)                          
(null-ld? d6)

display "testing car-ld\n"

(car-ld d1)                            
(car-ld d2)                            
(car-ld d3)                            
(car-ld d6)                            

display "testing length-ld\n"

(length-ld d1)                         
(length-ld d2)                         
(length-ld d3)                         
(length-ld d6)                         
(length-ld d7)

(define kv1 (cons d1 'a))
(define kv2 (cons d2 'b))
(define kv3 (cons d3 'c))
(define kv4 (cons d1 'd))
(define d8 (listdiff kv1 kv2 kv3 kv4))
(define d9 (listdiff kv3 kv4))

display "testing list-tail-ld\n"

(eq? d8 (list-tail-ld d8 0))
(equal? (listdiff->list (list-tail-ld d8 2)) (listdiff->list d9))
(null-ld? (list-tail-ld d8 4))
(list-tail-ld d8 -1)
(list-tail-ld d8 5)

display "testing car-ld and cdr-ld\n"
  
(eq? (car-ld d6) ils)
(eq? (car-ld (cdr-ld d6)) d1) 
(eqv? (car-ld (cdr-ld (cdr-ld d6))) 37) 
(equal? (listdiff->list d6)(list ils d1 37)) 
(eq? (list-tail (car d6) 3) (cdr d6))
 