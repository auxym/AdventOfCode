import streams
import os
import strutils
import sets

var 
    sum: int = 0
    seen = initSet[int]()
    found_repeat = false
    first = true

while not found_repeat:
    for line in lines(os.paramStr(1)):
        sum += parseInt(line)
        if not found_repeat and seen.contains(sum):
            echo "Repeat found_repeat: ", sum
            found_repeat = true
        seen.incl(sum)
    
    if first:
        echo "sum: ", sum
        first = false