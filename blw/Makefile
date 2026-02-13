BIN      := blw
BINPATH  := bin/$(BIN)
PREFIX   := $(HOME)/.local/bin
GOFLAGS  := -trimpath -ldflags="-s -w"

.PHONY: build install clean tidy

build: tidy
	@mkdir -p bin
	go build $(GOFLAGS) -o $(BINPATH) ./cmd/blw

install: build
	@mkdir -p $(PREFIX)
	cp $(BINPATH) $(PREFIX)/$(BIN)
	@echo "Installed $(BIN) to $(PREFIX)/$(BIN)"

clean:
	rm -rf bin

tidy:
	go mod tidy
