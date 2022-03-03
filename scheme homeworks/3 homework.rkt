(define (derivative xs)
  (if (null? xs)
      '()
      (cond ((= (length xs) 1) (if (number? (car xs))
                                   '(0)
                                   '(1)))
            ((= (length xs) 2) (cond ((equal? (car xs) 'cos) (if (list? (list-ref xs 1))
                                                                 `(* ,(derivative (list-ref xs 1)) (- (sin ,(list-ref xs 1))))
                                                                 `(- (sin ,(list-ref xs 1)))))
                                     ((equal? (car xs) 'sin) (if (list? (list-ref xs 1))
                                                                 `(* ,(derivative (list-ref xs 1)) (cos ,(list-ref xs 1)))
                                                                 `(cos ,(list-ref xs 1))))
                                     ((equal? (car xs) 'ln) (if (list? (list-ref xs 1))
                                                                `(* ,(derivative (list-ref xs 1)) (/ 1 ,(list-ref xs 1)))
                                                                `(/ 1 ,(list-ref xs 1))))
                                     (else (cons (car xs) (derivative (cdr xs))))))
            ((= (length xs) 3) (cond ((equal? (car xs) '+) (cond ((and (list? (list-ref xs 1)) (list? (list-ref xs 2)))
                                                                  `(+ ,(derivative (list-ref xs 1)) ,(derivative (list-ref xs 2))))
                                                                 ((and (list? (list-ref xs 1)) (not (list? (list-ref xs 2))))
                                                                  `(+ ,(derivative (list-ref xs 1)) ,@(derivative (list (list-ref xs 2)))))
                                                                 ((and (not (list? (list-ref xs 1))) (list? (list-ref xs 2)))
                                                                  `(+ ,@(derivative (list (list-ref xs 1))) ,(derivative (list-ref xs 2))))))
                                     ((equal? (car xs) '-) (cond ((and (list? (list-ref xs 1)) (list? (list-ref xs 2)))
                                                                  `(- ,(derivative (list-ref xs 1)) ,(derivative (list-ref xs 2))))
                                                                 ((and (list? (list-ref xs 1)) (not (list? (list-ref xs 2))))
                                                                  `(- ,(derivative (list-ref xs 1)) ,@(derivative (list (list-ref xs 2)))))
                                                                 ((and (not (list? (list-ref xs 1))) (list? (list-ref xs 2)))
                                                                  `(- ,@(derivative (list (list-ref xs 1))) ,(derivative (list-ref xs 2))))))
                                     ((equal? (car xs) '*) (cond ((and (list? (list-ref xs 1)) (list? (list-ref xs 2)))
                                                                  `(+ (* ,(derivative (list-ref xs 1)) ,(list-ref xs 2)) (* ,(list-ref xs 1) ,(derivative (list-ref xs 2)))))
                                                                 ((list? (list-ref xs 2))
                                                                  `(* ,(list-ref xs 1) ,(derivative (list-ref xs 2))))
                                                                 ((number? (list-ref xs 1))
                                                                  `(* ,(list-ref xs 1) ,@(derivative (list (list-ref xs 2)))))
                                                                 (else `(+ (* ,@(derivative (list (list-ref xs 1))) ,(list-ref xs 2)) (* ,(list-ref xs 1) ,@(derivative (list (list-ref xs 2))))))))
                                     ((equal? (car xs) '/)  (if (list? (list-ref xs 2))
                                                                `(/ (- (* ,@(derivative (list (list-ref xs 1))) ,(list-ref xs 2)) (* ,(list-ref xs 1) ,(derivative (list-ref xs 2)))) (expt ,(list-ref xs 2) 2))
                                                                `(/ (- (* ,@(derivative (list (list-ref xs 1))) ,(list-ref xs 2)) (* ,(list-ref xs 1) ,@(derivative (list (list-ref xs 2))))) (expt ,(list-ref xs 2) 2))))
                                     ((equal? (car xs) 'expt) (cond ((and (number? (list-ref xs 1)) (not (list? (list-ref xs 2)))) `(* (expt ,(list-ref xs 1) ,(list-ref xs 2)) (ln ,(list-ref xs 1))))
                                                                 ((and (number? (list-ref xs 2)) (not (equal? (list-ref xs 1) 'e))) `(* ,(list-ref xs 2) (expt ,(list-ref xs 1) ,(- (list-ref xs 2) 1))))
                                                                 ((and (list? (list-ref xs 2)) (equal? (list-ref xs 1) 'e)) `(* ,(derivative (list-ref xs 2)) (expt e ,(list-ref xs 2))))
                                                                 ((and (list? (list-ref xs 2)) (not (equal? (list-ref xs 1) 'e))) `(* ,(derivative (list-ref xs 2)) (expt ,(list-ref xs 1) ,(list-ref xs 2)) (ln ,(list-ref xs 1))))
                                                                 (else `(expt e ,(list-ref xs 2)))))))
            (else (cond ((equal? (car xs) '+) `(+ ,(derivative (list-ref xs 1)) ,(derivative `(+ ,@(cdr (cdr xs))))))
                        ((equal? (car xs) '-) `(- ,(derivative (list-ref xs 1)) ,(derivative `(- ,@(cdr (cdr xs))))))
                        ((equal? (car xs) '*) `(+ (* ,(derivative (list-ref xs 1)) ,(cdr (cdr xs))) (* ,(list-ref xs 1) ,(derivative `(* (cdr (cdr xs)))))))
                        ((equal? (car xs) 'expt) `(,(derivative `(expt ,(list-ref xs 1) ,(cdr (cdr xs))))))))))) 
                        

;;unit-test
(define-syntax test
  (syntax-rules ()
    ( (test def res )
      (begin
        (let ((xs (quote def))
              (result res))
          (list xs result))))))

(define (run-test xs)
  (newline)
  (write (car xs))
  (let ((have (eval (car xs) (interaction-environment)))
        (want (cadr xs)))
    (if (equal? want have)
        (begin (display "done") #t)
        (begin (display "fail") (newline) (display "wanted: ") (write want) (newline) (display "have: ") (write have) #f))))

(define (run-tests tests)
  (define (loop test1 res)
    (if (null? test1)
        (begin (newline) res)
        (if (run-test (car test1))
            (loop (cdr test1) res)
            (loop (cdr test1) #f))))
  (loop tests #t))

;;derivative tests

(define the-tests
  (list (test (derivative '(2)) '(0))
        (test (derivative '(x))  '(1))
        (test (derivative '(- x)) '(- 1))
        (test (derivative '(* 1 x)) '(* 1 1))
        (test (derivative '(* -1 x)) '(* -1 1))
        (test (derivative '(* -4 x))  '(* -4 1))
        (test (derivative '(* 10 x)) '(* 10 1))
        (test (derivative '(- (* 2 x) 3)) '(- (* 2 1) 0))
        (test (derivative '(expt x 10)) '(* 10 (expt x 9)))
        (test (derivative '(* 2 (expt a 5)))  '(* 2 (* 5 (expt a 4))))
        (test (derivative '(- (* 2 x) 3))  '(- (* 2 1) 0))
        (test (derivative '(expt x -2)) '(* -2 (expt x -3)))
        (test (derivative '(cos x)) '(- (sin x)))
        (test (derivative '(sin x)) '(cos x))
        (test (derivative '(expt e x)) '(expt e x))
        (test (derivative '(* 2 (expt e x))) '(* 2 (expt e x)))
        (test (derivative '(* 2 (expt e (* 2 x)))) '(* 2 (* (* 2 1) (expt e (* 2 x)))))
        (test (derivative '(ln x)) '(/ 1 x))
        (test (derivative '(* 3 (ln x))) '(* 3 (/ 1 x)))
        (test (derivative '(+ (expt x 3) (expt x 2))) '(+ (* 3 (expt x 2)) (* 2 (expt x 1))))
        (test (derivative '(expt 5 (expt x 2))) '(* (* 2 (expt x 1)) (expt 5 (expt x 2)) (ln 5)))
        (test (derivative '(/ 3 (* 2 (expt x 2)))) '(/ (- (* 0 (* 2 (expt x 2))) (* 3 (* 2 (* 2 (expt x 1))))) (expt (* 2 (expt x 2)) 2)))
        (test (derivative '(/ 3 x)) '(/ (- (* 0 x) (* 3 1)) (expt x 2)))
        (test (derivative '(* 2 (* (sin x) (cos x)))) '(* 2 (+ (* (cos x) (cos x)) (* (sin x) (- (sin x))))))
        (test (derivative '(* 2 (* (expt e x) (* (sin x) (cos x))))) '(* 2 (+ (* (expt e x) (* (sin x) (cos x))) (* (expt e x) (+ (* (cos x) (cos x)) (* (sin x) (- (sin x))))))))
        (test (derivative '(cos (* 2 (expt x 2)))) '(* (* 2 (* 2 (expt x 1))) (- (sin (* 2 (expt x 2))))))
        (test (derivative '(sin (ln (expt x 2)))) '(* (* (* 2 (expt x 1)) (/ 1 (expt x 2))) (cos (ln (expt x 2)))))
        (test (derivative '(+ (sin (* 2 x)) (cos (* 2 (expt x 2))))) '(+ (* (* 2 1) (cos (* 2 x))) (* (* 2 (* 2 (expt x 1))) (- (sin (* 2 (expt x 2)))))))
        (test (derivative '(* (sin (* 2 x)) (cos (* 2 (expt x 2))))) '(+ (* (* (* 2 1) (cos (* 2 x))) (cos (* 2 (expt x 2)))) (* (sin (* 2 x)) (* (* 2 (* 2 (expt x 1))) (- (sin (* 2 (expt x 2))))))))))
(run-tests the-tests)
                           
                                                                       
                                                                 
                                     
                                                                 
                                                                  
                                                                 
                                                                 
                                      