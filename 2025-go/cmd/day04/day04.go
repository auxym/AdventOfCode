package main

import (
	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 4

func isAccessible(diagram utils.RuneGrid, loc utils.Vector) bool {
	paperCount := 0
	for _, nbChar := range diagram.NeighborValuesDiag(loc) {
		if nbChar == '@' {
			paperCount++
			if paperCount >= 4 {
				return false
			}
		}
	}
	return true
}

func part1() int {
	var diagram utils.RuneGrid = utils.RuneGridFromString(utils.LoadInput(day))
	accessibleCount := 0

	for vec, char := range diagram.Pairs() {
		if char == '@' && isAccessible(diagram, vec) {
			accessibleCount++
		}
	}

	return accessibleCount
}

func tryRemoveRoll(diagram *utils.RuneGrid) bool {
	found := false
	var toRemove utils.Vector
	for vec, char := range diagram.Pairs() {
		if char == '@' && isAccessible(*diagram, vec) {
			found = true
			toRemove = vec
			break
		}
	}

	if found {
		diagram.SetAt(toRemove, '.')
		return true
	} else {
		return false
	}
}

func part2() int {
	var diagram utils.RuneGrid = utils.RuneGridFromString(utils.LoadInput(day))
	countRemoved := 0

	for tryRemoveRoll(&diagram) {
		countRemoved++
	}
	return countRemoved
}

func main() {
	utils.ShowAnswer(1, part1(), 1543, true)
	utils.ShowAnswer(2, part2(), 9038, true)
}
