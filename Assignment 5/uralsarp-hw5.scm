(define get-operator (lambda (op-symbol env)
  (cond
    ((equal? op-symbol '+) +)
    ((equal? op-symbol '*) *)
    ((equal? op-symbol '-) -)
    ((equal? op-symbol '/) /)
    (else 
        (let (
            (dummy15 (display "cs305: ERROR\n\n"))
        )
        (repl env))
    ))))

(define get-value (lambda (var env)
    (cond 
       ( (null? env) (let (
        (dummy23 (display "cs305: ERROR\n\n"))
       )       
       (repl env)
       ) )
       ( (equal? var (caar env)) (cdar env))
       ( else (get-value var (cdr env))))))


(define extend-env (lambda (var val old-env)
        (cons (cons var val) old-env)))

(define define-expr? (lambda (e)
         (and (list? e) (= (length e) 3) (eq? (car e) 'define) (symbol?(cadr e)))))

(define if-stmt? (lambda (e)
        (and (list? e)
        (= (length e) 4)
        (equal? (car e) 'if)
        )
    )
)

(define condition-list? (lambda (e)

    (if (null? e)
        #f
        (if (and (list? (car e)) (= (length (car e)) 2))
            (if (equal? (caar e) 'else)
                (if (null? (cdr e))
                    #t
                    #f
                )
                (condition-list? (cdr e))
            )
            #f
        )
    )
))


(define cond-stmt? (lambda (e)
    (and (list? e)
    (equal? (car e) 'cond)
    (> (length e) 2)
    (condition-list? (cdr e))    
    )
))

(define var-bind-list?
  (lambda (e)
    (if (list? e)
        (if (null? e)
            #t
            (if (and (list? (car e))
                     (= (length (car e)) 2)
                     (symbol? (caar e)))
                (var-bind-list? (cdr e))
                #f))
        #f)))


(define letstar-stmt? (lambda (e)
    (and (list? e)
    (equal? (car e) 'let*)
    (= (length e) 3)
    (list? (cadr e))
    (var-bind-list? (cadr e))
    )
))


(define let-stmt? (lambda (e)
    (and (list? e)
    (equal? (car e) 'let)
    (= (length e) 3)
    (list? (cadr e))
    (var-bind-list? (cadr e))
    )
))


(define repl (lambda (env)
   (let* (
           (dummy1 (display "cs305> "))
           (expr (read))
           (new-env (if (define-expr? expr) 
                        (extend-env (cadr expr) (s7-interpret (caddr expr) env) env)
                        env
                    ))
           (val (if (define-expr? expr)
                    (cadr expr)
                    (s7-interpret expr env)
                ))
           (dummy2 (display "cs305: "))
           (dummy3 (display val))
           (dummy4 (newline))
           (dummy5 (newline))
          )
          (repl new-env))))

(define s7-interpret (lambda (e env)
   (cond
      ( (number? e) e)
      ( (symbol? e) (get-value e env))
      ( (not (list? e)) (let ( 
        (dummy1 (display "cs305: ERROR\n\n"))
      )
        (repl env)
      ))
      

      ((if-stmt? e)
        (if
            (eq? (s7-interpret (cadr e) env) 0)
            (s7-interpret (cadddr e) env)
            (s7-interpret (caddr e) env)
        )
      )
      
      ((cond-stmt? e)
       (if (= (length (cdr e)) 2)

         (if (eq? (s7-interpret (caadr e) env) 0)
           (s7-interpret (car (cdaddr e)) env)
       	   (s7-interpret (cadadr e) env)
         )

         (if (eq? (s7-interpret (caadr e) env) 0) 
           (s7-interpret (cons (car e) (cddr e)) env)
	       (s7-interpret (cadadr e) env)
         )
       )
      )
   
      ((let-stmt? e)
        (let* ((bindings (cadr e))
              (vars (map car bindings))
              (initvals (map cadr bindings))
              (vals (map (lambda (k) (s7-interpret k env)) initvals))
              (new-env (append (map cons vars vals) env)))
          (s7-interpret (caddr e) new-env)))


      ((letstar-stmt? e)
        (let* ((bindings (cadr e))
              (vars (map car bindings))
              (initvals (map cadr bindings))
              (vals (map (lambda (k) (s7-interpret k env)) initvals))
              (new-env (extend-env (caaadr e) (car vals) env)))
          (if (> (length bindings) 1)
              (s7-interpret (list (car e) (cdr bindings) (caddr e)) new-env)
              (s7-interpret (caddr e) new-env))))
      

      (else
         (let ((operands (map s7-interpret (cdr e) (make-list (length (cdr e)) env)))
                (operator (get-operator (car e) env)))
                (apply operator operands))
      )
)))


(define cs305 (lambda () (repl '())))