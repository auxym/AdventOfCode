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

(def input (parse-input (readfile input-path)))

(defn find-solution [acc target terms]
  (var result false)
  (pat/match terms
    [x] (each f [+ *] (do
      (set result (= (f acc x) target))
      (if result (break))
    ))
    [head & tail] (each f [+ *] (do
      (def new-acc (f acc head))
      (if (<= new-acc target) (do
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
