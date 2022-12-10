import std/strutils

type CpuState = object
  x: int
  cycleCount: int

func initCpu: CpuState =
  CpuState(x: 1, cycleCount: 0)

func part1(instructions: seq[string]): int =
  var
    cpu = initCpu()
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
      if cpu.cycleCount in [20, 60, 100, 140, 180, 220]:
        let signalStrentgh = cpu.cycleCount * cpu.x
        debugEcho cpu, " ", signalStrentgh
        result.inc signalStrentgh
    cpu.x = nextX

let input = readFile("./input/day10_input.txt").strip.splitLines

echo part1(input)
