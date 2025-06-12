# AIKit Makefile

.PHONY: build test clean format lint docs release

# Default target
all: build

# Build the package
build:
	swift build

# Run tests
test:
	swift test

# Build for release
release:
	swift build -c release

# Clean build artifacts
clean:
	swift package clean
	rm -rf .build

# Format code using swift-format (if installed)
format:
	@if command -v swift-format >/dev/null 2>&1; then \
		swift-format -i -r Sources/ Tests/; \
	else \
		echo "swift-format not installed. Install with: brew install swift-format"; \
	fi

# Lint code
lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint; \
	else \
		echo "SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

# Generate documentation
docs:
	@if command -v swift-doc >/dev/null 2>&1; then \
		swift-doc generate Sources/AIKit --module-name AIKit --output docs; \
	else \
		echo "swift-doc not installed. Install with: brew install swift-doc"; \
	fi

# Update dependencies
update:
	swift package update

# Show dependency graph
dependencies:
	swift package show-dependencies

# Run a specific test
test-single:
	@read -p "Enter test name: " test_name; \
	swift test --filter $$test_name

# Create a new provider package
new-provider:
	@read -p "Enter provider name (e.g., openai): " provider_name; \
	mkdir -p ../aikit-$$provider_name; \
	cd ../aikit-$$provider_name && swift package init --type library --name AIKit$$(echo $$provider_name | sed 's/\b\(.\)/\u\1/g')

# Install git hooks
install-hooks:
	@echo "#!/bin/sh\nmake lint\nmake test" > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Git pre-commit hook installed"

# Help
help:
	@echo "Available targets:"
	@echo "  make build        - Build the package"
	@echo "  make test         - Run all tests"
	@echo "  make release      - Build for release"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make format       - Format code (requires swift-format)"
	@echo "  make lint         - Lint code (requires swiftlint)"
	@echo "  make docs         - Generate documentation (requires swift-doc)"
	@echo "  make update       - Update dependencies"
	@echo "  make dependencies - Show dependency graph"
	@echo "  make test-single  - Run a specific test"
	@echo "  make new-provider - Create a new provider package"
	@echo "  make install-hooks- Install git pre-commit hooks"
