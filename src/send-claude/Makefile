# Makefile for send-ai-team Go application

# Variables
BINARY_NAME=send-ai-team
GO_FILES=$(wildcard *.go)
BUILD_DIR=build
INSTALL_DIR=~/dotfiles/bin

# Default target
all: fmt install

# Build the application
build: $(BUILD_DIR)/$(BINARY_NAME)

$(BUILD_DIR)/$(BINARY_NAME): $(GO_FILES) go.mod
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME) .

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Install the binary to system PATH
install: build
	cp $(BUILD_DIR)/$(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME)
	chmod +x $(INSTALL_DIR)/$(BINARY_NAME)

# Uninstall the binary from system PATH
uninstall:
	sudo rm -f $(INSTALL_DIR)/$(BINARY_NAME)

# Test the application
test:
	go test -v ./...

# Run the application
run: build
	$(BUILD_DIR)/$(BINARY_NAME)

# Format Go code
fmt:
	go fmt ./...

# Check for Go modules updates
mod-update:
	go mod tidy
	go mod download

# Development build (with race detector)
dev-build:
	@mkdir -p $(BUILD_DIR)
	go build -race -o $(BUILD_DIR)/$(BINARY_NAME) .

# Show help
help:
	@echo "Available targets:"
	@echo "  build      - Build the application"
	@echo "  clean      - Clean build artifacts"
	@echo "  install    - Install binary to $(INSTALL_DIR)"
	@echo "  uninstall  - Remove binary from $(INSTALL_DIR)"
	@echo "  test       - Run tests"
	@echo "  run        - Build and run the application"
	@echo "  fmt        - Format Go code"
	@echo "  mod-update - Update Go modules"
	@echo "  dev-build  - Build with race detector for development"
	@echo "  help       - Show this help message"

# Create a release build
release: clean
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME) .
	@echo "Release build created in $(BUILD_DIR)/$(BINARY_NAME)"

.PHONY: all build clean install uninstall test run fmt mod-update dev-build help release
