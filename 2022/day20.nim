import std/lists
import std/sequtils
import ./utils

func toDoublyLinkedRing[T](values: openArray[T]): DoublyLinkedRing[T] =
  for v in values:
    result.add v

func insertAfter(after, toInsert: DoublyLinkedNode) =
  after.next.prev = toInsert
  toInsert.next = after.next
  toInsert.prev = after
  after.next = toInsert

func mix(values: seq[int], times = 1): seq[int] =
  var list = values.toDoublyLinkedRing
  let
    divisor = values.len - 1
    initialOrder: seq[DoublyLinkedNode[int]] = toSeq(list.nodes)
  for i in 0 ..< times:
    for n in initialOrder:
      var cur = n.prev
      list.remove n
      if n.value > 0:
        for i in 0 ..< (n.value mod divisor):
          cur = cur.next
      else:
        for i in 0 ..< (abs(n.value) mod divisor):
          cur = cur.prev
      cur.insertAfter n
  result = toSeq(list)

func findGroveCoordinates(values: seq[int]): int =
  var zeroIdx = 0
  while values[zeroIdx] != 0:
    inc zeroIdx

  var i = 0
  while i < 3000:
    inc i
    if i == 1000 or i == 2000 or i == 3000:
      let idx = (zeroIdx + i) mod values.len
      result.inc values[idx]

let encryptedFile = readFile("./input/day20_input.txt").getInts

let part1 = encryptedFile.mix.findGroveCoordinates
echo part1

# Part 2
const decryptionKey = 811589153

let part2 = encryptedFile.mapIt(
  it * decryptionKey
).mix(10).findGroveCoordinates
echo part2
