# ------------------------------------------------------------------------
#
# General stuff
#

# Detect OS
OS = $(shell uname -s)

# Defaults
ECHO = echo

# Make adjustments based on OS
# http://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux/27776822#27776822
ifneq (, $(findstring CYGWIN, $(OS)))
	ECHO = /bin/echo -e
endif

# Colors and helptext
NO_COLOR	= \033[0m
ACTION		= \033[32;01m
OK_COLOR	= \033[32;01m
ERROR_COLOR	= \033[31;01m
WARN_COLOR	= \033[33;01m

# Which makefile am I in?
WHERE-AM-I = $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_MAKEFILE := $(call WHERE-AM-I)

# Echo some nice helptext based on the target comment
HELPTEXT = $(ECHO) "$(ACTION)--->" `egrep "^\# target: $(1) " $(THIS_MAKEFILE) | sed "s/\# target: $(1)[ ]*-[ ]* / /g"` "$(NO_COLOR)"

# Check version  and path to command and display on one line
CHECK_VERSION = $(ECHO) `basename $(1)` `$(1) --version $(2)` `which $(1)`



# ------------------------------------------------------------------------
#
# Specifics
#
BIN     := .bin

SHELLCHECK := $(BIN)/shellcheck
BATS       := $(BIN)/bats

INSTALL_DIR := /usr/local/bin



# target: help               - Displays help.
.PHONY:  help
help:
	@$(call HELPTEXT,$@)
	@$(ECHO) "Usage:"
	@$(ECHO) " make [target] ..."
	@$(ECHO) "target:"
	@egrep "^# target:" $(THIS_MAKEFILE) | sed 's/# target: / /g'



# target: prepare            - Prepare for tests and build
.PHONY:  prepare
prepare:
	@$(call HELPTEXT,$@)
	[ -d .bin ] || mkdir .bin
	[ -d build ] || mkdir build
	rm -rf build/*



# target: clean              - Removes generated files and directories.
.PHONY: clean
clean:
	@$(call HELPTEXT,$@)
	rm -rf build



# target: clean-cache        - Clean the cache.
.PHONY:  clean-cache
clean-cache:
	@$(call HELPTEXT,$@)
	rm -rf cache/*/*



# target: clean-all          - Removes generated files and directories.
.PHONY:  clean-all
clean-all: clean clean-cache
	@$(call HELPTEXT,$@)
	rm -rf .bin vendor



# target: check              - Check version of installed tools.
.PHONY:  check
check: check-tools-bash
	@$(call HELPTEXT,$@)



# target: test               - Run all tests.
.PHONY:  test
test: shellcheck bats
	@$(call HELPTEXT,$@)
	[ ! -f composer.json ] || composer validate



# target: doc                - Generate documentation.
.PHONY:  doc
doc: phpdoc
	@$(call HELPTEXT,$@)



# target: build              - Do all build
.PHONY:  build
build: test doc
	@$(call HELPTEXT,$@)



# target: release            - Build a release from source
.PHONY:  release
release: release-app
	@$(call HELPTEXT,$@)



# target: install            - Install the tool
.PHONY:  install
install: install-app
	@$(call HELPTEXT,$@)
	


# target: install-dev        - Install development tools
.PHONY:  install-dev
install-dev: prepare install-tools-bash
	@$(call HELPTEXT,$@)



# target: update             - Update the codebase and tools.
.PHONY:  update
update:
	@$(call HELPTEXT,$@)
	[ ! -d .git ] || git pull
	[ ! -f composer.json ] || composer update
	[ ! -f package.json ] || npm update



# target: tag-prepare        - Prepare to tag new version.
.PHONY: tag-prepare
tag-prepare: release-app
	@$(call HELPTEXT,$@)



# ------------------------------------------------------------------------
#
# App specifics
#

# target: install-app        - Install the app using repo as source.
.PHONY: install-app
install-app: release-app
	@$(call HELPTEXT,$@)
	sudo install -m 0755 src/dbwebb.bash $(INSTALL_DIR)/dbwebb3
	@$(call CHECK_VERSION, dbwebb3, | cut -d ' ' -f 1)



# target: release-app        - Build a release from source.
.PHONY: release-app
release-app:
	@$(call HELPTEXT,$@)
	install -d release/latest
	install -m 0755 src/dbwebb.bash release/latest/dbwebb
	install -m 0755 src/install.bash release/latest/install

	sha1sum release/latest/dbwebb > release/latest/dbwebb.sha1
	sha1sum release/latest/install > release/latest/install.sha1

	ls -l release/latest

	release/latest/dbwebb --version



# ------------------------------------------------------------------------
#
# Bash
#

# target: install-tools-bash - Install Bash development tools.
.PHONY: install-tools-bash
install-tools-bash:
	@$(call HELPTEXT,$@)
	# Shellcheck
	curl -s https://storage.googleapis.com/shellcheck/shellcheck-latest.linux.x86_64.tar.xz | tar -xJ -C build/ && rm -f .bin/shellcheck && ln build/shellcheck-latest/shellcheck .bin/

	# Bats
	curl -Lso $(BIN)/bats-exec-suite https://raw.githubusercontent.com/sstephenson/bats/master/libexec/bats-exec-suite
	curl -Lso $(BIN)/bats-exec-test https://raw.githubusercontent.com/sstephenson/bats/master/libexec/bats-exec-test
	curl -Lso $(BIN)/bats-format-tap-stream https://raw.githubusercontent.com/sstephenson/bats/master/libexec/bats-format-tap-stream
	curl -Lso $(BIN)/bats-preprocess https://raw.githubusercontent.com/sstephenson/bats/master/libexec/bats-preprocess
	curl -Lso $(BATS) https://raw.githubusercontent.com/sstephenson/bats/master/libexec/bats
	chmod 755 $(BIN)/bats*



# target: check-tools-bash   - Check versions of Bash tools.
.PHONY: check-tools-bash
check-tools-bash:
	@$(call HELPTEXT,$@)
	@$(call CHECK_VERSION, bash, | head -1 | cut -d ' ' -f 4)
	@$(call CHECK_VERSION, $(SHELLCHECK), | grep version: | cut -d ' ' -f 2)
	@$(call CHECK_VERSION, $(BATS))



# target: shellcheck         - Run shellcheck for bash files.
.PHONY: shellcheck
shellcheck:
	@$(call HELPTEXT,$@)
	#[ ! -f src/*.bash ] || $(SHELLCHECK) --shell=bash src/*.bash
	$(SHELLCHECK) --shell=bash src/*.bash



# target: bats               - Run bats for unit testing bash files.
.PHONY: bats
bats:
	@$(call HELPTEXT,$@)
	[ ! -d bats ] || $(BATS) bats/
