import std/strutils

import std/sequtils

import std/tables

import std/math

import regex

#import utils

type
  Category = enum
    catX
    catM
    catA
    catS

  Part = array[Category, int]

  Operator = enum
    opNone
    opGreaterThan
    opLessThan

  Rule = object
    op: Operator
    lhs: Category
    rhs: int
    truewf: string

  Workflow = object
    id: string
    rules: seq[Rule]

  Input = object
    workflows: Table[string, Workflow]
    parts: seq[Part]

func parseWorkflow(txt: string): Workflow =
  const
    ruleEx = re2"([xmas])([<>])(\d+):([a-zA-Z]+)"
    wfEx = re2"([a-zA-Z]+)\{([^\{\}]+)\}"

  var m: RegexMatch2
  doAssert txt.match(wfEx, m)

  result.id = txt[m.group(0)]

  for part in txt[m.group(1)].split(","):
    if part.match(re2"[a-zA-Z]+"):
      result.rules.add Rule(op: opNone, truewf: part)
    else:
      doAssert part.match(ruleEx, m)
      var rule: Rule

      rule.op =
        case part[m.group(1)][0]
        of '<':
          opLessThan
        of '>':
          opGreaterThan
        else:
          assert false
          opNone

      rule.lhs =
        case part[m.group(0)][0]
        of 'x':
          catX
        of 'm':
          catM
        of 'a':
          catA
        of 's':
          catS
        else:
          assert false
          catX

      rule.rhs = part[m.group(2)].parseInt
      rule.truewf = part[m.group(3)]

      result.rules.add rule

func parsePart(txt: string): Part =
  const partExpr = re2"\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}"
  var m: RegexMatch2
  doAssert txt.match(partExpr, m)
  result[catX] = txt[m.group(0)].parseInt
  result[catM] = txt[m.group(1)].parseInt
  result[catA] = txt[m.group(2)].parseInt
  result[catS] = txt[m.group(3)].parseInt

func parseInput(txt: string): Input =
  let blocks = txt.strip.split("\n\n")
  for ln in blocks[0].strip.splitLines:
    let wf = parseWorkflow ln
    result.workflows[wf.id] = wf

  for ln in blocks[1].strip.splitLines:
    result.parts.add ln.parsePart

let input = readFile("input/day19_input.txt").parseInput
#let input = readFile("input/day19_example.txt").parseInput

func eval(rule: Rule; part: Part): bool =
  case rule.op
  of opNone:
    true
  of opLessThan:
    part[rule.lhs] < rule.rhs
  of opGreaterThan:
    part[rule.lhs] > rule.rhs

func process(wf: Workflow; part: Part): string =
  for rule in wf.rules:
    if rule.eval(part):
      return rule.truewf
  assert false

func process(wftab: Table[string, Workflow]; part: Part): bool =
  var next = "in"
  while next != "A" and next != "R":
    let wf = wftab[next]
    next = wf.process(part)
  result = next == "A"

let pt1 = input.parts.filterIt(input.workflows.process(it)).mapIt(sum it).sum
echo pt1

# Part 2
# https://www.reddit.com/r/adventofcode/comments/18lwcw2/2023_day_19_an_equivalent_part_2_example_spoilers/

type
  BinaryRule = object
    id: string
    dim: Category
    leftLessThan: int
    left, right: string

  KdNodeKind = enum
    kdBranch
    kdLeaf

  KdNode = ref object
    case kind: KdNodeKind
    of kdBranch:
      dim: Category
      val: int
      left, right: KdNode
    of kdLeaf:
      accepted: bool

func toBinRuleId(id: string): string =
  if id == "A" or id == "R":
    id
  else:
    id & "0"

func toBinaryRules(tab: Table[string, Workflow]): Table[string, BinaryRule] =
  for wf in tab.values:
    assert wf.rules[^1].op == opNone
    for i in wf.rules.low..<wf.rules.high:
      let rule = wf.rules[i]
      var binRule = BinaryRule(id: wf.id & $i, dim: rule.lhs)

      let alt =
        if (i + 1) == wf.rules.high:
          wf.rules[^1].truewf.toBinRuleId
        else:
          wf.id & $(i + 1)

      case rule.op
      of opLessThan:
        binRule.leftLessThan = rule.rhs
        binRule.left = rule.truewf.toBinRuleId
        binRule.right = alt
      of opGreaterThan:
        binRule.leftLessThan = rule.rhs + 1
        binRule.right = rule.truewf.toBinRuleId
        binRule.left = alt
      of opNone:
        assert false

      assert binRule.id notin result
      result[binRule.id] = binRule

func buildTree(tab: Table[string, BinaryRule]; rootId: string): KdNode =
  debugEcho rootId
  let rule = tab[rootId]

  new result
  result.kind = kdBranch
  result.dim = rule.dim
  result.val = rule.leftLessThan

  if rule.left == "A":
    result.left = KdNode(kind: kdLeaf, accepted: true)
  elif rule.left == "R":
    result.left = KdNode(kind: kdLeaf, accepted: false)
  else:
    result.left = buildTree(tab, rule.left)

  if rule.right == "A":
    result.right = KdNode(kind: kdLeaf, accepted: true)
  elif rule.right == "R":
    result.right = KdNode(kind: kdLeaf, accepted: false)
  else:
    result.right = buildTree(tab, rule.right)

func buildTree(input: Input): KdNode =
  let rules = input.workflows.toBinaryRules
  result = rules.buildTree("in0")

type HCube = array[Category, Slice[int]]

func volume(cube: HCube): Natural =
  result = 1
  for dim in cube.items:
    result = result * dim.len

func countAccepted(tree: KdNode; extents: HCube): Natural =
  case tree.kind
  of kdLeaf:
    if tree.accepted:
      extents.volume
    else:
      0
  of kdBranch:
    debugEcho extents, " split on ", tree.dim, " = ", tree.val
    var leftCube = extents
    leftCube[tree.dim].b = tree.val - 1
    assert leftCube[tree.dim].b >= leftCube[tree.dim].a

    var rightCube = extents
    rightCube[tree.dim].a = tree.val
    assert rightCube[tree.dim].b >= rightCube[tree.dim].a

    countAccepted(tree.left, leftCube) + countAccepted(tree.right, rightCube)

func countAccepted(tree: KdNode): Natural =
  let extents =
    block:
      var c: HCube
      for dim in c.mitems:
        dim = 1..4000
      c
  result = countAccepted(tree, extents)

let kdtree = input.buildTree
let pt2 = kdtree.countAccepted
echo pt2
