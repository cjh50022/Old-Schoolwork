;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname T4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;Chris Hill
;Based on the T2 solution provided on D2L.
;https://www.radford.edu/~itec380//2018fall-ibarland/Homeworks/T4.html

(require "student-extras.rkt")
(require "scanner.rkt")
(provide (all-defined-out))
#|
  Expr   ::= Num | Paren | BinOp | parity
  Paren  ::= < Expr >          
  BinOp  ::= # Expr Op  Expr #
  parity ::= even? Expr dope Expr nope Expr dawg
  Op     ::= boii | boi | boiii
|# 

; An Expr is:
;  - a number
;  - (make-paren [Expr])
;  - (make-binop [Op] [Expr] [Expr])
;  - (make-parity  [Expr] [Expr] [Expr])
;  - (make-ifgt [Expr] [Expr] [Expr] [Expr])     ;>>>T1
;  - string (interpretation: Identifier)         ;>>>T2
;  - (make-let-expr [string] [Expr] [Expr])      ;>>>T2
(define OPS (list "boii" "boi" "boiii" "bae"))   ;>>>T1
; An Op is: (one-of OPS)

(define-struct binop (left op right))
(define-struct paren (e))
(define-struct parity (test even-ans odd-ans))
(define-struct ifgt (left right gt-ans le-ans))
(define-struct let-expr (id rhs body))
(define-struct func-expr (argument body)) ;>>>T4
(define-struct func-apply-expr (function argument)) ;>>>T4    

; Examples of Expr:
34
(make-paren 34)
(make-binop 3 "boii" 4)
(make-binop (make-paren 34) "boii"  (make-binop 3 "boiii" 4))
(make-parity 3 7 9)
(make-parity (make-paren 1)
             (make-binop (make-paren 34) "boii"  (make-binop 3 "boiii" 4))
             (make-parity 0 7 9))

(make-binop 7 "bae" 4) ;>>>T1
(make-ifgt 1 2 3 4)    ;>>>T1
"someVar"                                      ;>>>T2
(make-let-expr "x" 3 78)                       ;>>>T2
(make-let-expr "x" 3 (make-binop 7 "bae" 4))   ;>>>T2
(make-let-expr "x" 3 "x")                      ;>>>T2
(make-let-expr "x" 3 (make-binop "x" "bae" 4)) ;>>>T2

