;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW04) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;Chris Hill
;HW04
;https://www.radford.edu/~itec380//2018fall-ibarland/Homeworks/structs/structs.html

;Part 1:

;Data definition:
(define-struct team (name offense defence))
;make-team : string, natural, natural --> team

;Examples of the data:
(define RedT (make-team "Red Team" 100 40))
(define BlueT (make-team "Blue Team" 50 90))
(define GreenT (make-team "Green Team" 70 70))
(define PinkT (make-team "Pink Team" 30 30))
(define ClearT (make-team "Clear Team" 0 0))
(define GoldT (make-team "Gold Team" 100 100))
(define TraitorT (make-team "Help the Other Team" -100 -100))
(define DecimalT (make-team "Decimal Team" 70.5 70.5))

;Template:

(define (func-for-team a-team)
  (... (team-name a-team)
   ... (team-offense a-team)
   ... (team-defence a-team)))

;Part 2: 

; team>? : team, team -> boolean
; Determines whether the first team is better than the second team.
; If team one has higher offense than the opposing team's defense AND
; it has higher defense than the opposing team's offense, it is considered greater.

(check-expect (team>? GoldT ClearT) #true)
(check-expect (team>? GoldT GoldT) #false)
(check-expect (team>? RedT BlueT) #false)
(check-expect (team>? RedT GreenT) #false)
(check-expect (team>? RedT PinkT) #true)
(check-expect (team>? BlueT PinkT) #true)
(check-expect (team>? DecimalT GreenT) #true)
(check-expect (team>? TraitorT ClearT) #false)
(check-expect (team>? TraitorT RedT) #false)
(check-expect (team>? ClearT PinkT) #false)

(define (team>? t1 t2)
  (and(> (team-offense t1) (team-defence t2)) (> (team-defence t1) (team-offense t2))))

;Part 4 (Part 3 is in Java):

;Data definition:
(define-struct missile (direction xpos ypos))
;make-missile : integer, natural, natural --> missile

;Direction is represented by a positive or negative integer. A negative integer means it's fired by an enemy as it's moving south on the y plane.
;A positive direction means it's fired by the player.
;Xpos is position on the x plane, this shouldn't ever change.
;Ypos is position on the y plane.

;Examples of the data:
(define Missile (make-missile 1 50 10))
(define SuperMissile (make-missile 2 50 10))
(define UltraMissile (make-missile 3 50 10))
(define EnmyMissile (make-missile -1 50 90))
(define EnmySuperMissile (make-missile -2 50 90))
(define EnmyUltraMissile (make-missile -3 50 90))

;Template
(define (func-for-missile a-missile)
  (... (missile-direction a-missile)
   ... (missile-ypos a-missile)))


; missile-move : missile -> missile
; Moves a missile by one tick.  
; The direction and x-pos should never change.
; The y-pos will be incremented or decremented by the direction. Increments for positive direction, decrements for negative direction.

(check-expect (missile-move Missile)(make-missile 1 50 11))
(check-expect (missile-move SuperMissile)(make-missile 2 50 12))
(check-expect (missile-move UltraMissile)(make-missile 3 50 13))
(check-expect (missile-move EnmyMissile)(make-missile -1 50 89))
(check-expect (missile-move EnmySuperMissile)(make-missile -2 50 88))
(check-expect (missile-move EnmyUltraMissile)(make-missile -3 50 87))

(define (missile-move a-missile)
  (make-missile (missile-direction a-missile) (missile-xpos a-missile) (+ (missile-ypos a-missile) (missile-direction a-missile))))

;Part 5

;Data definition:
(define-struct spaceship (health xpos ypos))
;make-spaceship : natural, natural, natural --> spaceship

;Health is the amount of hits the ship can take. Call it lives if you will, but health seems better to me.
;Xpos is position on the x plane
;Ypos is position on the y plane, this shouldn't ever change.

;Examples of the data:
(define Spaceship (make-spaceship 3 50 9))
(define DamagedShip (make-spaceship 1 50 9))

;Template
(define (func-for-spaceship a-spaceship)
  (... (spaceship-health a-spaceship)
   ... (spaceship-xpos a-spaceship)))

;Data definition:
(define-struct alien (health xpos ypos))
;make-alien : natural, natural, natural --> spaceship

;Health is the amount of hits the alien can take.
;Xpos is position on the x plane
;Ypos is position on the y plane

;Examples of the data:
(define Alien (make-alien 3 50 9))
(define AlienQueen (make-alien 99999999 50 9))
 
;Template
(define (func-for-alien an-alien)
  (... (alien-health an-alien)
   ... (alien-xpos an-alien)
   ... (alien-ypos an-alien)))