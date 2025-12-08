package main

import (
	"fmt"
	"strings"

	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 2

type IdRange struct {
	a int64
	b int64
}

func parseInput(s string) []IdRange {
	strRanges := strings.Split(strings.TrimSpace(s), ",")
	result := make([]IdRange, 0, len(strRanges))
	for _, sr := range strRanges {
		var idr IdRange
		_, err := fmt.Sscanf(sr, "%d-%d", &idr.a, &idr.b)
		if err != nil {
			panic(err)
		}
		result = append(result, idr)
	}
	return result
}

func isSymmetric(x int64) bool {
	s := fmt.Sprintf("%d", x)
	if len(s) % 2 != 0 {
		return false
	}

	h := len(s) / 2
	return s[:h] == s[h:]
}

func part1() int64 {
	var result int64
	input := parseInput(utils.LoadInput(day))
	for _, rng := range input {
		for x := rng.a; x <= rng.b; x++ {
			if isSymmetric(x) {
				result += x
			}
		}
	}
	return result
}

func compareSubstrings(s string, subslen int) bool {
	if len(s) % subslen != 0 {
		return false
	}

	for i := subslen; (i + subslen <= len(s)); i += subslen {
		if s[0:subslen] != s[i:(i + subslen)] {
			return false
		}
	}

	return true
}

func part2() int64 {
	var result int64
	input := parseInput(utils.LoadInput(day))
	for _, rng := range input {
		for x := rng.a; x <= rng.b; x++ {
			s := fmt.Sprint(x)
			for replen := 1; replen <= (len(s) / 2); replen++ {
				if compareSubstrings(s, replen) {
					result += x
					break
				}
			}
		}
	}
	return result
}

func main() {
	utils.ShowAnswer(1, part1(), 18595663903, true)
	utils.ShowAnswer(2, part2(), 19058204438, true)
}
