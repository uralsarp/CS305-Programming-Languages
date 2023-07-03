(define check-triple?
  (lambda (tripleList)
    (if (null? tripleList)
        #t
        (if (not (and (= (length (car tripleList)) 3)
                      (integer? (car (car tripleList)))
                      (integer? (cadr (car tripleList)))
                      (integer? (caddr (car tripleList)))))
            #f
            (check-triple? (cdr tripleList))))))

(define check-length?
  (lambda (inTriple count)
    (= (length inTriple) count)))

(define check-sides?
  (lambda (inTriple)
    (and (integer? (car inTriple)) (> (car inTriple) 0)
         (integer? (cadr inTriple)) (> (cadr inTriple) 0)
         (integer? (caddr inTriple)) (> (caddr inTriple) 0))))

(define sort-all-triples
  (lambda (tripleList)
    (if (null? tripleList)
        '()
        (cons (sort-triple (car tripleList))
              (sort-all-triples (cdr tripleList))))))


(define sort-triple
  (lambda (inTriple)
    (cond ((< (car inTriple) (cadr inTriple))
           (if (< (cadr inTriple) (caddr inTriple))
             (list (car inTriple) (cadr inTriple) (caddr inTriple))
             (if (< (car inTriple) (caddr inTriple))
               (list (car inTriple) (caddr inTriple) (cadr inTriple))
               (list (caddr inTriple) (car inTriple) (cadr inTriple)))))
          (else
           (if (< (car inTriple) (caddr inTriple))
             (list (cadr inTriple) (car inTriple) (caddr inTriple))
             (if (< (cadr inTriple) (caddr inTriple))
               (list (cadr inTriple) (caddr inTriple) (car inTriple))
               (list (caddr inTriple) (cadr inTriple) (car inTriple))))))))

(define filter-triangle
  (lambda (tripleList)
    (cond ((null? tripleList) '())
          ((> (+ (car (car tripleList)) (cadr (car tripleList))) (caddr (car tripleList)))
           (cons (car tripleList) (filter-triangle (cdr tripleList))))
          (else (filter-triangle (cdr tripleList)))))) 

(define filter-pythagorean
  (lambda (tripleList)
    (cond ((null? tripleList) '())
          ((= (+ (* (car (car tripleList)) (car (car tripleList)))
                 (* (cadr (car tripleList)) (cadr (car tripleList))))
              (* (caddr (car tripleList)) (caddr (car tripleList))))
           (cons (car tripleList) (filter-pythagorean (cdr tripleList))))
          (else (filter-pythagorean (cdr tripleList))))))

(define triangle?
  (lambda (triple)
    (> (+ (car triple) (cadr triple)) (caddr triple))))


(define pythagorean-triangle?
  (lambda (triple)
    (= (+ (* (car triple) (car triple))
          (* (cadr triple) (cadr triple)))
       (* (caddr triple) (caddr triple)))))

(define get-area
  (lambda (triple)
    (/ (* (car triple) (cadr triple)) 2)))

(define sort-area
  (lambda (tripleList)
    (if (null? tripleList)
        '()
        (insert-sort-triples (car tripleList) (sort-area (cdr tripleList))))))

(define insert-sort-triples
  (lambda (triple sortedList)
    (if (null? sortedList)
        (list triple)
        (if (< (get-area triple) (get-area (car sortedList)))
            (cons triple sortedList)
            (cons (car sortedList) (insert-sort-triples triple (cdr sortedList)))))))

(define main-procedure
  (lambda (tripleList)
    (if (or (null? tripleList) (not (list? tripleList)))
      (error "ERROR305: the input should be a list full of triples")
      (if (check-triple? tripleList)
        (sort-area (filter-pythagorean (filter-triangle
        (sort-all-triples tripleList))))
          (error "ERROR305: the input should be a list full of triples")
      )
    )
  )
)

