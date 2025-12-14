package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/auxym/AdventOfCode/2025-go/utils"
	"github.com/samber/lo"
)

const day = 6

type Problem struct {
	Operands []int64
	Operator byte
}

type Homework []Problem

func parseInput(s string) Homework {
	var hw []Problem
	lines := utils.Lines(s)
	for _, line := range utils.WithoutLast(lines) {
		for i, n := range utils.GetInts(line) {
			if i >= len(hw) {
				hw = append(hw, Problem{Operands: []int64{n}})
			} else {
				hw[i].Operands = append(hw[i].Operands, n)
			}
		}
	}

	for i, op := range strings.Fields(lines[len(lines)-1]) {
		if len(op) != 1 || !strings.ContainsAny(op, "+*") {
			panic(fmt.Sprintf("Unexpected operator '%s'", op))
		}
		hw[i].Operator = op[0]
	}

	return hw
}

func compute(pb Problem) int64 {
	switch pb.Operator {
	case '+':
		return lo.Sum(pb.Operands)
	case '*':
		return lo.Product(pb.Operands)
	}
	panic(fmt.Sprintf("Unexpected operator '%b'", pb.Operator))
}

func part1() int64 {
	hw := parseInput(utils.LoadInput(day))
	result := int64(0)
	for _, pb := range hw {
		result += compute(pb)
	}
	return result
}

// ---- Part 2 -------------------------------

func containsOnly(s []byte, b byte) bool {
    if len(s) == 0 {
        return false
    }
    for _, v := range s {
        if v != b {
            return false
        }
    }
    return true
}

func parseInput2(s string) Homework {
	var hw []Problem
	lines := strings.Split(strings.TrimRight(s, "\n"), "\n")
	numLines := utils.WithoutLast(lines)

	var pb Problem
	operandIndex := 0
	for colIndex := range numLines[0] {
		var opChars []byte
		for lineIndex := range numLines {
			b := numLines[lineIndex][colIndex]
			opChars = append(opChars, b)
		}

		if containsOnly(opChars, ' ') {
			hw = append(hw, pb)
			pb.Operands = nil
			operandIndex = 0
		} else {
			val, err := strconv.ParseInt(strings.TrimSpace(string(opChars)), 10, 64)
			if err != nil {
				panic(err)
			}
			pb.Operands = append(pb.Operands, val)
			operandIndex ++
		}
	}
	hw = append(hw, pb)

	for i, op := range strings.Fields(lines[len(lines)-1]) {
		if len(op) != 1 || !strings.ContainsAny(op, "+*") {
			panic(fmt.Sprintf("Unexpected operator '%s'", op))
		}
		hw[i].Operator = op[0]
	}

	return hw
}

func part2() int64 {
	hw := parseInput2(utils.LoadInput(day))
	result := int64(0)
	for _, pb := range hw {
		result += compute(pb)
	}
	return result
}

func main() {
	utils.ShowAnswer(1, part1(), 4722948564882, true)
	utils.ShowAnswer(2, part2(), 9581313737063, true)
}
