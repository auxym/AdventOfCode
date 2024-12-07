(use "./aocutils")

(def input-path "input/day03_input.txt")
(def input (readfile input-path))

(defn p1 [s]
  (def mul-exprs (peg/match
    ~{:main (any (+ (group :mul) 1))
      :mul (* "mul(" :int "," :int ")")
      :int (number (some :d))}
    s))

  (sum (map (partial apply *) mul-exprs)))

(pp (p1 input))

# Part 2

(defn p2 [s]
  (def instructions (peg/match
    ~{:main (any (+ (group :mul) :cond 1))
      :mul (* "mul(" :int "," :int ")")
      :int (number (some :d))
      :cond (<- (+ "do()" "don't()"))}
    s))

  (var state true)
  (var result 0)
  (each instr instructions
    (match instr
      "do()"    (set state true)
      "don't()" (set state false)
      @[a b]    (if state (+= result (* a b)))))
  result)

(pp (p2 input))
