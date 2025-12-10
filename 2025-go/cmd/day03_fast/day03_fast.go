// Re-implement part 2 after I looked up solutions on reddit
// Greedy algo much faster than my initial DFS...

package main

import (
	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 3

const NBATT = 12

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

// powers of 10 [0 10 100...]
var pow10 [NBATT]int64 = func() [NBATT]int64 {
	var pows [NBATT]int64
	pows[0] = 1
	for i := 1; i < NBATT; i++ {
		pows[i] = pows[i-1] * 10
	}
	return pows
}()

func maximumJoltage2(bank Bank) int64 {
	used := 0
	idx := 0

	var jolts int64 = 0
	for used < NBATT {
		remain := NBATT - (used + 1) // after this one
		lastIdx := len(bank) - remain

		bestVal := bank[idx]
		bestIdx := idx
		for i := idx + 1; i < lastIdx; i++ {
			if bank[i] > bestVal {
				bestVal = bank[i]
				bestIdx = i
			}
		}

		jolts += int64(bestVal) * pow10[NBATT-(used+1)]
		idx = bestIdx + 1
		used++
	}
	return jolts
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
	utils.ShowAnswer(2, part2(), 169685670469164, true)
}
