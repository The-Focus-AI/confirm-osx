# Makefile for Confirm - macOS Confirmation Dialog Utility

# Configuration
SWIFT_FILES = confirm.swift
EXECUTABLE = confirm
INSTALL_PREFIX = /usr/local
INSTALL_DIR = $(INSTALL_PREFIX)/bin

# Compiler settings
SWIFTC = swiftc
SWIFT_FLAGS = -O
DEBUG_FLAGS = -g -Onone

# Default target
all: $(EXECUTABLE)

# Build the executable
$(EXECUTABLE): $(SWIFT_FILES)
	@echo "Building $(EXECUTABLE)..."
	$(SWIFTC) $(SWIFT_FLAGS) $(SWIFT_FILES) -o $(EXECUTABLE)
	@echo "Build complete: $(EXECUTABLE)"

# Debug build
debug: $(SWIFT_FILES)
	@echo "Building debug version of $(EXECUTABLE)..."
	$(SWIFTC) $(DEBUG_FLAGS) $(SWIFT_FILES) -o $(EXECUTABLE)
	@echo "Debug build complete: $(EXECUTABLE)"

# Install system-wide
install: $(EXECUTABLE)
	@echo "Installing $(EXECUTABLE) to $(INSTALL_DIR)..."
	@if [ ! -d "$(INSTALL_DIR)" ]; then \
		echo "Creating $(INSTALL_DIR)..."; \
		mkdir -p "$(INSTALL_DIR)"; \
	fi
	cp $(EXECUTABLE) $(INSTALL_DIR)/$(EXECUTABLE)
	chmod 755 $(INSTALL_DIR)/$(EXECUTABLE)
	@echo "Installation complete. You can now use 'confirm' from anywhere."

# Uninstall
uninstall:
	@echo "Removing $(EXECUTABLE) from $(INSTALL_DIR)..."
	rm -f $(INSTALL_DIR)/$(EXECUTABLE)
	@echo "Uninstallation complete."

# Test the executable
test: $(EXECUTABLE)
	@echo "Testing basic functionality..."
	@echo "Testing help flag..."
	./$(EXECUTABLE) --help
	@echo "\nTesting with timeout (will auto-decline after 5 seconds)..."
	@timeout 5 ./$(EXECUTABLE) "Test message (auto-declining in 5 seconds)" || echo "Test completed (expected decline)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(EXECUTABLE)
	rm -rf $(EXECUTABLE).dSYM
	@echo "Clean complete."

# Create a distribution package
package: $(EXECUTABLE)
	@echo "Creating distribution package..."
	@PACKAGE_DIR="confirm-dist"; \
	rm -rf $$PACKAGE_DIR; \
	mkdir -p $$PACKAGE_DIR; \
	cp $(EXECUTABLE) $$PACKAGE_DIR/; \
	cp README.md $$PACKAGE_DIR/; \
	cp Makefile $$PACKAGE_DIR/; \
	cp $(SWIFT_FILES) $$PACKAGE_DIR/; \
	tar -czf confirm.tar.gz $$PACKAGE_DIR; \
	rm -rf $$PACKAGE_DIR; \
	echo "Package created: confirm.tar.gz"

# Run basic validation
validate: $(EXECUTABLE)
	@echo "Validating executable..."
	@if [ -f "$(EXECUTABLE)" ]; then \
		echo "✓ Executable exists"; \
	else \
		echo "✗ Executable not found"; \
		exit 1; \
	fi
	@if [ -x "$(EXECUTABLE)" ]; then \
		echo "✓ Executable is executable"; \
	else \
		echo "✗ Executable is not executable"; \
		exit 1; \
	fi
	@if ./$(EXECUTABLE) --help > /dev/null 2>&1; then \
		echo "✓ Help flag works"; \
	else \
		echo "✗ Help flag failed"; \
		exit 1; \
	fi
	@echo "Validation complete."

# Show build information
info:
	@echo "Confirm Build Information"
	@echo "========================="
	@echo "Swift compiler: $(shell which $(SWIFTC))"
	@echo "Swift version: $(shell $(SWIFTC) --version | head -1)"
	@echo "Source files: $(SWIFT_FILES)"
	@echo "Executable: $(EXECUTABLE)"
	@echo "Install prefix: $(INSTALL_PREFIX)"
	@echo "Install directory: $(INSTALL_DIR)"
	@echo ""
	@echo "Available targets:"
	@echo "  all      - Build the executable (default)"
	@echo "  debug    - Build with debug symbols"
	@echo "  install  - Install system-wide (requires sudo)"
	@echo "  uninstall- Remove system installation"
	@echo "  test     - Run basic tests"
	@echo "  clean    - Remove build artifacts"
	@echo "  package  - Create distribution package"
	@echo "  validate - Validate the build"
	@echo "  info     - Show this information"

# Help target
help: info

# Check for Swift compiler
check-swift:
	@which $(SWIFTC) > /dev/null || (echo "Error: Swift compiler not found. Install Xcode Command Line Tools with: xcode-select --install" && exit 1)

# Pre-build setup
setup: check-swift
	@echo "Environment check complete."

# Build with setup
build: setup $(EXECUTABLE)

# Phony targets
.PHONY: all debug install uninstall test clean package validate info help check-swift setup build

# Default shell
SHELL := /bin/bash