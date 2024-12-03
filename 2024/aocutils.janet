(defn readlines [path]
  (with [f (file/open path)]
    (->>
      (file/read f :all)
      (string/trim)
      (string/split "\n"))))

(defn getints [s]
  (peg/match
   ~{:main (* (? :sep) :int (any (* :sep :int)) (? :sep))
     :int (/ (<- (some :d)) ,scan-number)
     :sep (some :D)}
    s))