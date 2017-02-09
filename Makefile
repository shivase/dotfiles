DOTFILES_GITHUB   := "https://github.com/kegamin/dotfiles.git"
DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*) bin .zlogin .zlogout .zpreztorc .zprofile .zshenv .zshrc
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))

all: install

help:
	@echo "make list           #=> List the files"
	@echo "make update         #=> Fetch changes"
	@echo "make deploy         #=> Create symlink"
	@echo "make init           #=> Setup environment"
	@echo "make install        #=> Updating, deploying and initializng"
	@echo "make clean          #=> Remove the dotfiles"

list:
	@$(foreach val, $(DOTFILES_FILES), ls -dF $(val);)

update:
	@DOTPATH=$(PWD) bash $(PWD)/bin/dotfiles_update

deploy:
	@echo 'Copyright (c) 2013-2015 BABAROT All Rights Reserved.'
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

init:
	@DOTPATH=$(PWD) bash $(PWD)/etc/init/init.sh

install: update deploy init
	@exec $$SHELL

clean:
	@echo 'Remove dot files in your home directory...'
	@-$(foreach val, $(DOTFILES_FILES), rm -vrf $(HOME)/$(val);)
	-rm -rf $(DOTFILES_DIR)
