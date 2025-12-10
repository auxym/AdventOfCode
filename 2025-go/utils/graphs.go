package utils

type WeightedEdge[T any] struct {
	To T
	Weight int
}

type Graph[T comparable] map[T][]WeightedEdge[T]

func (g Graph[T]) AddEdge(from, to T, weight int) {
	g[from] = append(g[from], WeightedEdge[T]{to, weight})
}