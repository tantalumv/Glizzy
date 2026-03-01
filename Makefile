# Glizzy Monorepo Makefile
#
# Gleam has no native workspace support - build each package individually

.PHONY: build test lint format clean help

help:
	@echo "Glizzy Monorepo - Individual package builds required"
	@echo ""
	@echo "Available targets:"
	@echo "  make build       - Build all packages"
	@echo "  make test        - Run tests (if any)"
	@echo "  make lint        - Run linting"
	@echo "  make format      - Format code"
	@echo "  make clean       - Clean build artifacts"
	@echo ""
	@echo "Or build individual packages:"
	@echo "  cd packages/glizzy && gleam build"
	@echo "  cd packages/cart && gleam build"
	@echo "  cd packages/mustard && gleam build"

build:
	@echo "Building packages/glizzy..."
	@cd packages/glizzy && gleam build
	@echo "Building packages/mustard..."
	@cd packages/mustard && gleam build
	# Skip cart package - WIP with missing dependencies
	# @echo "Building packages/cart..."
	# @cd packages/cart && gleam build
	@echo "All packages built!"

test:
	@cd packages/glizzy && gleam test

lint:
	@cd packages/glizzy && gleam check
	@cd packages/mustard && gleam check
	@cd packages/cart && gleam check

format:
	@cd packages/glizzy && gleam format
	@cd packages/mustard && gleam format
	@cd packages/cart && gleam format

clean:
	@rm -rf packages/glizzy/build
	@rm -rf packages/mustard/build
	@rm -rf packages/cart/build
	@rm -rf examples/*/build
	@echo "Cleaned all build artifacts"
