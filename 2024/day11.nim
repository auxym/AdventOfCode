import std/lists
import std/strformat
import utils

type
  Stone = DoublyLinkedNode[int]
  StoneList = DoublyLinkedList[int]

let input: StoneList = "125 17".getInts.toDoublyLinkedList

proc `$`(s: Stone): string =
  let
    pval =
      if s.prev.isNil:
        "nil"
      else:
        $(s.prev.value)
    nval =
      if s.next.isNil:
        "nil"
      else:
        $(s.next.value)
  fmt"(value: {s.value}, prev: {pval}, next: {nval})"

proc insertAfter(ls: var StoneList, after: Stone, value: int) =
  #echo "--    insert after: ", after
  let n = newDoublyLinkedNode[int](value)
  n.prev = after
  if not after.next.isNil:
    n.next = after.next
    after.next.prev = n
    after.next = n
    #echo "--    after insert: ", after, " -> ", after.next
  else:
    #echo "after.next is nil"
    assert after.next.isNil
    after.next = n
    ls.tail = n

proc blink(ls: var StoneList) =
  var cur = ls.head
  #echo "blink ", ls
  while not cur.isNil:
    #echo "  ", ls, " ", cur
    let
      valDigits = cur.value.digits
      n = valDigits.len
    if cur.value == 0:
      cur.value = 1
      cur = cur.next
    elif n mod 2 == 0:
      let
        half = n div 2
        left = valDigits[0 ..< half].digitsToNumber
        right = valDigits[half .. ^1].digitsToNumber
      cur.value = left
      #echo "before insert: ", ls
      #echo "    insert after:", cur
      ls.insertAfter(cur, right)
      #echo "after insert: ", ls
      cur = cur.next.next
    else:
      cur.value = cur.value * 2024
      cur = cur.next

proc copyList[T](ls: DoublyLinkedList[T]): DoublyLinkedList[T] =
  result = initDoublyLinkedList[int]()
  for x in ls:
    assert type(x) is T
    result.add x

func len(ls: StoneList): Natural =
  for x in ls:
    inc result

proc p1(input: StoneList): int =
  var ls = input.copyList
  for i in 0 ..< 24:
    ls.blink
    #echo ls
  result = ls.len

echo p1(input)
