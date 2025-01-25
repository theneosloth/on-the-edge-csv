(require 'asdf)
(in-package :cl-user)
(asdf:load-systems :parseq :alexandria :serapeum :arrow-macros :transducers :com.inuoe.jzon :cl-csv)
(defpackage cl-ote-parser
  (:use :cl :arrow-macros)
  (:local-nicknames (:p :parseq) (:alexandria :alexandria) (:serapeum :serapeum) (:transducers :transducers) (:jzon :com.inuoe.jzon)))

(in-package :cl-ote-parser)


(p:defrule space () (* #\Space) (:constant t))
(p:defrule ws () (* (or #\Space #\Newline #\Linefeed #\Return)) (:constant t))
(p:defrule nl () (or #\Linefeed #\Return) (:constant t))

(p:defrule name () (+
                    (or
                     ;; Need an exception for Brownshirt (2)
                     "(2)"
                     #\Space
                     (char "\"?0-9a-zA-Z',-:& ")))
  (:string)
  (:function #'serapeum:trim-whitespace))

(p:parseq 'name "            Atlanteans' Secret    " :parse-error t)
(p:parseq 'name "Brownshirt (2)" :parse-error t)

(p:defrule num () (+
                   (or
                    (char ",+.*=0-9-")
                    #\VULGAR_FRACTION_ONE_HALF))
  (:string))
(assert (p:parseq 'num "-"))
(assert (p:parseq 'num "0"))

(p:defrule cost () num)
(p:defrule power () num)
(p:defrule defense () num)
(p:defrule pull () num)

(p:defrule header () (and
                          space
                          "ON THE EDGE© CARD RULE SPOILER"
                          ws
                          "[INLINE]"
                          ws
                          )
  (:constant t))

(p:defrule footer () (and
                      "© On the Edge is a trademark of Trident Inc. Over the Edge, Al Amarja,"
                      (* form)))

(p:defrule set () (and
                 #\(
                 (+ (char "A-z0-9"))
                 #\)
                 ) (:choose 1) (:string))

(p:parseq 'set "(A032)" :parse-error t)

(p:defrule traits () (+ (char "a-z -")) (:string))
(p:parseq 'traits "hu - ac - at" :parse-error t)

(p:defrule type () (+ (char "A-Z/")) (:string))

(p:defrule stats () (and cost "/" power "/" defense "/" pull) (:choose 0 2 4 6))

(p:parseq 'stats "3/-/½/-" :parse-error t)

(p:defrule card-header () (and
                  name
                  space
                  set
                  space
                  stats
                  space
                  type
                  (? (and
                      " - "
                      traits))
                  (* #\Space)
                  (* nl)
                  )(:choose 0 2 4 6 '(7 1)))

(p:parseq 'card-header "Cabal's Story, The (A002) 0/-/-/- SECR - cb" :parse-error t)
(p:parseq 'card-header "Deal With Sub-Randomness, The (C01) 0/-/-/- SECR" :parse-error t)
(p:parseq 'card-header "Rigor Kwasek (135) 0/1/1/* CHAR - hu - ac - at" :parse-error t)
(defun replace-newlines (str)
  (->> str
      (substitute #\Space #\Return)
    (substitute #\Space #\Newline)))

(p:defrule rule-line () (and
                         (+ #\Space)
                         (+ (not nl))
                         (* nl))
  (:choose 1)
  (:flatten)
  (:string))

(p:parseq 'rule-line "          Crank for 4 Pull to call Atlantean cards or 1 Pull to call." :parse-error t)

(p:defrule rules ()
    (+ rule-line)
  (:lambda (&rest strings)
    (-<>> strings
      (serapeum:string-join <> " ")
      (serapeum:trim-whitespace))))



(defparameter *carriage*
  "           Crank for 4 Pull to call Atlantean cards or 1 Pull to call
            Psychic cards. Crank to add +1 to any attack of an Atlantean.")

(p:parseq 'rules *carriage* :parse-error t)

(p:defrule card () (and card-header (? rules) ws) (:choose 0 1))
(defparameter *card* "   Atlanteans' Secret (A001) 0/-/-/- SECR - ae
          Crank for 4 Pull to call Atlantean cards or 1 Pull to call
            Psychic cards. Crank to add +1 to any attack of an Atlantean.")

(p:parseq
          'card
          *card* :parse-error t)

(p:defrule grammar ()
    (and
     header
     (+ card)
     footer)
  (:choose 1))

(defparameter *ote* (alexandria:read-file-into-string "ontespoa.txt" :external-format :iso-8859-1))
(p:parseq 'grammar *ote*)
(defclass card ()
  ((name :initarg :name :accessor name)
   (setcode :initarg :setcode :accessor setcode)
   (cost :initarg :cost :accessor cost)
   (power :initarg :power :accessor power)
   (defense :initarg :defense :accessor defense)
   (pull :initarg :pull :accessor pull)
   (ctype :initarg :type :accessor ctype)
   (traits :initarg :traits :accessor traits :initform nil)
   (rules :initarg :rules :accessor rules)))

()
(serapeum:-> expand-traits (string) string)
(defun expand-traits (trait)
  (let ((names
          (serapeum:dict
           "aa" nil
           "ac" "Academic"
           "ad" nil
           "ae" "Aries"
           "ag" nil
           "ai" nil
           "al" nil
           "as" "Astral"
           "at" "Artist"
           "bu" "Burger"
           "ca" nil
           "cb" nil
           "ci" "C&I"
           "cl" "Cloak"
           "co" nil
           "cr" nil
           "cr" nil
           "ct" nil
           "cu" nil
           "da" nil
           "do" nil
           "en" nil
           "fo" nil
           "fr" "Fringe"
           "gg" "Glug"
           "gr" "Glorious lords"
           "gs" "Gladstein"
           "gv" "Government"
           "ha" nil
           "he" "Hermetic"
           "hu" "Human"
           "ke" nil
           "la" nil
           "lo" nil
           "lt" nil
           "lu" nil
           "mc" nil
           "mu" nil
           "ne" "Net"
           "nt" nil
           "ph" nil
           "ps" "Psychic"
           "sa" nil
           "sn" nil
           "sr" nil
           "th" nil
           "tr" "Trident"
           "tt" nil
           "we" nil
           )))
    names))

(defmethod print-object ((it card) stream)
  (print-unreadable-object (it stream)
    (format stream "~a, (~a) ~a/~a/~a/~a ~a ~a~%~a"
            (name it)
            (setcode it)
            (cost it)
            (power it)
            (defense it)
            (pull it)
            (ctype it)
            (traits it)
            (rules it))))

(defmethod to-list ((it card))
  (with-slots (name setcode cost power defense pull ctype traits rules)
      it
    (list name setcode cost power defense pull ctype traits rules)))

(defun to-card (parsed)
  (destructuring-bind
      ((name setcode (cost power defense pull) type traits) rules)
      parsed
    (make-instance 'card
                   :name name
                   :setcode setcode
                   :cost cost
                   :power power
                   :defense defense
                   :pull pull
                   :type type
                   :traits traits
                   :rules  rules)))


(defun grab-all-cards ()
    (let ((parsed (p:parseq 'grammar *ote* :parse-error t)))
      (transducers:transduce
       (transducers:map
        #'to-card)
       #'transducers:cons
       parsed)))

(cl-csv:write-csv 
 (transducers:transduce (transducers:map #'to-list) #'transducers:cons (grab-all-cards))
 :separator #\Tab
 :stream #P"out.tsv")
