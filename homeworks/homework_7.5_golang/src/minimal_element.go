package main

import "fmt"

func main() {
	x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
	v_min := x[0]
	for i := 0; i < len(x); i++ {
		if v_min > x[i] {
			v_min = x[i]
		}
	}
	fmt.Println(v_min)
}