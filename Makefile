.PHONY: test build watch

# Run tests
test:
	gleam test

# Build the project
build:
	gleam build

# Watch for changes and run tests automatically
watch:
	@./watch.sh
