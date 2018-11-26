DOTFILES_GITHUB   := "https://github.com/kegamin/dotfiles.git"
DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*) bin .zlogin .zlogout .zpreztorc .zprofile .zshenv .zshrc
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))

.DEFAULT_GOAL := help
.PHONY: help init symlinks update

init:  ## Setup environents
	@DOTPATH=$(PWD) bash $(PWD)/init/init.sh

deploy: ## deploy to the home folder
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

update: ## Fetch changes
	@DOTPATH=$(PWD) bash $(PWD)/bin/dotfiles_update

install: init deploy update ## Runs init, deploy, update

brew_install: ## install brew targets
	@cd brew && make install

brew_clean:
	@cd brew && make clean

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

