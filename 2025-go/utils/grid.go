package utils

import "iter"

type RuneGrid struct {
	items [][]rune
	NRows int
	NCols int
}

type Vector struct {
	X, Y int
}

func InitRuneGrid(rows, cols int) RuneGrid {
	items := make([][]rune, rows)
	for i := range items {
		items[i] = make([]rune, cols)
	}
	return RuneGrid{
		items: items,
		NRows: rows,
		NCols: cols,
	}
}

func RuneGridFromString(s string) RuneGrid {
	var result RuneGrid
	lines := Lines(s)
	result.NRows = len(lines)
	result.NCols = len(lines[0])

	for _, line := range lines {
		if len(line) != result.NCols {
			panic("Lines are not equal length")
		}
		result.items = append(result.items, []rune(line))
	}
	return result
}

func (g *RuneGrid) At(v Vector) rune {
	return g.items[v.Y][v.X]
}

func (g *RuneGrid) SetAt(v Vector, r rune) {
	g.items[v.Y][v.X] = r
}

func (g *RuneGrid) IsInGrid(v Vector) bool {
	return v.X >= 0 && v.X < g.NCols && v.Y >= 0 && v.Y < g.NRows
}

// Iterator over all (location, value) pairs of the grid
func (g *RuneGrid) Pairs() iter.Seq2[Vector, rune] {
	return func(yield func(Vector, rune) bool) {
		for row := 0; row < g.NRows; row++ {
			for col := 0; col < g.NCols; col++ {
				v := Vector{Y: row, X: col}
				r := g.At(v)
				if !yield(v, r) {
					return
				}
			}
		}
	}
}

// return up to 8 valid neighboring vectors
func (g *RuneGrid) NeighborLocsDiag(v Vector) []Vector {
	nb := make([]Vector, 0, 8)
	if v.Y > 0 {
		nb = append(nb, Vector{Y: v.Y - 1, X: v.X})
		if v.X > 0 {
			nb = append(nb, Vector{Y: v.Y - 1, X: v.X - 1})
		}
		if v.X < g.NCols - 1 {
			nb = append(nb, Vector{Y: v.Y - 1, X: v.X + 1})
		}
	}

	if v.Y < g.NRows - 1 {
		nb = append(nb, Vector{Y: v.Y + 1, X: v.X})
		if v.X > 0 {
			nb = append(nb, Vector{Y: v.Y + 1, X: v.X - 1})
		}
		if v.X < g.NCols - 1 {
			nb = append(nb, Vector{Y: v.Y + 1, X: v.X + 1})
		}
	}

	if v.X > 0 {
		nb = append(nb, Vector{Y: v.Y, X: v.X - 1})
	}
	if v.X < g.NCols - 1 {
		nb = append(nb, Vector{Y: v.Y, X: v.X + 1})
	}
	return nb
}

func (g *RuneGrid) NeighborValuesDiag(v Vector) []rune {
	nvals := make([]rune, 0, 8)
	for _, nb := range g.NeighborLocsDiag(v) {
		nvals = append(nvals, g.At(nb))
	}
	return nvals
}
