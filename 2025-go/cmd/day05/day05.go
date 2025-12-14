package main

import (
	"cmp"
	"fmt"
	"slices"
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

func (rng Range) Contains(x int) bool {
	return x >= rng.A && x <= rng.B
}

func part1() int {
	numFresh := 0
	db := parseInput(utils.LoadInput(day))
	for _, ing := range db.Available {
		for _, rng := range db.FreshRanges {
			if rng.Contains(ing) {
				numFresh++
				break
			}
		}
	}
	return numFresh
}

func (rng Range) Length() int {
	return rng.B - rng.A + 1
}

func (rng Range) HasOverlap(other Range) bool {
	return rng.Contains(other.A) || rng.Contains(other.B) || other.Contains(rng.A) || other.Contains(rng.B)
}

func (x Range) Union(y Range) Range {
	if !x.HasOverlap(y) {
		panic("No overlap cannot union")
	}
	return Range{A: min(x.A, y.A), B: max(x.B, y.B)}
}

// Disjoint range composed of multiple subranges that are guaranteed wi
// be disjoint with respect to each other (no overlap).
type DisjointRange []Range

// Attempt to merge subrange at index "index" of DisjointRange "dr" into
// any of the other subranges, if it overlaps. If merge succeeds, repeat
// the process with the new, merged subrange, until there are no possible
// merge (no subrange overlap).
func (dr DisjointRange) tryMerge(index int) DisjointRange {
	for {
		target := dr[index]
		canMerge := -1
		for i, rng := range dr {
			if i == index {
				continue
			}
			if rng.HasOverlap(target) {
				canMerge = i
				break
			}
		}

		if canMerge >= 0 {
			keepIndex := min(index, canMerge)
			delIndex := max(index, canMerge)
			dr[keepIndex] = target.Union(dr[canMerge])
			dr = slices.Delete(dr, delIndex, delIndex+1)
			index = keepIndex
			// loop again and attempt to merge this new item
		} else {
			// Cannot merge
			return dr
		}
	}
}

// Add a new subrange into a DisjoinRange.
func (dr DisjointRange) Union(other Range) DisjointRange {
	for i, rng := range dr {
		if rng.HasOverlap(other) {
			dr[i] = rng.Union(other)
			return dr.tryMerge(i)
		}
	}
	return append(dr, other)
}

func part2() int64 {
	db := parseInput(utils.LoadInput(day))

	var dr DisjointRange = make([]Range, 0, 1024)
	for _, rng := range db.FreshRanges {
		dr = dr.Union(rng)
	}

	var count int64 = 0
	for _, rng := range dr {
		count += int64(rng.Length())
	}

	return count
}

// Because I didn't think to sort the ranges before I saw the idea on reddit :(
func part2_sort() int {
	db := parseInput(utils.LoadInput(day))
	slices.SortFunc(db.FreshRanges, func(x, y Range) int {
		return cmp.Compare(x.A, y.A)
	})

	count := 0
	cur := db.FreshRanges[0]
	for _, rng := range db.FreshRanges[1:] {
		if rng.A <= cur.B {
			cur.B = max(cur.B, rng.B)
		} else {
			count += cur.Length()
			cur = rng
		}
	}
	count += cur.Length()
	return count
}

func main() {
	utils.ShowAnswer(1, part1(), 733, true)
	utils.ShowAnswer(2, part2(), 345821388687084, true)
	utils.ShowAnswer(2, part2_sort(), 345821388687084, true)
}
