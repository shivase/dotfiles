install: ## install from Brewfile
	@brew bundle install

check: ## check if missing dependencies exists
	@brew bundle check

backup: ## Backup Brewfile
	@brew bundle dump --force

clean:
	@brew cleanup -s

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
