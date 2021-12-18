import utils
from std/math import sgn

type TargetZone = object
  xzone: Slice[int]
  yzone: Slice[int]

type TorpedoResult = object
  success: bool
  numSteps: int
  maxHeight: int

func contains(tg: TargetZone, a: Vector): bool =
  a.x in tg.xzone and a.y in tg.yzone

func fireTorpedo(v0: Vector, target: TargetZone): TorpedoResult =
  let
    targetMinY = min(target.yzone.a, target.yzone.b)
    targetMaxX = max(target.xzone.a, target.xzone.b)

  var
    pcur: Vector = (0, 0)
    vcur: Vector = v0
    i = 0
    maxHeight = int.low

  while true:
    inc i

    # Update position
    pcur.x.inc vcur.x
    pcur.y.inc vcur.y
    if pcur.y > maxHeight: maxHeight = pcur.y

    # Update speed
    vcur.x.dec vcur.x.sgn
    vcur.y.dec 1

    if pcur in target:
      return TorpedoResult(
        success: true,
        numSteps: i,
        maxHeight: maxHeight,
      )
    elif (vcur.y < 0 and pcur.y < targetMinY) or (pcur.x > targetMaxX and vcur.x >= 0):
      return TorpedoResult(
        success: false,
        numSteps: i,
        maxHeight: maxHeight,
      )

func findMaxHeight(target: TargetZone): tuple[v: Vector, maxHeight: int] =
  var
    vy = 0
    success = true
    searchFlag = false
    maxVy = int.high

  while success or (vy <= maxVy):
    inc vy
    for vx in 1..(target.xzone.b div 2):
      let fireResult = fireTorpedo((vx, vy), target)
      success = fireResult.success

      if fireResult.success:
        searchFlag = false
        assert result.maxHeight < fireResult.maxHeight
        result.maxHeight = fireResult.maxHeight
        result.v = (vx, vy)
        break

    if not success and not searchFlag:
      # If no viable vx found, search up to double vy then stop.
      searchFlag = true
      maxVy = vy * 2

# Example
# let target = TargetZone(xzone: 20 .. 30, yzone: -10 .. -5)
# assert FireTorpedo((7, 2), target).success
# assert FireTorpedo((6, 3), target).success
# assert FireTorpedo((9, 0), target).success
# assert not FireTorpedo((17, -4), target).success
# assert FireTorpedo((6, 9), target).success
# assert FireTorpedo((6, 9), target).maxHeight == 45
# assert findMaxHeight(target) == 45

let target = TargetZone(xzone: 277 .. 318, yzone: -92 .. -53)
let pt1 = target.findMaxHeight
echo pt1

# Part 2

proc countSolutions(target: TargetZone): int =
  for vy in (target.yzone.a) .. pt1.v.y:
    for vx in 1 .. target.xzone.b:
      if fireTorpedo((vx, vy), target).success:
        result.inc

echo target.countSolutions
