(defn readfile [path]
  (with [f (file/open path)] (file/read f :all)))

(defn splitlines [s] (string/split "\n" s))

(defn readlines [path]
  "Read lines as list of strings from file. Trims blank lines at beginning and end."
  (->>
    (readfile path)
    (string/trim)
    (splitlines)))

(defn getints [s]
  "Extract all integers from a string"
  (peg/match
   ~{:main (any (+ :int 1))
     :int (/ (<- (some :d)) ,scan-number)}
    s))

(defn ppn [& xs]
  "Like `pp` but takes variadic arguments and concatenates the result"
  (def fmtstring
    (string/join
      (map
        (fn [x] (if (= (type x) :string) "%s" "%q"))
        xs)))
  (print (string/format fmtstring ;xs)))
