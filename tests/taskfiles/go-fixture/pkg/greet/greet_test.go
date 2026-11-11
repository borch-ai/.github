package greet

import "testing"

func TestHello(t *testing.T) {
	if got := Hello(); got != "hello world" {
		t.Errorf("got %q, want %q", got, "hello world")
	}
}
