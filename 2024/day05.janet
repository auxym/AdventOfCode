
(use "./aocutils")

(def input-path "input/day05_input.txt")

(defn parse-input [s]
  (def parts (string/split "\n\n" (string/trim s)))
  (assert (= (length parts) 2))

  (def rules (map getints (splitlines (parts 0))))
  (each rule rules (assert (= (length rule) 2)))

  (def page-lists (map getints (splitlines (parts 1))))
  (each ls page-lists (assert (> (length ls) 0)))

  {:rules rules :page-lists page-lists})

(def input (parse-input (readfile input-path)))

(defn getorput [t key dfflt]
  (def val (t key))
  (if val
    val
    (do
      (put t key dfflt)
      dfflt)))

(defn add-edge [g from to &opt weight]
  (def from-node (getorput g from @{:val from :edges @{}}))
  (def wt (if weight weight 1))
  (put (from-node :edges) to wt))

(defn build-graph [input]
  (var result @{})
  (each [dep sub] (input :rules)
    (add-edge result sub dep))
  result)

(defn ordered? [rules-graph pages]
  (var result true)
  (for i 1 (length pages)
    (def pg (pages i))
    (eachk dep ((rules-graph pg) :edges)
      (if
       (> (find-index |(= $ dep) pages -1) i)
       (do (set result false) (break))))
    (if-not result (break)))
  result)

(defn p1 [input]
  (def graph (build-graph input))
  (def ordered-lists
    (filter (partial ordered? graph) (input :page-lists)))
  (sum (map
        (fn [ls] (ls (math/trunc (/ (length ls) 2))))
        ordered-lists)))

(pp (p1 input))
