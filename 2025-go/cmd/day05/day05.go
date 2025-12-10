package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 5

type Range struct{ A, B int }

type Database struct {
	FreshRanges []Range
	Available   []int
}

func parseInput(s string) Database {
	var db Database

	blocks := strings.Split(strings.TrimSpace(s), "\n\n")
	if len(blocks) != 2 {
		panic("")
	}

	// Parse ranges
	for _, line := range utils.Lines(blocks[0]) {
		var rng Range
		_, err := fmt.Sscanf(line, "%d-%d", &rng.A, &rng.B)
		if err != nil {
			panic("Parse error")
		}
		db.FreshRanges = append(db.FreshRanges, rng)
	}

	// Parse available ingredient ids
	for _, line := range utils.Lines(blocks[1]) {
		id, err := strconv.Atoi(line)
		if err != nil {
			panic("Parse error")
		}
		db.Available = append(db.Available, id)
	}

	return db
}

func (rng Range) isIn(x int) bool {
	return x >= rng.A && x <= rng.B
}

func part1() int {
	numFresh := 0
	db := parseInput(utils.LoadInput(day))
	for _, ing := range db.Available {
		for _, rng := range db.FreshRanges {
			if rng.isIn(ing) {
				numFresh++
				break
			}
		}
	}
	return numFresh
}

func part2() int {
	utils.LoadInput(day)
	return 0
}

func main() {
	utils.ShowAnswer(1, part1(), 733, true)
	utils.ShowAnswer(2, part2(), 0, false)
}
