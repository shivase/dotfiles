DOTFILES_GITHUB   := "https://github.com/kegamin/dotfiles.git"
DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*) bin .zlogin .zlogout .zpreztorc .zprofile .zshenv .zshrc
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))

list: ## list the files to be installed
	@$(foreach val, $(DOTFILES_FILES), ls -dF $(val);)

update: ## Fetch changes
	@DOTPATH=$(PWD) bash $(PWD)/bin/dotfiles_update

deploy: ## Create symlinks to the home folder
	@echo 'Copyright (c) 2013-2015 BABAROT All Rights Reserved.'
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init:  ## Setup environents
	@DOTPATH=$(PWD) bash $(PWD)/etc/init/init.sh

clean: ## Reove the dotfiles
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES_FILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTFILES_DIR)

all: install ## Updating, deploying and initializing

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

