package utils

type Stack[T any] struct {
	items []T
}

func NewStack[T any](cap int) Stack[T] {
	var s Stack[T]
	s.items = make([]T, 0, cap)
	return s
}

func (s *Stack[T]) Push(item T) {
	s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() T {
	item := s.items[len(s.items) - 1]
	s.items = s.items[:len(s.items) - 1]
	return item
}

func (s *Stack[T]) Peek() T {
	item := s.items[len(s.items) - 1]
	return item
}

func (s *Stack[T]) Len() int {
	return len(s.items)
}

func (s *Stack[T]) IsEmpty() bool {
	return len(s.items) == 0
}
