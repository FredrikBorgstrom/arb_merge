SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-23s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development
.PHONY: install
install: ## Install dependencies
	dart pub get

.PHONY: lint
lint: ## Lint code
	dart analyze .

.PHONY: format
format: ## Format code
	dart format --set-exit-if-changed --line-length 120 .

.PHONY: test
test: ## Run tests
	dart test

.PHONY: test-coverage
test-coverage: install-lcov ## Run tests with coverage
	dart run coverage:test_with_coverage
	@if which genhtml > /dev/null; then genhtml coverage/lcov.info -o coverage/html; fi

##@ Build
.PHONY: bump
bump: ## install-bumper ## Bump version
	@current=$$(grep '^version:' pubspec.yaml | head -n1 | cut -d' ' -f2); \
	read -p "Enter new version(current is $$current): " version; \
	if [[ ! $$version =~ ^[0-9]+\.[0-9]+\.[0-9]+$$ ]]; then \
		echo "Version must be in x.x.x format"; \
		exit 1; \
	fi; \
	if [[ $$(echo -e "$$version\n$$current" | sort -V | head -n1) == $$version ]]; then \
		echo "Version must be above $$current"; \
		exit 1; \
	fi; \
	sed -i.bk '5s/version: *.*.*/version: '$$version'/' pubspec.yaml; \
	rm -f pubspec.yaml.bk; \
	sed -i.bk "6s/const version = '.*';/const version = '$$version';/" bin/arb_merge.dart; \
	rm -f bin/arb_merge.dart.bk; \
	bumper --latestVersion=v$$version

.PHONY: build-example
build-example: ## Build example, config by pubspec.yaml
	dart run arb_merge --no-lastModified

##@ Tools
.PHONY: install-bumper
install-bumper: ## Install bumper
	@if ! command -v bumper &> /dev/null; then \
		npm i --global @evan361425/version-bumper; \
	fi

.PHONY: install-lcov
install-lcov: ## Install lcov
	@if ! which lcov &> /dev/null; then \
		echo "Missing lcov, you can use: brew install lcov in macOS"; \
	fi
