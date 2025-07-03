.DEFAULT_GOAL := install

.PHONY: install
install:
	swift build

.PHONY: run-example
run-example:
	$(MAKE) install
	swift run ExampleApp
