(defn readfile [path]
  (with [f (file/open path)] (file/read f :all)))

(defn splitlines [s] (string/split "\n" s))

(defn readlines [path]
    (->>
      (readfile path)
      (string/trim)
      (splitlines)))

(defn getints [s]
  (peg/match
   ~{:main (* (any (+ :int 1)))
     :int (/ (<- (some :d)) ,scan-number)}
    s))