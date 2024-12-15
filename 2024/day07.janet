(use "./aocutils")

(def input-path "input/day07_input.txt")

(defn parse-input [s]
  (def captures (peg/match
    ~{:main (some :entry)
      :entry (group (* :int ":" :terms (? "\n")))
      :terms (group (some (+ :int " ")))
      :int (/ (<- (some :d)) ,int/s64)
      }
    s))
)

(def input (parse-input (readfile input-path)))

(defn find-solution [acc target terms]
  (var result false)
  (match terms
    [head & tail] (each f [+ *] (do
      (def new-acc (f acc head))
      (if (<= new-acc target) (do
        (set result (find-solution new-acc target tail))
        (if result (break))
      ))
    ))
    [] (set result (= acc target))
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

# Part 2

(defn cat [a b]
  (int/s64 (string/join (map string [a b])))
)

(defn find-solution-p2 [acc target terms]
  (var result false)
  (match terms
    [head & tail] (each f [+ * cat] (do
      (def new-acc (f acc head))
      (if (<= new-acc target) (do
        (set result (find-solution-p2 new-acc target tail))
        (if result (break))
      ))
    ))
    [] (set result (= acc target))
  )
  result
)

(defn p2 [input]
  (->>
    input
    (filter
      (fn [entry]
        (def [target terms] entry)
        (def [head & tail] terms)
        (find-solution-p2 head target tail)))
    (map
      (fn [entry] (def [testval _] entry) testval))
    sum
  )
)

(print (p2 input))
