SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifdef V
Q :=
else
Q := @
MAKEFLAGS += --no-print-directory
endif

ODIN ?= odin
ODIN_FLAGS ?=
ODIN_CHECK_FLAGS ?= -no-entry-point -strict-style -vet-cast -vet-semicolon -vet-shadowing -vet-style -vet-unused-imports -vet-unused-variables -warnings-as-errors
BUILD_DIR ?= build.nosync
ODIN_BIN ?= $(BUILD_DIR)/smgui
C_EXAMPLE ?= helloworld
C_EXAMPLES_DIR := reference-c/examples
C_BIN := $(C_EXAMPLES_DIR)/$(C_EXAMPLE)

.DEFAULT_GOAL := run

.PHONY: help
help:
	$(Q)printf '%s\n' \
	  'Usage: make <target>' \
	  '' \
	  'Odin targets:' \
	  '  all          Check and build the Odin rewrite' \
	  '  check        Check every Odin package' \
	  '  test         Run every Odin test package' \
	  '  build        Build the native smoke executable' \
	  '  run          Build and run the native smoke executable (default)' \
	  '' \
	  'Reference C targets:' \
	  '  reference-c-init  Initialize/update the C git submodule' \
	  '  c-build           Build C_EXAMPLE (default: helloworld)' \
	  '  c-run             Build and run C_EXAMPLE' \
	  '' \
	  'Other:' \
	  '  clean        Remove Odin and C build output' \
	  '  V=1          Show commands'

.PHONY: all
all: check build

.PHONY: check
check:
	$(Q)packages=$$(find . -path ./reference-c -prune -o -name '*.odin' -print | sed 's#/[^/]*$$##' | LC_ALL=C sort -u); \
	for package in $$packages; do \
		echo "Checking $$package"; \
		$(ODIN) check "$$package" $(ODIN_CHECK_FLAGS); \
	done

.PHONY: test
test:
	$(Q)$(ODIN) test . -all-packages $(ODIN_FLAGS)

$(BUILD_DIR):
	$(Q)mkdir -p "$@"

.PHONY: build
build: | $(BUILD_DIR)
	$(Q)$(ODIN) build . $(ODIN_FLAGS) -out:"$(ODIN_BIN)"

.PHONY: run
run: build
	$(Q)"$(ODIN_BIN)"

.PHONY: reference-c-init
reference-c-init:
	$(Q)git submodule update --init --recursive reference-c

.PHONY: c-build
c-build: reference-c-init
	$(Q)$(MAKE) -C "$(C_EXAMPLES_DIR)" "$(C_EXAMPLE)"

.PHONY: c-run
c-run: c-build
	$(Q)"$(C_BIN)"

.PHONY: clean
clean:
	$(Q)rm -rf "$(BUILD_DIR)"
	$(Q)if [ -f "$(C_EXAMPLES_DIR)/Makefile" ]; then $(MAKE) -C "$(C_EXAMPLES_DIR)" clean; fi
