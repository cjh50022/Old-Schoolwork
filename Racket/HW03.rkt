;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW03) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Chris Hill
; Homework 03
; https://www.radford.edu/~itec380//2018fall-ibarland/Homeworks/union-types/union-types.html

;; Data definition: A "game-result" is one of:
;;    - a win (#true) and a loss (#false)
;;    - a symbol, Tie
;;    - a message explaining that there was no game
;;    - a team name, if a game is currently in progress

;; Data examples:
;; #true
;; #false
;; "No game."
;; "Tie."
;; "Brown Badgers"


(define (func-for-game-result a-gr)
  (cond [(boolean? a-gr)  (cond [(equal? #true a-gr)  ...]
                                [(equal? #false a-gr)  ...])]
        [(symbol? a-gr) (cond [(equal? 'Tie a-gr) ...]
                              [(equal? 'NoGame a-gr) ...])]
        [(string? a-gr)  ...]))

; payout : positive real number, game-result -> positive real number
; Determines how much is paid out based on the result of a game and the bet made.
; If there's a win, 190% of the money is returned. A loss and no money is returned.
; In progress game? Nothing (yet). Tie, 90% of the money is returned. No game, 100% of money returned.

(check-expect (payout 0 #true) 0)
(check-expect (payout 100 #true) 190)
(check-expect (payout 105.5 #true) 200.45)
(check-expect (payout 100 #false) 0)
(check-expect (payout 100 'Tie) 90)
(check-expect (payout 100 "Brown Badgers") 0)
(check-expect (payout 100 'NoGame) 100)


(define (payout bet a-gr)
  (cond [(boolean? a-gr)  (cond [(equal? #true a-gr)  (* bet 1.90)]
                                [(equal? #false a-gr)  0])]
        [(symbol? a-gr) (cond [(equal? 'Tie a-gr)  (* bet 0.90)]
                              [(equal? 'NoGame a-gr)  bet])]
        [(string? a-gr)  0]))

; game-result->string: game-result -> string
; Returns a game result as a string.
; If there's a win, returns "The Radford Highlanders won." A loss and "The Radford Highlanders lost." A tie. "The game resulted in a tie."
; In progress game? Name of the team being played. No game and returns "There is no game."

(check-expect (game-result->string #true) "The Radford Highlanders won.")
(check-expect (game-result->string #false) "The Radford Highlanders lost.")
(check-expect (game-result->string 'Tie) "The game resulted in a tie.")
(check-expect (game-result->string "Brown Badgers") "The Radford Highlanders are currently playing the Brown Badgers")
(check-expect (game-result->string 'NoGame) "There is no game.")

(define (game-result->string a-gr)
  (cond [(boolean? a-gr)  (cond [(equal? #true a-gr)  "The Radford Highlanders won."]
                                [(equal? #false a-gr)  "The Radford Highlanders lost."])]
        [(symbol? a-gr) (cond [(equal? 'Tie a-gr) "The game resulted in a tie."]
                              [(equal? 'NoGame a-gr) "There is no game."])]
        [(string? a-gr)  (string-append "The Radford Highlanders are currently playing the " a-gr)]))