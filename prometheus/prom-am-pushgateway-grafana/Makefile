# Get the git tag from the current commit...
TAG=$(shell git describe --always --dirty)
MAKEFILE_DIR=$(PWD)

.PHONY: help
help:
	@echo "+------------------+"
	@echo "| Makefile Targets |"
	@echo "+------------------+"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

.PHONY: refresh-config 
refresh-config: ## Refresh the prometheus config
	@echo "+----------------+"
	@echo "| Refresh config |"
	@echo "+----------------+"

	docker exec -i -t prometheus kill -s HUP 1
