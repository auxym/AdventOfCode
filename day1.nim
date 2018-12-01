import strutils
import sequtils
import sets
import math

let input = readFile("./day1_input.txt")
    .splitLines()
    .filter(proc(x: string): bool = x.len > 0) # parseInt fails on empty last line
    .map(parseInt)

var 
    sum: int = 0
    seen = initSet[int](2^17)
    found_repeat = false
    first = true

while not found_repeat:
    for elem in input:
        sum += elem
        if not found_repeat and seen.contains(sum):
            echo "Repeat found: ", sum
            found_repeat = true
        seen.incl(sum)
    
    if first:
        echo "sum: ", sum
        first = false