import std/strutils
import std/parseutils
import std/tables
import std/os

type NodeKind = enum File, Dir

type FsNode = ref object
  path: string
  case kind: NodeKind
  of File:
    size: int
  of Dir:
    children: Table[string, FsNode]

func parseInput(data: string): FsNode =
  var
    dirStack: seq[FsNode]
    curDir: FsNode
    root = FsNode(kind: Dir, path: "/")
    fsize: int # used for parseInt below
  result = root

  for ln in data.strip.splitLines:
    let parts = splitWhitespace ln
    if parts[0] == "$" and parts[1] == "cd":
      if parts[2] == "/":
        curDir = root
        dirStack.setLen(0)

      elif parts[2] == "..":
        curDir = dirStack.pop

      else:
        if not curDir.isNil: dirStack.add curDir
        curDir = curDir.children[parts[2]]

    elif parts[0] == "dir":
      if parts[1] notin curDir.children:
        curDir.children[parts[1]] = FsNode(
          kind: Dir, path: curDir.path / parts[1]
        )

    elif parseInt(parts[0], fsize) > 0:
        curDir.children[parts[1]] = FsNode(
          kind: File, size: fsize, path: curDir.path & "/" & parts[1]
        )

func totalSize(dir: FsNode): int =
  doAssert dir.kind == Dir
  for c in dir.children.values:
    case c.kind:
    of File:
      result.inc c.size
    of Dir:
      result.inc c.totalSize()

func buildSizeTable(root: FsNode): Table[string, int] =
  var stack: seq[FsNode]
  stack.add root

  while stack.len > 0:
    let dir = stack.pop
    result[dir.path] = totalSize dir
    for c in dir.children.values:
      if c.kind == Dir:
        stack.add c

let rootDir = readFile("./input/day07_input.txt").parseInput

proc part1: int =
  let sizeTable = buildSizeTable rootDir
  for size in sizeTable.values:
    if size <= 100_000:
      result.inc size

echo part1()
