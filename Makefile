HOMEFILES := $(shell ls -A home)
DOTFILES := $(addprefix $(HOME)/,$(HOMEFILES))

.PHONEY: symlink unlink

symlink: | $(DOTFILES)

$(DOTFILES):
	@ln -sv "$(PWD)/home/$(notdir $@)" $@

# Interactively delete symbolic links.
unlink:
	@echo "Unlinking dotfiles"
	@for f in $(DOTFILES); do if [ -h $$f ]; then rm -i $$f; fi ; done
