import std/strutils
import std/enumerate
import std/options
import std/math

type
  FileId = int32
  DiskBlocks = seq[Option[FileId]]

func parseInput(s: string): DiskBlocks =
  var
    isFile = true
    curId = FileId(0)
  for c in s.strip:
    let
      content =
        if isFile:
          some(curId)
        else:
          none(FileId)

    for i in 0..<parseInt($c):
      result.add content

    isFile = not isFile
    if isFile:
      inc curId

let input = readFile("./input/day09_input.txt").parseInput
#let input = parseInput "2333133121414131402"

func checksum(blocks: DiskBlocks): int =
  for (i, blk) in enumerate(blocks):
    if blk.isSome:
      result.inc i * blk.get()

proc `$`(blocks: DiskBlocks): string =
  var parts = newSeqOfCap[string](blocks.len)
  for blk in blocks:
    if blk.isNone:
      parts.add "."
    else:
      parts.add $(blk.get)
  result = parts.join(" ")

proc p1(input: DiskBlocks): int =
  var blocks = input
  var nextUsed = blocks.high

  for i in 0..blocks.high:
    if isSome(blocks[i]):
      continue

    # Find next used block
    while nextUsed >= i and blocks[nextUsed].isNone:
      dec nextUsed
    if nextUsed < i:
      # We're done
      break

    assert blocks[nextUsed].isSome
    assert nextUsed > i
    blocks[i] = blocks[nextUsed]
    blocks[nextUsed] = none(FileId)
    dec nextUsed

  result = checksum blocks

echo p1(input)
