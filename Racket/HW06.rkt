;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname HW06) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Chris Hill
; HW06
; https://www.radford.edu/~itec380//2018fall-ibarland/Homeworks/lists/lists.html

(require 2htdp/universe)
(require 2htdp/image)
(require "overlap.rkt")

; count-bigs: real, list-of-real -> natnum
; Takes in a threshold and a list of numbers and determines how many numbers in the list are bigger than the threshold.

(check-expect (count-bigs 7 empty) 0)

(check-expect (count-bigs 7 (cons 5 empty)) 0)
(check-expect (count-bigs 5 (cons 5 empty)) 0)
(check-expect (count-bigs 3 (cons 5 empty)) 1)

(check-expect (count-bigs 7(cons 2 (cons 5 empty))) 0)
(check-expect (count-bigs 3(cons 2 (cons 5 empty))) 1)
(check-expect (count-bigs 2(cons 2 (cons 5 empty))) 1)
(check-expect (count-bigs 1(cons 2 (cons 5 empty))) 2)

(check-expect (count-bigs 7 (cons 10 (cons 2 (cons 5 empty)))) 1)
(check-expect (count-bigs 3 (cons 10 (cons 2 (cons 5 empty)))) 2)

(define (count-bigs threshold nums)
  (cond [(empty? nums)  0]
        [(cons? nums)  (cond [(< threshold (first nums))(+ 1 (count-bigs threshold (rest nums)))]
                             [else (+ 0 (count-bigs threshold (rest nums)))])]))

; map-sqr: real, list-of-real -> natnum
; Takes in a list of numbers and returns the same list of numbers squared.

(check-expect (map-sqr empty)  empty)
(check-expect (map-sqr (cons 7 empty))  (cons 49 empty))
(check-expect (map-sqr (cons 9 (cons 7 empty)))  (cons 81 (cons 49 empty)))

