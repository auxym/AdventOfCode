package utils

import "testing"

func TestPowInt(t *testing.T) {
    tests := []struct {
        base int
        exp  int
        want int
    }{
        {2, 0, 1},
        {2, 1, 2},
        {2, 10, 1024},
        {3, 5, 243},
        {5, 3, 125},
    }

    for _, tt := range tests {
        got := PowInt(tt.base, tt.exp)
        if got != tt.want {
            t.Fatalf("Pow(%d, %d) = %d, want %d",
                tt.base, tt.exp, got, tt.want)
        }
    }
}