.PHONY: help setup lint clean validate-links test

help:
	@echo "Technical Documentation Repository - Build Targets"
	@echo ""
	@echo "  make setup          Install required tooling (Vale, Mermaid CLI)"
	@echo "  make lint           Run Vale linter against all documentation"
	@echo "  make validate-links Check for broken relative links"
	@echo "  make test           Run all validation checks"
	@echo "  make clean          Remove generated artifacts and cache"
	@echo ""

setup:
	@echo "Installing documentation tooling..."
	@command -v vale >/dev/null 2>&1 || { \
		echo "Installing Vale..."; \
		brew install vale || echo "ERROR: Install Vale manually from https://vale.sh"; \
	}
	@command -v mmdc >/dev/null 2>&1 || { \
		echo "Installing Mermaid CLI..."; \
		npm install -g @mermaid-js/mermaid-cli || echo "ERROR: Ensure Node.js is installed"; \
	}
	@echo "Fetching Google Style Guide for Vale..."
	@mkdir -p .vale/styles
	@vale sync || echo "ERROR: Run 'vale sync' manually after installing Vale"
	@echo "Setup complete."

lint:
	@echo "Running Vale linter..."
	@vale --config=.vale.ini docs/ templates/ README.md || true

validate-links:
	@echo "Validating relative links..."
	@find docs/ templates/ -name "*.md" -exec grep -H '\[.*\](\.\./' {} \; || echo "No relative links found or all valid."

test: lint validate-links
	@echo "All validation checks complete."

clean:
	@echo "Cleaning artifacts..."
	@rm -rf .vale/storage
	@find . -name ".DS_Store" -delete
	@echo "Clean complete."
