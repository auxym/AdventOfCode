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
