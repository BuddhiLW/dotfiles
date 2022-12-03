package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// function to receive comma-separated numbers
// from Stdin: =echo "1, 3.3, 5" | go run program.go=

func input() []float64 {
	scanner := bufio.NewScanner(os.Stdin)
	// var result [][]float64
	var numbers []float64
	var txt string
	for scanner.Scan() {
		txt = scanner.Text()
		if len(txt) > 0 {
			values := strings.Split(txt, ",")
			// var row []float64
			for _, v_text := range values {
				// Convert string-value representing a float to float-value.
				v_float, err := strconv.ParseFloat(strings.Trim(v_text, " "), 64)
				if err != nil {
					panic(fmt.Sprintf("Incorrect value for float64 '%v'", v_float))
				}
				numbers = append(numbers, v_float)
			}
			// result = append(result, row)
		}
	}
	fmt.Printf("Result: %v\n", numbers)
	return numbers
}

// Calculates the mean
// func mean(x ...float64) float64 {
// 	fmt.Print(x, " ")
// 	sum := float64(0)
// 	for _, xi := range x {
// 		sum += xi
// 	}
// 	mean := float64(sum) / float64(len(x))
// 	fmt.Println(mean)
// 	return mean

// }

func main() {
	inpt := input()
	inpt_mean := mean(inpt)
	fmt.Println(inpt_mean)
}
