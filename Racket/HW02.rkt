;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW02) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; Chris Hill
; ITEC 380
; Homework 02

(require 2htdp/image)

(define (scale-to-width img reference)
  ;(-> image? image?  image?)
  (cond [(zero? (image-width reference)) empty-image]
        [(zero? (image-width img)) (error 'scale-to-width "Can't scale a 0-width image to a non-0-width.")]
        [else (scale (/ (image-width reference) (image-width img)) img)]))

(check-expect (has-suffix? "compass" "ass") true)
(check-expect (has-suffix? "compass" "lass") false)
(check-expect (has-suffix? "compass" "compass") true)
(check-expect (has-suffix? "compass" "assistant") false)
(check-expect (has-suffix? "pa" "a") true)

; has-suffix? : string, string, -> boolean
; String to check suffix for s1 and suffix s2.
; If the second string is identical to the end of the first string, returns true. Otherwise returns false.
; Example of true input: Maneater and eater

(define (has-suffix? s1 s2)
  (cond [(< (-(string-length s1)(string-length s2)) 0) false] 
        [(string=? s2 (substring s1 (-(string-length s1)(string-length s2)) (string-length s1))) true]
        [ else false]))

(check-expect (donut 21 "brown") (overlay (circle 7 "solid" "white")(circle 21 "solid" "brown")))
(check-expect (donut 3000000 "brown") (overlay (circle 1000000 "solid" "white")(circle 3000000 "solid" "brown")))
(check-expect (donut 1 "brown") (overlay (circle (/ 1 3) "solid" "white")(circle 1 "solid" "brown")))
(check-expect (donut 0 "brown") (overlay (circle 0 "solid" "white")(circle 0 "solid" "brown")))


; donut : positive real, color, -> image
; Size of the donut, size and color, color.
; Creates an image of a donut of size and color specified.

(define (donut size color)
  (overlay (circle (/ size 3) "solid" "white")(circle size "solid" color)))

(check-expect (eyes 21 "brown")(beside (donut 21 "brown") (donut 21 "brown")))
(check-expect (eyes 3 "brown")(beside (donut 3 "brown") (donut 3 "brown")))
(check-expect (eyes 30000000 "brown")(beside (donut 30000000 "brown") (donut 30000000 "brown")))
(check-expect (eyes 0 "brown")(beside (donut 0 "brown") (donut 0 "brown")))


; eyes : positive real, color, -> image
; Size of the eyes, size and color, color.
; Creates an image of a pair of eyes in the size and color specified.

(define (eyes size color)
  (beside (donut size color) (donut size color)))

; super-cool-skin-instructor-meme : string -> image
; String top is the top of the image meme text.
; Creates an image of a South Park ski instructor overlayed with a constant bottom text of "you're gonna have a bad time" and a top line defined by the user.

(check-expect (super-cool-ski-instructor-meme "If you spend all semester making memes,")
              (overlay/align 'center ' bottom
                             (scale-to-width (text "you're gonna have a bad time." 12 'goldenrod)
                                             (bitmap/url "https://imgflip.com/s/meme/Super-Cool-Ski-Instructor.jpg"))
                             (overlay/align 'center 'top (scale-to-width (text "If you spend all semester making memes," 12 'goldenrod)
                             (bitmap/url "https://imgflip.com/s/meme/Super-Cool-Ski-Instructor.jpg"))
                             (bitmap/url "https://imgflip.com/s/meme/Super-Cool-Ski-Instructor.jpg"))))

(define (super-cool-ski-instructor-meme top) (make-meme "https://imgflip.com/s/meme/Super-Cool-Ski-Instructor.jpg" top "you're gonna have a bad time."))

(check-expect (futurama-fry-meme "the image-library is easy" "Java's GUI library is hard") (overlay/align 'center ' bottom
                             (scale-to-width (text (string-append "or " "Java's GUI library is hard") 12 'goldenrod)
                                             (bitmap/url "https://i.imgflip.com/18mq5r.jpg"))
                             (overlay/align 'center 'top (scale-to-width (text (string-append "Not sure if " "the image-library is easy") 12 'goldenrod)
                             (bitmap/url "https://i.imgflip.com/18mq5r.jpg"))
                             (bitmap/url "https://i.imgflip.com/18mq5r.jpg"))))

(check-expect (futurama-fry-meme "Dr. Barland is a pedant" "we're horrible programmers") (overlay/align 'center ' bottom
                             (scale-to-width (text (string-append "or " "we're horrible programmers") 12 'goldenrod)
                                             (bitmap/url "https://i.imgflip.com/18mq5r.jpg"))
                             (overlay/align 'center 'top (scale-to-width (text (string-append "Not sure if " "Dr. Barland is a pedant") 12 'goldenrod)
                             (bitmap/url "https://i.imgflip.com/18mq5r.jpg"))
                             (bitmap/url "https://i.imgflip.com/18mq5r.jpg"))))

; futurama-fry-meme : string, string -> image
; Creates an image of Fry from Futurama overlayed with a constant top text of "Can't tell if" followed by user defined rest of sentence, and overlayed with
; a constant bottom text "or" plus the rest of the sentence defined by the user.
; String top is the top of the image meme text while string bottom is the bottom.


(define (futurama-fry-meme top bottom) (make-meme "https://i.imgflip.com/18mq5r.jpg" (string-append "Not sure if " top) (string-append "or " bottom)))


(check-expect (skeleton-meme "Waiting for" "Dr. Barland's class to be over.") (overlay/align 'center ' bottom
                             (scale-to-width (text "Dr. Barland's class to be over." 12 'goldenrod)
                                             (bitmap/url "https://imgflip.com/s/meme/Waiting-Skeleton.jpg"))
                             (overlay/align 'center 'top (scale-to-width (text  "Waiting for" 12 'goldenrod)
                             (bitmap/url "https://imgflip.com/s/meme/Waiting-Skeleton.jpg"))
                             (bitmap/url "https://imgflip.com/s/meme/Waiting-Skeleton.jpg"))))

; skeleton-meme : string, string -> image
; Creates an image of a skeleton, evidently dead from waiting overlayed with user defined top and bottom text.

(define (skeleton-meme top bottom) (make-meme "https://imgflip.com/s/meme/Waiting-Skeleton.jpg" top bottom))

; make-meme : image, string, string -> image
; Creates a meme image overlayed with text.
; Img is the image to overlay text on, string top is the top meme text, string bottom is the bottom meme text.

(define (make-meme img top bottom)   (overlay/align 'center ' bottom
                             (scale-to-width (text bottom 12 'goldenrod)
                                             (bitmap/url img))
                             (overlay/align 'center 'top (scale-to-width (text top 12 'goldenrod)
                             (bitmap/url img))
                             (bitmap/url img))))

(skeleton-meme "Waiting for" "Dr. Barland's class to be over.")