package main

import (
	"fmt"

	"example.com/makefixture/pkg/greet"
)

var version = "dev"

func main() {
	fmt.Printf("%s (%s)\n", greet.Hello(), version)
}
