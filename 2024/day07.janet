(use "./aocutils")
(import pat)

(def input-path "input/day07_input.txt")

(defn parse-input [s]
  (def captures (peg/match
    ~{:main (some :entry)
      :entry (group (* :int ":" :terms (? "\n")))
      :terms (group (some (+ :int " ")))
      :int (number (some :d))
      }
    s))
)

#(def input (parse-input (readfile input-path)))
#(def input (parse-input "190: 10 19"))
#(def input (parse-input "3267: 81 40 27"))
(def input (parse-input
``190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
``))

(each e input (pp e))
(print "")

(defn find-solution [acc target terms]
  (var result false)
  #(ppn "acc " acc)
  #(ppn "terms " terms)
  #(ppn "target " target)
  (pat/match terms
    [x] (each f [+ *] (do
      #(ppn "terminal, x = " x "f: " f)
      (set result (= (f acc x) target))
      #(pp result)
      (if result (break))
    ))
    [head & tail] (each f [+ *] (do
      (def new-acc (f acc head))
      (if (< new-acc target) (do
        #(ppn "recurse acc=" new-acc " f: " f)
        (set result (find-solution new-acc target tail))
        (if result (break))
      ))
    ))
  )
  result
)

(defn p1 [input]
  (->>
    input
    (filter
      (fn [entry]
        (def [target terms] entry)
        (def [head & tail] terms)
        (find-solution head target tail)))
    (map
      (fn [entry] (def [testval _] entry) testval))
    sum
  )
)

(print (p1 input))
