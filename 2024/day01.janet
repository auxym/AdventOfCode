(use "./aocutils")
(def input-path "input/day01_input.txt")

(defn parse-input [s]
  (def idpairs (map getints s))
  (def result (map array ;idpairs))
  (assert (= (length result) 2))
  (assert (=
    (length (result 0))
    (length (result 1))))
  result)

(defn p1 [input]
  (->> input
    (map sorted)
    (apply (partial map array))
    (map (partial apply -))
    (map math/abs)
    (sum))
)

(def input (parse-input (readlines input-path)))
(print (p1 input))

# Part 2

(defn p2 [input]
  (def [left right] input)
  (def right-counts (frequencies right))
  (sum (map
    (fn [lv] (* lv (get right-counts lv 0)))
    left))
)

(print (p2 input))
