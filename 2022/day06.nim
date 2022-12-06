import std/streams
import std/deques

const inputFileName = "./input/day06_input.txt"

proc checkSotMark(q: Deque[char], mlen: Natural): bool =
  doAssert q.len == mlen
  var s: set[char]
  for c in q: s.incl c
  return s.card == mlen

proc findMark(mlen: Natural): int =
  var
    input = newFileStream inputFileName
    consumed: int = 0
    sotMark = initDeque[char]()

  while not input.atEnd:
    let c = input.readChar
    consumed.inc
    sotMark.addLast c

    if sotMark.len == mlen:
      if checkSotMark(sotMark, mlen):
        return consumed
      discard sotMark.popFirst

  return -1

# Part 1
echo findMark(4)

# Part 2
echo findMark(14)
