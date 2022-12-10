import std/strutils
import std/sequtils
import ./utils

type CpuState = object
  x: int
  cycleCount: int

type CrtState = object
  pixels: SeqGrid[char]
  scan: Vector

func initCpu: CpuState =
  CpuState(x: 1, cycleCount: 0)

func initCrt: CrtState =
  CrtState(
    pixels: newSeqWith(6, newSeqWith(40, ' ')),
    scan: (0, 0)
  )

func incScan(crt: var CrtState) =
  crt.scan.x.inc
  if crt.scan.x > crt.pixels[0].high:
    crt.scan.y = (crt.scan.y + 1) mod (crt.pixels.len)
    crt.scan.x = 0

func drawSprite(crt: var CrtState, horz: int, width: int) =
  let
    spriteStart = horz - (width div 2)
    spriteEnd = horz + (width div 2)
  if crt.scan.x in (spriteStart .. spriteEnd):
    crt.pixels[crt.scan] = '#'

proc main(instructions: seq[string]): (int, CrtState) =
  var
    cpu = initCpu()
    crt = initCrt()
    remCycles: int
    nextX: int

  for line in instructions:
    let parts = line.splitWhitespace
    if parts[0] == "noop":
      remCycles = 1
      nextX = cpu.x
    elif parts[0] == "addx":
      remCycles = 2
      nextX = cpu.x + parts[1].parseInt

    while remCycles > 0:
      cpu.cycleCount.inc
      remCycles.dec
      crt.drawSprite(cpu.x, 3)
      crt.incScan
      if cpu.cycleCount in [20, 60, 100, 140, 180, 220]:
        let signalStrentgh = cpu.cycleCount * cpu.x
        result[0].inc signalStrentgh
    cpu.x = nextX
  result[1] = crt

proc show(crt: CrtState) =
  for row in crt.pixels:
    for c in row:
      stdout.write(c)
    stdout.write("\p")

let input = readFile("./input/day10_input.txt").strip.splitLines

let (pt1ans, crt) = main(input)
echo pt1ans
crt.show()
