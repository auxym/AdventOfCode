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
    let content =
      if isFile:
        some(curId)
      else:
        none(FileId)

    for i in 0 ..< parseInt($c):
      result.add content

    isFile = not isFile
    if isFile:
      inc curId

let input = readFile("./input/day09_input.txt").parseInput

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

  for i in 0 .. blocks.high:
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

# Part 2

type BlockSequence = Slice[Natural]

func moveFile(blocks: var DiskBlocks, src, dst: BlockSequence) =
  for k in 0 ..< src.len:
    assert blocks[dst.a + k].isNone
    assert blocks[src.a + k].isSome
    blocks[dst.a + k] = blocks[src.a + k]
    blocks[src.a + k] = none(FileId)
    assert blocks[dst.a + k].isSome
    assert blocks[src.a + k].isNone

func tryMoveFile(blocks: var DiskBlocks, fileLoc: BlockSequence): bool =
  var i = 0
  while i <= fileLoc.a:
    if blocks[i].isNone:
      var j = i
      while (j + 1) <= blocks.high and blocks[j + 1].isNone:
        inc j
      let hole = i.Natural .. j.Natural

      if hole.len >= fileLoc.len:
        blocks.moveFile(fileLoc, hole)
        return true
      i = hole.b + 1
    else:
      inc i

proc p2(input: DiskBlocks): int =
  var
    blocks = input
    i = blocks.high

  while i >= blocks.low:
    if blocks[i].isSome:
      let fileLoc = block:
        # Find start of file
        var j = i
        while (j - 1) >= blocks.low and blocks[j - 1] == blocks[i]:
          dec j
        j.Natural .. i.Natural

      discard blocks.tryMoveFile fileLoc
      i = fileLoc.a - 1
    else:
      dec i

  result = checksum blocks

echo p2(input)