; parse! : (scanner OR string) -> Expr
; given a scanner, consume one T2 expression off the front of it
; and
; return the corresponding parse-tree.
;
(define (parse! s)
  ; We use recursive-descent parsing.
  (cond [(string? s) (parse! (create-scanner s))]   ; overload: scanner *or* string.
        [(number? (peek s)) (pop! s)]
        [(string=? "<" (peek s))
         (let* {[_ (pop! s)]   ; consume the "<" from front of `s`
                [the-inside-expr (parse! s)]
                [_ (pop! s)]  ; the closing-bracket
                }
           (make-paren the-inside-expr))]
        [(string=? "#" (peek s))
         (let* {[open-hash (pop! s)]
                [lefty  (parse! s)]
                [_ (if (not (member? (peek s) OPS))
                       (error 'parse "Unknown op " (peek s))
                       'keep-on-going)]
                [op     (pop! s)]
                [righty (parse! s)]
                [close-hash (pop! s)]
                }
           (make-binop lefty op righty))]
        [(string=? "even" (peek s))
         (let* {[_ (pop! s)]   ; throw away the opening "even"
                [_ (pop! s)]   ; throw away the opening "?"
                [the-test (parse! s)]
                [_ (pop! s)]   ; discard "dope"
                [the-even-ans (parse! s)]
                [_ (pop! s)] ; throw away the "nope"
                [the-odd-ans  (parse! s)]
                [_ (pop! s)] ; throw away "dawg"
                }
           (make-parity the-test the-even-ans the-odd-ans))]
        [(string=? "abs" (peek s))                             ;>>>T1 ifgt
         (let* {[_ (pop! s)]   ; throw away the opening "abs"
                [left (parse! s)]                  
                [_ (pop! s)]   ; throw away the "unit"
                [_ (pop! s)]   ; throw away the "?"                  
                [right (parse! s)]                  
                [_ (pop! s)]   ; discard "dope"                  
                [the-gt-ans (parse! s)]                  
                [_ (pop! s)] ; throw away the "nope"                  
                [the-le-ans  (parse! s)]                  
                [_ (pop! s)] ; throw away "dawg"
                }
           (make-ifgt left right the-gt-ans the-le-ans))]                  
        [(string=? "so" (peek s))                              ;>>>T2 let-expr
         (let* {[_ (pop! s)]    ; throw away the opening "so"                  
                [id (parse! s)] ; (we could also call `pop!, since we know it's a single token)
                [_ (pop! s)]   ; throw away the "be"                  
                [_ (pop! s)]   ; throw away the "all"                 
                [rhs (parse! s)]                   
                [_ (pop! s)]   ; discard "in"                  
                [body (parse! s)]                  
                }                   
           (make-let-expr id rhs body))]
        [(string=? (peek s) "meme")   ;>>>T4
         (let* {[_ (pop! s)] 
                [id (pop! s)]
                [_ (pop! s)] 
                [bod (parse! s)]
                }
           (make-func-expr id bod))] 
        [(string=? (peek s) "dank")  ;>>>T4     
         (let* {[_ (pop! s)]  
                [function (parse! s)]
                [_ (pop! s)] 
                [argument (parse! s)]
                }
           (make-func-apply-expr function argument))]
        [(string? (peek s)) (pop! s)]                            ;>>>T2 Id
        [else (error 'parse! (format "syntax error -- something has gone awry!  Seeing ~v" (peek s)))]))

; eval : Expr -> Num
; Return the value which this Expr evaluates to.
; In T2, the only type of value is a Num.

(define (eval e)
  (cond [(number? e) e]
        [(paren? e) (eval (paren-e e))]
        [(binop? e) (let* {[the-op (binop-op e)]
                           [left-val  (eval (binop-left  e))]
                           [right-val (eval (binop-right e))]
                           }
                      (eval-binop the-op left-val right-val))]
        [(parity? e) (if (even? (eval (parity-test e)))
                         (eval (parity-even-ans e))
                         (eval (parity-odd-ans e)))]
        [(ifgt? e)   (if (> (eval (ifgt-left e)) (eval (ifgt-right e)))
                         (eval (ifgt-gt-ans e))
                         (eval (ifgt-le-ans e)))]
        [(let-expr? e) (let* {[v0 (eval (let-expr-rhs e))]                       ;>>>T2 let
                              [e′ (subst (let-expr-id e) v0 (let-expr-body e))]  ;>>>T2 let
                              }                                                  ;>>>T2 let
                         (eval e′))]
        [(func-expr? e) e] ;>>>T4
        [(func-apply-expr? e) (let* {[x (eval (func-apply-expr-function e))] ;>>>T4     
                                     [actual-arg (eval (func-apply-expr-argument e))]
                                     [e′ (subst (func-expr-argument x) actual-arg (func-expr-body x))]
                                     }
                                (eval e′))]
        
        [(string? e) (error 'eval "hey! undefined identifier: " (expr->string e))]  ;>>>T2 Id
        [else (error 'eval "unknown type of expr: " (expr->string e))]))

; eval-binop : op num num -> num
; Implement the binary operators.
(define (eval-binop op l r)
  (cond [(string=? op  "boii") (+ l r)]
        [(string=? op   "boi") (- l r)]
        [(string=? op "boiii") (* l r)]
        [(string=? op   "bae") (let {[q (/ l r)]}          ;>>>T1
                                 (* r (- q (floor q))))]   ;>>>T1
        [else (error 'eval "Unimplemented op " op)]
        ))

(check-expect (eval-binop "boii"  3 2) 5)
(check-expect (eval-binop "boi"   3 2) 1)
(check-expect (eval-binop "boiii" 3 2) 6)

; expr->string : Expr -> string 
; Return a string-representation of `e`.

(define (expr->string e)
  (cond [(number? e) (number->string (if (integer? e) e (exact->inexact e)))]
        [(paren? e) (string-append "<" (expr->string (paren-e e)) ">")]
        [(binop? e) (string-append "#"
                                   (expr->string (binop-left e))
                                   " "
                                   (binop-op e)
                                   " "
                                   (expr->string (binop-right e))
                                   "#"
                                   )]
        [(parity? e) (string-append "even? "
                                    (expr->string (parity-test e))
                                    " dope "
                                    (expr->string (parity-even-ans e))
                                    " nope "
                                    (expr->string (parity-odd-ans e))
                                    " dawg"
                                    )]
        [(ifgt? e) (string-append "abs "                            ;>>>T1
                                  (expr->string (ifgt-left e))      ;>>>T1
                                  " unit? "                         ;>>>T1
                                  (expr->string (ifgt-right e))     ;>>>T1
                                  " dope "                          ;>>>T1
                                  (expr->string (ifgt-gt-ans e))    ;>>>T1
                                  " nope "                          ;>>>T1
                                  (expr->string (ifgt-le-ans e))    ;>>>T1
                                  " dawg"                           ;>>>T1
                                  )]
        [(let-expr? e) (string-append "so "                             ;>>> T2 let
                                      (let-expr-id e)                   ;>>> T2 let
                                      " be all "                        ;>>> T2 let
                                      (expr->string (let-expr-rhs e))   ;>>> T2 let
                                      " in "                            ;>>> T2 let
                                      (expr->string (let-expr-body e))  ;>>> T2 let
                                      )]
        [(func-expr? e) (string-append "meme " ;>>>T4
                                       (func-expr-argument e)
                                       " haz "
                                       (expr->string (func-expr-body e))
                                       )]
        [(func-apply-expr? e) (string-append "dank "   ;>>>T4
                                             (expr->string (func-apply-expr-function e))
                                             " @ "
                                             (expr->string (func-apply-expr-argument e))
                                             )]
        [(string? e) e]                                             ;>>>T2 Id
        [else (error 'expr->string "unknown type of expr: " e)]))

; subst : Id, Num, Expr -> Expr           ;>>>T2                  
; Return an Expr just like `e`, except each occurrence of `id` is replaced with `v`.

(define (subst id v e)                  
  (cond [(number? e) e]                  
        [(paren? e) (make-paren (subst id v (paren-e e)))]                  
        [(binop? e) (make-binop (subst id v (binop-left e))                  
                                (binop-op e)                  
                                (subst id v (binop-right e)))]                  
        [(parity? e) (make-parity (subst id v (parity-test e))                  
                                  (subst id v (parity-even-ans e))                  
                                  (subst id v (parity-odd-ans e)))]                  
        [(ifgt? e) (make-ifgt (subst id v (ifgt-left e))                  
                              (subst id v (ifgt-right e))                  
                              (subst id v (ifgt-gt-ans e))                  
                              (subst id v (ifgt-le-ans e)))]                  
        [(string? e)   (if (string=? id e) v e)]                  
        [(let-expr? e) (make-let-expr (let-expr-id e)
                                      (subst id v (let-expr-rhs e))
                                      (if (string=? id (let-expr-id e))  
                                          (let-expr-body e)
                                          (subst id v (let-expr-body e))))]
        [(func-expr? e) (make-func-expr (func-expr-argument e)   ;>>>T4
                                        (if (string=? id (func-expr-argument e))
                                            (func-expr-body e)
                                            (subst id v (func-expr-body e))))]
        [(func-apply-expr? e) (make-func-apply-expr (subst id v (func-apply-expr-function e)) ;>>>T4
                                                    (subst id v (func-apply-expr-argument e)))]
        [else (error 'subst (format "unknown type of expr: " e))]))

;>>>T2 tests for 'subst'
(require rackunit)
(check-equal? (subst "x" 9 (parse! "3"))   (parse! "3") )
(check-equal? (subst "x" 9 (parse! "x"))   (parse! "9") )
(check-equal? (subst "z" 7 (parse! "x"))   (parse! "x") )
(check-equal? (subst "z" 7 (parse! "#4 boii z#"))   (parse!"#4 boii 7#") )
(check-equal? (subst "z" 7 (parse! "so x be all z in #x boiii z#"))
              (parse! "so x be all 7 in #x boiii 7#"))

;a. so y be all 3 in <so x be all 5 in #x boii y># ⇒ <so x be all 5 in #x boii 3> ⇒ 5 boii 3  ⇒ 8
;b. so y be all 3 in <so x be all y in> #x boii y# ⇒  <so x be all y in> #x boii 3# ⇒ 3 boii 3 ⇒ 6
;c. so x be all 5 in <so y be all 3 in> # <so x be all y in #x boii y# boii x|||| <so y be all 3 in> # <so x be all y in #5 boii y# boii x # # ⇒
;|||# <so x be all y in #5 boii 3# boii x # #⇒ #5 boii 3# boii 3 ⇒ #8 boii 3 ⇒ 11
;d. so x be all 5 in <so x be all #x boii 1# in #x boii 2#> ⇒ <so x be all # 5 boii 1# in # x boii 2#> ⇒ <so x be all 6 in # x boii 2#> ⇒ <# 6 boii 2#> ⇒ 8 <

(check-expect (parse! "so x be all 99 in 50") (make-let-expr "x" 99 50)) ;>>>T3
(check-expect (eval (parse! "so y be all 3 in so x be all 5 in #x boii y#"))8) ;>>>T3
(check-expect (eval (parse! "so x be all 5 in so y be all 3 in # so x be all y in #x boii y# boii x #"))11) ;>>>T3
(check-expect (eval (parse! "so x be all 5 in <so x be all #x boii 1# in #x boii 2#>"))8) ; >>>T3

;1.
;A constant function that always returns (say) 17.
;meme x haz 17

;2.
;the function sqr, which squares its input;

;so sqr 
;be all meme x haz #x boiii x#

;3.
;the factorial function, written in T4
;???

(check-expect (parse! "meme x haz 17") (make-func-expr "x" 17))
(check-expect (expr->string (parse! "meme x haz 17")) "meme x haz 17")
(check-expect (eval(parse! "meme x haz 17")) (make-func-expr "x" 17))

(check-expect (eval(parse! "dank meme x haz 17 @ 9999")) 17)
(check-expect (expr->string (parse! "dank meme x haz 17 @ 9999")) "dank meme x haz 17 @ 9999")
(check-expect (eval(parse! "so sqr be all meme x haz #x boiii x# in dank sqr @ 9")) 81)

(check-expect (eval(parse! "dank meme x haz #x boiii x# @ 9")) 81)
(check-expect (expr->string (parse! "dank meme x haz 17 @ 9999")) "dank meme x haz 17 @ 9999")
(check-expect (eval(parse! "so sqr be all meme x haz #x boiii x# in dank sqr @ 9")) 81)
(check-expect (eval(parse! "so sqr be all meme x haz #x boiii x# in dank sqr @ so x be all 5 in so y be all 3 in # so x be all y in #x boii y# boii x #")) 121)
(check-expect (eval(parse! "so sqr be all meme x haz #x boiii x# in dank sqr @ so x be all 5 in <so x be all #x boii 1# in #x boii 2#>")) 64)
(check-expect (expr->string (parse! "so sqr be all meme x haz #x boiii x# in dank sqr @ so x be all 5 in <so x be all #x boii 1# in #x boii 2#>")) "so sqr be all meme x haz #x boiii x# in dank sqr @ so x be all 5 in <so x be all #x boii 1# in #x boii 2#>")

;Prolog

#|ppg(blossom).
ppg(buttercup).
ppg(bubbles).

tmnt(leonardo).
tmnt(rafael).
tmnt(donatello).
tmnt(michelangelo).

pmon(squirtle). 
pmon(magikarp).
pmon(pikachu).
pmon(meowth).

dbz(goku).
dbz(vegeta).
dbz(piccolo).

villain(mojo-jojo).
villain(meowth).

hero(pikachu).
hero(goku).
hero(C) :- ppg(C).
hero(C) :- tmnt(C).
  
fightsWith(buttercup,fist).
fightsWith(blossom,brain).
fightsWith(bubbles,cat_videos).
fightsWith(leo,shredder).
fightsWith(michelangelo,nunchucks).
fightsWith(mojo-jojo,brain).
fightsWith(squirtle,bubbles).
fightsWith(magikarp,tail).
fightsWith(pikachu,tail).
fightsWith(goku,fist).
fightsWith(vegeta,fist).
fightsWith(piccolo,brain).

color(bubbles,blue).
color(buttercup,green).
color(blossom,red).
color(leonardo,blue).
color(rafael,red).
color(donatello,purple).
color(michelangelo,orange).
color(squirtle,blue).
color(pikachu,yellow).
color(meowth,black).
color(magikarp,red).
color(goku,orange).
color(vegeta,blue).
color(piccolo,green).

snazzyHero(C) :- hero(C), color(C,blue).
bothRed(C1,C2) :- color(C1,red), color(C2,red), C1 \= C2.
clash(C1,C2) :- color(C1, K ), color(C2, K). 

drink(meowth,pepsi).
drink(bubbles,pepsi).

compatible(A,B) :- 
    fightsWith(A, X), fightsWith(B,X), not(A = B); color(A, X), color(B,X), not(A = B).

friendly(A,C) :- 
    compatible(A,B), compatible(B,C).

last([Last], Last).
last([_ | Rest], Last) :- last(Rest, Last).

reverseLastTwo([H1,R1], [H2,R2]) :- H1 = R2, R1 = H2.
reverseLastTwo([Head1 | Rest1],[Head2 | Rest2]) :- reverseLastTwo(Rest1,Rest2).|#