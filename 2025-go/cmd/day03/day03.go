package main

import (
	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 3

type Bank []int

func parseInput(s string) []Bank {
	var banks []Bank
	for _, line := range utils.Lines(s) {
		b := make([]int, len(line))
		for i, char := range line {
			b[i] = utils.ParseCharInt(char)
		}
		banks = append(banks, b)
	}
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
	var result int
	for _, bank := range banks {
		result += maximumJoltage(bank)
	}
	return result
}

// -- Part 2

const NBATT = 12

var pow10 [NBATT]int64 = func() [NBATT]int64 {
	var pows [NBATT]int64
	pows[0] = 1
	for i := 1; i < NBATT; i++ {
		pows[i] = pows[i-1] * 10
	}
	return pows
}()

func batteryJoltsValue(batt int, position int) int64 {
	if batt > 9 || batt < 0 || position < 1 || position > int(NBATT) {
		panic("Invalid argument")
	}

	return pow10[NBATT-position] * int64(batt)
}

// Used to keep track of DFS in maximumJoltage2
type joltageSearchState struct {
	index   int
	jolts   int64
	numBatt int
}

// DFS over a battery bank to find NBATT combination with highest Joltage
func maximumJoltage2(bank Bank) int64 {
	stack := utils.NewStack[joltageSearchState](1024)

	// Initialize stack with all possible choices for first battery
	for i, batt := range bank[:len(bank)-NBATT+1] {
		stack.Push(joltageSearchState{i, batteryJoltsValue(batt, 1), 1})
	}

	best := int64(0)

	for !stack.IsEmpty() {
		cur := stack.Pop()

		// If reached target number of batteries, check Joltage and update best if needed
		if cur.numBatt == NBATT {
			if cur.jolts > best {
				best = cur.jolts
			}
			continue
		}

		// Prune tree if it's impossible to beat current best with the current state
		maxRemaningJoltage := batteryJoltsValue(1, cur.numBatt) - 1 // 9999...
		if cur.jolts+maxRemaningJoltage < best {
			continue
		}

		maxIndex := len(bank) - (NBATT - cur.numBatt) + 1
		for i := cur.index + 1; i < maxIndex; i++ {
			nextBatt := bank[i]
			nextNumBatt := cur.numBatt + 1
			nextJolts := cur.jolts + batteryJoltsValue(nextBatt, nextNumBatt)
			nextState := joltageSearchState{index: i, jolts: nextJolts, numBatt: nextNumBatt}
			stack.Push(nextState)
		}
	}
	return best
}

func part2() int64 {
	banks := parseInput(utils.LoadInput(day))
	var result int64
	for _, bank := range banks {
		result += maximumJoltage2(bank)
	}
	return result
}

func main() {
	utils.ShowAnswer(1, part1(), 17155, true)
	utils.ShowAnswer(2, part2(), 169685670469164, true)
}
