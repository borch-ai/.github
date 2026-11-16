package main

import (
	"fmt"

	"example.com/partialfixture/pkg/greet"
)

var version = "dev"

func main() {
	fmt.Printf("%s (%s)\n", greet.Hello(), version)
}

