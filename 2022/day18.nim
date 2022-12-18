import std/strutils
import std/sequtils
import std/sets
import ./utils

const fname = "./input/day18_input.txt"

let dropletCubes = readFile(fname).strip.splitLines.mapIt:
  let ints = getInts it
  (ints[0], ints[1], ints[2])

const directions = [
  (1, 0, 0),
  (-1, 0, 0),
  (0, 1, 0),
  (0, -1, 0),
  (0, 0, 1),
  (0, 0, -1),
]

func part1(cubes: seq[Vector3]): int =
  let dropletSet = cubes.toHashSet
  for c in dropletSet:
    for dirvec in directions:
      if (c + dirvec) notin dropletSet:
        inc result

echo part1(dropletCubes)

# Part 2

type BoundingBox = (Vector3, Vector3)

func contains(bbox: BoundingBox, v: Vector3): bool =
  v.x >= bbox[0].x and v.x <= bbox[1].x and
  v.y >= bbox[0].y and v.y <= bbox[1].y and
  v.z >= bbox[0].z and v.z <= bbox[1].z

func getBounds(cubes: seq[Vector3]): (Vector3, Vector3) =
  doAssert cubes.len > 0
  result[0] = (int.high, int.high, int.high)
  result[1] = (int.low, int.low, int.low)
  for c in cubes:
    if c.x < result[0].x: result[0].x = c.x
    if c.y < result[0].y: result[0].y = c.y
    if c.z < result[0].z: result[0].z = c.z
    if c.x > result[1].x: result[1].x = c.x
    if c.y > result[1].y: result[1].y = c.y
    if c.z > result[1].z: result[1].z = c.z

func isCaptive(v: Vector3, rockSet: HashSet[Vector3], rockBBox: BoundingBox): bool =
  var
    stack: seq[Vector3]
    airSet: HashSet[Vector3]

  assert v notin rockSet
  stack.add v
  airSet.incl v

  result = true
  while stack.len > 0:
    let c = stack.pop
    for dir in directions:
      let n = c + dir
      if n notin rockBBox:
        return false
      if n notin rockSet and n notin airSet:
        airSet.incl n
        stack.add n

func part2(cubes: seq[Vector3]): int =
  let
    rockSet = cubes.toHashSet
    bbox = cubes.getBounds

  for c in rockSet:
    for dirvec in directions:
      let n = c + dirvec
      if n notin rockSet and not isCaptive(n, rockSet, bbox):
        inc result

echo part2(dropletCubes)
