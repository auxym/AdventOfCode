import std/tables

import std/deques

import std/strutils

import std/sequtils

type
  ModuleId = string

  ModuleKind = enum
    mFlipFlop
    mConjunction
    mOutput

  Pulse = object
    p: bool
    src: ModuleId
    dest: ModuleId

  MachineState = object
    broadcastTargets: seq[ModuleId]
    moduleKinds: Table[ModuleId, ModuleKind]
    conjunctionState: Table[ModuleId, OrderedTableRef[ModuleId, bool]]
    flipflopState: Table[ModuleId, bool]
    wires: Table[ModuleId, seq[ModuleId]]
    pulseQueue: Deque[Pulse]
    pulseCount: array[bool, Natural]
    rx: bool

const
  Low = false
  High = true

func modKind(machine: MachineState; id: ModuleId): ModuleKind =
  machine.moduleKinds[id]

proc addModule(machine: var MachineState; modl: ModuleId; kind: ModuleKind) =
  doAssert modl notin machine.moduleKinds
  doAssert modl notin machine.wires
  doAssert modl notin machine.conjunctionState
  doAssert modl notin machine.flipflopState
  machine.moduleKinds[modl] = kind
  machine.wires[modl] = @[]
  case kind
  of mFlipFlop:
    machine.flipflopState[modl] = Low
  of mConjunction:
    machine.conjunctionState[modl] = newOrderedTable[ModuleId, bool]()
  of mOutput:
    discard

proc addWire(machine: var MachineState; src, dst: ModuleId) =
  machine.wires[src].add dst
  let dstKind = machine.modKind(dst)
  if dstKind == mConjunction:
    machine.conjunctionState[dst][src] = Low

func parseInput(txt: string): MachineState =
  var processedLines: seq[(string, seq[string])]
  for line in txt.strip.splitLines:
    let parts = line.split(" -> ")
    assert parts.len == 2

    let src = parts[0]
    assert src.strip == src

    let dests = parts[1].split(", ")
    assert dests.len >= 1

    processedLines.add (src, dests)

  for (src, dests) in processedLines:
    if src == "broadcaster":
      result.broadcastTargets = dests
    elif src[0] == '%':
      let srcName = src[1..^1]
      result.addModule(srcName, mFlipFlop)
    elif src[0] == '&':
      let srcName = src[1..^1]
      result.addModule(srcName, mConjunction)
    else:
      doAssert false

  for (src, dests) in processedLines:
    if src == "broadcaster":
      discard
    elif src[0] in {'%', '&'}:
      for dst in dests:
        if dst notin result.moduleKinds:
          # Handle output module
          result.addModule(dst, mOutput)
        result.addWire(src[1..^1], dst)
    else:
      doAssert false

#let input = readFile("input/day20_example.txt").parseInput
let input = readFile("input/day20_input.txt").parseInput

proc pushPulse(machine: var MachineState; p: bool; src, dest: ModuleId) =
  #debugEcho src, " -", ["low", "high"][p.int], " -> ", dest
  machine.pulseQueue.addLast Pulse(p: p, src: src, dest: dest)

proc pushPulse(
    machine: var MachineState; p: bool; src: ModuleId; dest: openArray[ModuleId]
) =
  for d in dest:
    machine.pushPulse(p, src, d)

proc pushButton(machine: var MachineState) =
  doAssert machine.pulseQueue.len == 0
  inc machine.pulseCount[Low]
  for dst in machine.broadcastTargets:
    machine.pushPulse(Low, "broadcaster", dst)

template toggle(e: var bool): untyped =
  e = not e

func checkConjunction(machine: MachineState; module: ModuleId): bool =
  result = true
  for mem in machine.conjunctionState[module].values:
    if not mem:
      return false

proc processPulse(machine: var MachineState) =
  let pulse = machine.pulseQueue.popFirst
  inc machine.pulseCount[pulse.p]

  case machine.modKind(pulse.dest)
  of mFlipFlop:
    if pulse.p == Low:
      toggle machine.flipflopState[pulse.dest]
      machine.pushPulse(
        machine.flipflopState[pulse.dest], pulse.dest, machine.wires[pulse.dest]
      )
  of mConjunction:
    machine.conjunctionState[pulse.dest][pulse.src] = pulse.p
    let emit = not machine.checkConjunction(pulse.dest)
    machine.pushPulse(emit, pulse.dest, machine.wires[pulse.dest])
  of mOutput:
    if pulse.dest == "rx" and pulse.p == Low:
      machine.rx = true

  let tgState = toSeq(machine.conjunctionState["tg"].values)
  if tgState.foldl(a or b):
    debugecho tgState

proc processAllPulses(machine: var MachineState) =
  while machine.pulseQueue.len > 0:
    machine.processPulse

let pt1 =
  block:
    var m = input
    for i in 1..1000:
      m.pushButton
      m.processAllPulses
      #debugEcho ""
    debugEcho m.pulseCount
    m.pulseCount[High] * m.pulseCount[Low]

echo pt1

# Part 2
var
  mach = input
  buttonCount = 0
while not mach.rx:
  mach.pushButton
  inc buttonCount
  mach.processAllPulses
echo buttonCount
