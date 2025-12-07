package utils

import (
	"fmt"
	"os"
	"path"
	"strings"
)

func LoadInput(day int) string {
	filepath := path.Join("input", fmt.Sprintf("day%02d_input.txt", day))
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

func Abs[T ~int | ~int8 | ~int16 | ~int32 | ~int64](x T) T {
    if x < 0 {
        return -x
    }
    return x
}
