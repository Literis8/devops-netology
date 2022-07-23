package main

import "fmt"

func main()  {
	fmt.Print("Введите количество метров: ")
	var v_meters float64
	fmt.Scanf("%f", &v_meters)
	fmt.Println("В ", v_meters, " метре(ах) ", v_meters/0.3048, " фута(ов).")
}