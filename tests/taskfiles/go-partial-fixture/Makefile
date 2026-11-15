POWERWORD ?= ../mock-powerword.sh
COVERAGE_THRESHOLD ?= 50
EFFECTIVE_COVERAGE = $(if $(MIN_COVERAGE),$(MIN_COVERAGE),$(COVERAGE_THRESHOLD))

.PHONY: all build test lint fmt tidy vuln check-coverage clean

all: lint vuln check-coverage build

build:
	mkdir -p bin
	go build -o bin/sample ./cmd/sample

test:
	go test -v -race -covermode=atomic -coverprofile=coverage.out -coverpkg=./... ./...

lint:
	$(POWERWORD) lint-go

fmt:
	go fmt ./...

tidy:
	go mod tidy

vuln:
	$(POWERWORD) vuln

check-coverage: test
	$(POWERWORD) check-coverage $(EFFECTIVE_COVERAGE) coverage.out

clean:
	rm -rf bin coverage coverage.out