(define (map-sqr nums)
  (cond [(empty? nums) '()]
        [(cons? nums) (cons (* (first nums) (first nums)) (map-sqr (rest nums)))]))

;;;;;;;;;;;;;;;;;
;Space Game part
;;;;;;;;;;;;;;;;;

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
(define WorldMissile (make-missile 0 400 400))


;Template
(define (func-for-missile a-missile)
  (... (missile-direction a-missile)
       ... (missile-ypos a-missile)))


; missile-move : missile -> missile
; Moves a missile by one tick.  
; The direction and x-pos should never change.
; The y-pos will be incremented or decremented by the direction. Increments for positive direction, decrements for negative direction.

;(check-expect (missile-move Missile)(make-missile 1 50 11))
;(check-expect (missile-move SuperMissile)(make-missile 2 50 12))
;(check-expect (missile-move UltraMissile)(make-missile 3 50 13))
;(check-expect (missile-move EnmyMissile)(make-missile -1 50 89))
;(check-expect (missile-move EnmySuperMissile)(make-missile -2 50 88))
;(check-expect (missile-move EnmyUltraMissile)(make-missile -3 50 87))

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
(define Spaceship (make-spaceship 3 270 270))
(define DamagedShip (make-spaceship 1 270 270))

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
(define RightAlien (make-alien 3 51 9))
(define AlienQueen (make-alien 99999999 100 9))

;Template
(define (func-for-alien an-alien)
  (... (alien-health an-alien)
       ... (alien-xpos an-alien)
       ... (alien-ypos an-alien)))

;(make-alien (alien-health (world-alien a-world)) (+ (alien-xpos (world-alien a-world)) 1) (alien-ypos (world-alien a-world))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;New code begin:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; move-alien: alien, integer -> alien
; Moves an alien in the direction of the integer.
; Xpos + integer = new xpos

(check-expect (move-alien Alien 1) (make-alien 3 51 9)) 
(check-expect (move-alien Alien -1) (make-alien 3 49 9)) 
(check-expect (move-alien Alien -50) (make-alien 3 0 9))
(check-expect (move-alien Alien -51) (make-alien 3 -1 9))
(check-expect (move-alien Alien 0) (make-alien 3 50 9))

(define (move-alien an-alien dir)
  (make-alien (alien-health an-alien) (+ (alien-xpos an-alien) dir) (alien-ypos an-alien)))

;Let's create the alien armada.

(define Alien1 (make-alien 3 20 20))
(define Alien2 (make-alien 3 40 40))
(define Alien3 (make-alien 3 60 60))
(define Alien4 (make-alien 3 80 80))
(define Alien5 (make-alien 3 100 100))
(define Alien6 (make-alien 3 120 120))

(define Alien7 (make-alien 3 21 20))
(define Alien8 (make-alien 3 41 40))
(define Alien9 (make-alien 3 61 60))
(define Alien10 (make-alien 3 81 80))
(define Alien11 (make-alien 3 101 100))
(define Alien12 (make-alien 3 121 120))

; Data Definition:
; a LoA ("list-of-aliens is:
;      '(), OR
;      (make-cons [alien] [LoA])

;Examples of the data.

(define Aliens0 '())
(define Aliens1 (cons Alien1 '()))
(define Aliens2 (cons Alien2 (cons Alien1 '())))
(define Aliens3 (cons Alien6 (cons Alien5 (cons Alien4 (cons Alien3 (cons Alien2 (cons Alien1 '())))))))
(define Aliens4 (cons Alien12 (cons Alien11 (cons Alien10 (cons Alien9 (cons Alien8 (cons Alien7 '())))))))

;Template

(define (func-for-aliest a-loa)
  (cond [(empty? a-loa)  ...]
        [(cons? a-loa)   (... (first a-loa) (func-for-aliest (rest a-loa)))]))

;move-aliens : list-of-aliens, integer -> list-of-aliens
;Moves all of the aliens in the list.

(check-expect (move-aliens Aliens0 1) '()) 
(check-expect (move-aliens Aliens1 1) (cons (make-alien 3 21 20) '())) 
(check-expect (move-aliens Aliens2 1) (cons (make-alien 3 41 40) (cons (make-alien 3 21 20) '()))) 
(check-expect (move-aliens Aliens1 -1) (cons (make-alien 3 19 20) '())) 
(check-expect (move-aliens Aliens2 -1) (cons (make-alien 3 39 40) (cons (make-alien 3 19 20) '())))
(check-expect (move-aliens Aliens1 0) (cons (make-alien 3 20 20) '())) 
(check-expect (move-aliens Aliens2 0) (cons (make-alien 3 40 40) (cons (make-alien 3 20 20) '())))

(define (move-aliens a-loa dir)
  (cond [(empty? a-loa) '()]
        [(cons? a-loa) (cons (move-alien (first a-loa) dir) (move-aliens (rest a-loa) dir))]))

; missile-handle-key : missile, spaceship, key-event -> spaceship
; Handles a key.  
; Teleports the missile in front of the ship.
; This has a funny side effect of teleporting a missile back to the player if a missile is attempted to be fired again.
; Oh well, the time to fix that is later.

(check-expect (missile-handle-key Missile Spaceship "up")(make-missile -5 270 265))

(define (missile-handle-key missile spaceship key-event)
  (if (key=? key-event "up") (make-missile -5 (spaceship-xpos spaceship) (- (spaceship-ypos spaceship) 5)) missile)) 

; spaceship-handle-key : spaceship, key-event -> spaceship
; Handles a key.  
; The x-pos will be incremented or decremented depending on the key pressed. Increments for right, decrements for left.

(check-expect (spaceship-handle-key Spaceship "left")(make-spaceship 3 269 270))
(check-expect (spaceship-handle-key Spaceship "right")(make-spaceship 3 271 270))
(check-expect (spaceship-handle-key Spaceship "up")(make-spaceship 3 270 270))

(define (spaceship-handle-key ship key-event)
  (cond [(key=? key-event "left") (make-spaceship (spaceship-health ship) (- (spaceship-xpos ship) 1) (spaceship-ypos ship))]
        [(key=? key-event "right")(make-spaceship (spaceship-health ship) (+ (spaceship-xpos ship) 1) (spaceship-ypos ship))]
        [else ship]))

(define-struct world (spaceship missile aliens dir))

;make-world : spaceship, missile, aliens, dir --> world

;Examples of the data:
(define World (make-world Spaceship WorldMissile Aliens3 1))
(define SimpleWorld (make-world Spaceship WorldMissile Aliens1 1))
(define UpdatedWorld (make-world Spaceship (make-missile 0 400 400) Aliens4 1))
(define RightWorld (make-world (spaceship-handle-key Spaceship "right") WorldMissile Aliens3 1))
(define LeftWorld (make-world (spaceship-handle-key Spaceship "left") WorldMissile Aliens3 1))
(define UpWorld (make-world (spaceship-handle-key Spaceship "up") (make-missile -5 270 265) Aliens3 1))


;Template
(define (func-for-world a-world)
  (... (world-spaceship a-world)
       ... (world-missile a-world)
       ... (world-aliens a-world)
       ... (world-dir a-world)))

; update-world : world -> world
; Updates the world.  
; The x-pos on the alien will be incremented.

(check-expect (update-world World) UpdatedWorld)

(define (update-world a-world)
  (make-world (world-spaceship a-world) (missile-move(world-missile a-world)) (move-aliens (world-aliens a-world) (world-dir a-world)) (world-dir a-world)))

; world-handle-key : world, key-event -> world
; Updates the world when a key is pressed.

(check-expect (world-handle-key World "right") RightWorld)
(check-expect (world-handle-key World "left") LeftWorld)
(check-expect (world-handle-key World "down") World)
(check-expect (world-handle-key World "up") UpWorld)

(define (world-handle-key a-world key-event)
  (make-world (spaceship-handle-key (world-spaceship a-world) key-event) (missile-handle-key (world-missile a-world) (world-spaceship a-world) key-event)
              (world-aliens a-world) (world-dir a-world)))

(define background (rectangle 300 300 "solid" "black"))
(define alienimg (rectangle 15 15 "solid" "red"))
(define shipimg (rectangle 15 15 "solid" "white"))
(define missileimg (rectangle 3 3 "solid" "white"))
(define bkg+alien (place-image alienimg 20 20 background))
(define LeftAlien (make-alien 99999999 -5 9))

;draw-alien : alien, image -> image

; It draws a space alien whose sole goal is to eradicate fellow spacefaring civilizations.
; Due to the destructive power of weapons at this stage of technological development, risk of extinction in confrontation is very high.
; You can never know if any given spacefaring civilization will or will not be hostile before contact.
; Your whole species is on the line, one mistake and it's all over. Forever. Do you want to take that risk? I didn't think so.
; It makes more sense to kill anything you come across lest they kill you first. Out in space it's a dog eat dog world.
; Now kill those aliens before we get hit by a relativistic kill vehicle. 
; Aliens don't exist by the way.

(check-expect (draw-alien Alien background) (place-image alienimg 50 9 background)) 
(check-expect (draw-alien AlienQueen bkg+alien) (place-image alienimg 100 9 bkg+alien)) 
(check-expect (draw-alien LeftAlien background) (place-image alienimg -5 9 background)) 

(define (draw-alien alien bkgr)
  (place-image alienimg (alien-xpos alien) (alien-ypos alien) bkgr))

;draw-spaceship : spaceship, image -> image
;It draws a spaceship, this is what the player controls. Dr. Barland would call this a player, but I have never entered a computer in my life, and I'm the player.

(check-expect (draw-spaceship Spaceship background) (place-image shipimg 270 270 background)) 
(check-expect (draw-spaceship Spaceship background) (place-image shipimg 270 270 background)) 

(define (draw-spaceship ship bkgr)
  (place-image shipimg (spaceship-xpos ship) (spaceship-ypos ship) bkgr))

;draw-missile : missile, image -> image
;Draws a missile.

(check-expect (draw-missile Missile background) (place-image missileimg 50 10 background))

(define (draw-missile a-missile bkgr)
  (place-image missileimg (missile-xpos a-missile) (missile-ypos a-missile) bkgr))

;draw-world : world -> image
;Draws the world.

(check-expect (draw-world SimpleWorld) (place-image shipimg 270 270 bkg+alien)) 

(define (draw-world a-world)
  (draw-missile (world-missile a-world) (draw-spaceship (world-spaceship a-world) (draw-aliens (world-aliens a-world) background))))

;draw-aliens : a-loa, image -> image
;Draws all of the aliens in the list.

(check-expect (draw-aliens '() background) background)
(check-expect (draw-aliens Aliens1 background) (draw-alien Alien1 background))
(check-expect (draw-aliens (cons Alien2 (cons Alien1 '())) background) (draw-alien Alien2 (draw-alien Alien1 background))) 
(check-expect (draw-aliens(cons Alien6 (cons Alien5 (cons Alien4 (cons Alien3 (cons Alien2 (cons Alien1 '())))))) background)
              (draw-alien Alien6 (draw-alien Alien5 (draw-alien Alien4 (draw-alien Alien3 (draw-alien Alien2 (draw-alien Alien1 background))))))) 

(define (draw-aliens a-loa bkgrd)
  (cond [(empty? a-loa) bkgrd]
        [(cons? a-loa) (draw-alien (first a-loa) (draw-aliens (rest a-loa) bkgrd))]))

(define CMissile (make-missile 1 20 20))
(define NCMissile (make-missile 1 100 40))

; alien-collide-missile?: alien, missile -> boolean
; Tells you if an alien collides with a missile.

(check-expect (alien-collide-missile? Alien1 CMissile) #true) 
(check-expect (alien-collide-missile? Alien1 NCMissile) #false) 

(define (alien-collide-missile? alien missile)
  (if (overlap? (alien-xpos alien) (alien-ypos alien) 15 15 (missile-xpos missile) (missile-ypos missile) 3 3)  #true #false))

;aliens-remaining : list-of-alien, missile → list-of-alien

(check-expect (aliens-remaining Aliens2 CMissile) (cons Alien2 '()))
(check-expect (aliens-remaining Aliens2 NCMissile) Aliens2)
(check-expect (aliens-remaining Aliens3 CMissile) (cons Alien6 (cons Alien5 (cons Alien4 (cons Alien3 (cons Alien2 '()))))))
(check-expect (aliens-remaining Aliens3 NCMissile) Aliens3)

(define (aliens-remaining a-loa missile)
  (cond [(empty? a-loa) '()]
        [(cons? a-loa) (cond [(alien-collide-missile? (first a-loa) missile) (rest a-loa)]
                             [else (cons (first a-loa) (aliens-remaining (rest a-loa) missile))])]))

;leftmost : list-of-alien → real
;Returns the x coordinate of the leftmost alien.

(check-expect (leftmost '()) 9999)
(check-expect (leftmost Aliens3) 20)

(define (leftmost a-loa)
  (cond [(empty? a-loa) 9999]
        [(cons? a-loa) (cond [(< (alien-xpos (first a-loa)) (leftmost (rest a-loa))) (alien-xpos (first a-loa))]
                             [else (leftmost (rest a-loa))])]))

;rightmost : list-of-alien → real
;Returns the x coordinate of the rightmost alien.

(check-expect (rightmost '()) -9999)
(check-expect (rightmost Aliens3) 120)

(define (rightmost a-loa)
  (cond [(empty? a-loa) -9999]
        [(cons? a-loa) (cond [(> (alien-xpos (first a-loa)) (rightmost (rest a-loa))) (alien-xpos (first a-loa))]
                             [else (rightmost (rest a-loa))])]))