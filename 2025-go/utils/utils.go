package utils

import (
	"fmt"
	"os"
	"path"
	"regexp"
	"strconv"
	"strings"

	"golang.org/x/exp/constraints"
)

func LoadInput(day int) string {
	filepath := path.Join("input", fmt.Sprintf("day%02d_input.txt", day))
	contents, err := os.ReadFile(filepath)
	if err != nil {
		panic(err)
	}
	return string(contents)
}

func LoadExampleInput(day int) string {
	filepath := path.Join("input", fmt.Sprintf("day%02d_example.txt", day))
	contents, err := os.ReadFile(filepath)
	if err != nil {
		panic(err)
	}
	return string(contents)
}

func Lines(s string) []string {
	return strings.Split(strings.TrimSpace(s), "\n")
}

func ShowAnswer[T comparable](part int, x, expected T, doCheck bool) {
	if doCheck && (x != expected) {
		fmt.Printf("Part %d: FAIL Expected %v, got %v\n", part, expected, x)
	} else if doCheck {
		fmt.Printf("Part %d: PASS %v\n", part, x)
	} else {
		fmt.Printf("Part %d: %v\n", part, x)
	}
}

func GetInts(s string) []int64 {
	var result []int64
	re := regexp.MustCompile(`\d+`)
	for _, part := range re.FindAllString(s, -1) {
		val, err := strconv.ParseInt(part, 10, 64)
		if err != nil {
			panic(err)
		}
		result = append(result, val)
	}
	return result
}

func Abs[T ~int | ~int8 | ~int16 | ~int32 | ~int64](x T) T {
	if x < 0 {
		return -x
	}
	return x
}

func WithoutLast[T any](s []T) []T {
	if len(s) == 0 {
		return s
	}
	return s[:len(s)-1]
}

func ParseCharInt(b rune) int {
	if b < '0' || b > '9' {
		panic("Rune is not within 0-9")
	}
	return int(b - '0')
}

func PowInt[T constraints.Integer](m, n T) T {
	if n < 0 {
		panic("Negative exponent not supported")
	}
	result := T(1)
	for i := T(1); i <= n; i++ {
		result = result * m
	}
	return result
}
