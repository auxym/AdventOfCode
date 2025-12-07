package main

import (
	"fmt"

	"strings"

	"github.com/auxym/AdventOfCode/2025-go/utils"
)

const day = 1

func applyInstruction(current int, instruction string) int {
	var dir rune
	var num int
	_, err := fmt.Sscanf(instruction, "%c%d", &dir, &num)
	if err != nil {
		panic(err)
	}

	if dir == 'L' {
		num = -num
	}
	new := (current + num) % 100

	if new < 0 {
		new += 100
	}

	return new
}

func applyInstruction2(current int, instruction string) (int, int) {
	var dir rune
	var num int
	_, err := fmt.Sscanf(strings.TrimSpace(instruction), "%c%d", &dir, &num)
	if err != nil {
		panic(err)
	}

	if dir == 'L' {
		num = -num
	}

	new := current + num
	passedZero := utils.Abs(new / 100)
	new = new % 100

	if new < 0 {
		new += 100
		if current > 0 {
			passedZero++
		}
	} else if (new == 0) && (dir == 'L') {
		passedZero++
	}

	return new, passedZero
}

func part1() int {
	instructions := utils.Lines(utils.LoadInput(day))
	current := 50
	password := 0
	for _, instr := range instructions {
		current = applyInstruction(current, instr)
		if current == 0 {
			password++
		}
	}
	return password
}

func part2() int {
	instructions := utils.Lines(utils.LoadInput(day))
	current := 50
	password := 0

	var passedZero int
	for _, instr := range instructions {
		current, passedZero = applyInstruction2(current, instr)
		password += passedZero
	}
	return password
}

func main() {
	utils.ShowAnswer(1, part1(), 1195, true)
	utils.ShowAnswer(2, part2(), 6770, true)
}
