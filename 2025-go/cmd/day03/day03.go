package main

import (
	"github.com/auxym/AdventOfCode/2025-go/utils"
	"github.com/samber/lo"
)

const day = 3

type Bank []int

func parseInput(s string) []Bank {
	banks := lo.Map(utils.Lines(s), func(line string, _ int) Bank {
		b := make([]int, len(line))
		for i, char := range line {
			b[i] = utils.ParseCharInt(char)
		}
		return b
	})
	return banks
}

// Returns a slice where the value at location i corresponds to the maximum
// value in the input slice that has an index greater than or equal to i.
func maxRightOf(bank Bank) []int {
	result := make([]int, len(bank))
	copy(result, bank)
	for i := len(result) - 2; i >= 0; i-- {
		if result[i] < result[i+1] {
			result[i] = result[i+1]
		}
	}
	return result
}

func maximumJoltage(bank Bank) int {
	mr := maxRightOf(bank)
	result := 0
	for i, leftDigit := range utils.WithoutLast(bank) {
		rightDigit := mr[i+1]
		jolts := leftDigit*10 + rightDigit
		if jolts > result {
			result = jolts
		}
	}
	return result
}

func part1() int {
	banks := parseInput(utils.LoadInput(day))
	return lo.Sum(lo.Map(banks, func(b Bank, _ int) int { return maximumJoltage(b) }))
}

func part2() int {
	utils.LoadInput(day)
	return 0
}

func main() {
	utils.ShowAnswer(1, part1(), 17155, true)
	utils.ShowAnswer(2, part2(), 0, false)
}
