package main

import (
	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 7

type TachyonManifold = struct {
	Splitters  map[utils.Vector]struct{}
	BeamStartX int
	NumRows    int
}

func parseInput(s string) TachyonManifold {
	var result TachyonManifold
	result.Splitters = make(map[utils.Vector]struct{})

	for y, line := range utils.Lines(s) {
		result.NumRows++
		for x, char := range line {
			switch char {
			case '^':
				// Splitter
				v := utils.Vector{X: x, Y: y}
				result.Splitters[v] = struct{}{}
			case 'S':
				result.BeamStartX = x
			}
		}
	}
	return result
}

func part1() int {
	tm := parseInput(utils.LoadInput(day))
	beams := make(map[int]struct{}) // x coordinate of beams
	beams[tm.BeamStartX] = struct{}{}
	splitCount := 0

	for row := 1; row < tm.NumRows; row++ {
		nextBeams := make(map[int]struct{}) // x coordinate of beams
		for beamX := range beams {
			_, isSplitter := tm.Splitters[utils.Vector{X: beamX, Y: row}]
			if isSplitter {
				nextBeams[beamX+1] = struct{}{}
				nextBeams[beamX-1] = struct{}{}
				splitCount++
			} else {
				nextBeams[beamX] = struct{}{}
			}
		}
		beams = nextBeams
	}

	return splitCount
}

func part2() int {
	utils.LoadInput(day)
	return 0
}

func main() {
	utils.ShowAnswer(1, part1(), 0, false)
	utils.ShowAnswer(2, part2(), 0, false)
}
