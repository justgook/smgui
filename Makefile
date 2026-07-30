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
# The default Odin target is the screen1 migration fixture.
EXAMPLE ?= smoke
BACKEND ?= raylib
EXAMPLE_DIR := examples/$(EXAMPLE)
ODIN_CHECK_FLAGS ?= -no-entry-point -strict-style -vet-cast -vet-semicolon -vet-shadowing -vet-style -vet-unused-imports -vet-unused-variables -warnings-as-errors
BUILD_DIR ?= build.nosync
ODIN_BIN ?= $(BUILD_DIR)/$(EXAMPLE)-$(BACKEND)
C_EXAMPLE ?= widgets
C_EXAMPLES_DIR := reference-c/examples
C_BIN := $(C_EXAMPLES_DIR)/$(C_EXAMPLE)
SMOKE_C_SOURCE := tests/manual/smoke.c
SMOKE_C_BIN := $(BUILD_DIR)/smoke-c
SMOKE_C_IMAGE_BIN := $(BUILD_DIR)/smoke-image-c
SMOKE_ODIN_IMAGE_BIN := $(BUILD_DIR)/smoke-image-odin
PNG_COMPARE_BIN := $(BUILD_DIR)/compare-png
PARITY_ACTUAL_DIR := tests/parity/actual
SMOKE_C_PNG := $(PARITY_ACTUAL_DIR)/smoke-c.png
SMOKE_ODIN_PNG := $(PARITY_ACTUAL_DIR)/smoke-odin.png
PARITY_C_BIN := $(BUILD_DIR)/parity-case-c
PARITY_ODIN_BIN := $(BUILD_DIR)/parity-case-odin
PARITY_CASES := empty label-normal button-normal button-explicit-size button-hover button-pressed button-disabled checkbox-normal checkbox-checked checkbox-hover checkbox-pressed checkbox-disabled radio-normal radio-selected radio-hover radio-pressed radio-disabled slider-minimum slider-midpoint slider-maximum slider-interaction slider-disabled progress-minimum progress-midpoint progress-maximum progress-disabled decimal-normal decimal-negative decimal-explicit-size decimal-disabled hex-normal hex-zero hex-explicit-size hex-disabled float-normal float-magnitude float-explicit-size float-disabled text-input-normal text-input-empty text-input-explicit-size text-input-edit text-input-disabled numeric-input-normal numeric-input-explicit-size numeric-input-decrement numeric-input-increment numeric-input-disabled select-normal select-explicit-size select-pressed select-open select-choice select-disabled option-normal option-explicit-size option-decrement option-increment option-disabled popup-normal popup-intrinsic popup-no-border popup-no-shadow popup-title popup-draggable popup-resizable popup-hidden popup-close menu-closed menu-button-closed menu-button-open menu-open menu-intrinsic menu-anchored menu-hover menu-disabled menu-choice menu-outside-close menu-escape-close
CASE ?= empty
WIDTH ?= 64
HEIGHT ?= 48
FUZZ_SEED ?= 1
FUZZ_CASES ?= 20
PARITY_C_PNG = $(PARITY_ACTUAL_DIR)/$(CASE)-$(WIDTH)x$(HEIGHT)-c.png
PARITY_ODIN_PNG = $(PARITY_ACTUAL_DIR)/$(CASE)-$(WIDTH)x$(HEIGHT)-odin.png
PKG_CONFIG ?= pkg-config
C_REFERENCE_CC := $(CC)
C_REFERENCE_GLFW_CFLAGS := $(shell $(PKG_CONFIG) --cflags glfw3 2>/dev/null)
C_REFERENCE_CPPFLAGS := $(C_REFERENCE_GLFW_CFLAGS)
C_REFERENCE_LIBS := $(shell $(PKG_CONFIG) --libs glfw3 2>/dev/null)
ifeq ($(shell uname -s),Darwin)
C_REFERENCE_CC := $(CURDIR)/compat/macos/cc
C_REFERENCE_CPPFLAGS += -I$(CURDIR)/compat/macos -DGL_SILENCE_DEPRECATION -DUI_GLFW_NOSHADER
C_REFERENCE_LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreFoundation -lm
else
C_REFERENCE_LIBS += -lGL -lm
endif

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
	  '  build        Build EXAMPLE with BACKEND' \
	  '  run          Run the Odin screen1 migration target (default)' \
	  '               EXAMPLE=basic BACKEND=raylib selects another example' \
	  '' \
	  'Paired manual smoke test:' \
	  '  smoke-odin    Run the Odin widget smoke test' \
	  '  smoke-c       Run the equivalent reference-C smoke test' \
	  '  smoke-images  Render both smoke tests directly to PNG' \
	  '  smoke-compare Compare decoded RGBA output (fails on mismatch)' \
	  '' \
	  'Framebuffer parity:' \
	  '  parity-case CASE=name  Compare one small deterministic fixture' \
	  '  parity                 Compare every completed fixture' \
	  '  parity-fuzz            Run seeded bounded cases (FUZZ_SEED=1 FUZZ_CASES=20)' \
	  '' \
	  'Reference C targets:' \
	  '  c-run, run-c      Run the upstream C widgets target behind screen1' \
	  '  reference-c-init  Initialize/update the C git submodule' \
	  '  c-build           Build upstream C_EXAMPLE (default: widgets)' \
	  '  c-example-run     Build and run upstream C_EXAMPLE' \
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
	$(Q)test "$(BACKEND)" = raylib || { echo "Backend '$(BACKEND)' is not implemented yet" >&2; exit 2; }
	$(Q)$(ODIN) build "$(EXAMPLE_DIR)" $(ODIN_FLAGS) -out:"$(ODIN_BIN)"

.PHONY: run
run: build
	$(Q)"$(ODIN_BIN)"

.PHONY: smoke-odin
smoke-odin:
	$(Q)$(MAKE) run EXAMPLE=smoke

.PHONY: reference-c-init
reference-c-init:
	$(Q)git submodule update --init --recursive reference-c

.PHONY: c-build
c-build: reference-c-init
	$(Q)$(PKG_CONFIG) --exists glfw3 || { echo "GLFW development files not found; enter the direnv/Nix shell first" >&2; exit 2; }
	$(Q)$(MAKE) -C "$(C_EXAMPLES_DIR)" "$(C_EXAMPLE)" \
		CC="$(C_REFERENCE_CC) $(C_REFERENCE_CPPFLAGS)" \
		LIBS="$(C_REFERENCE_LIBS)"

.PHONY: c-run run-c c-example-run
c-run run-c c-example-run: c-build
	$(Q)"$(C_BIN)"

$(SMOKE_C_BIN): $(SMOKE_C_SOURCE) | $(BUILD_DIR) reference-c-init
	$(Q)$(PKG_CONFIG) --exists glfw3 || { echo "GLFW development files not found; enter the direnv/Nix shell first" >&2; exit 2; }
	$(Q)$(C_REFERENCE_CC) $(C_REFERENCE_CPPFLAGS) \
		-std=c99 -Wall -Wextra -Wno-pragmas -O2 \
		-Ireference-c -Ireference-c/mods "$<" -o "$@" $(C_REFERENCE_LIBS)

.PHONY: smoke-c-build
smoke-c-build: $(SMOKE_C_BIN)

.PHONY: smoke-c
smoke-c: smoke-c-build
	$(Q)"$(SMOKE_C_BIN)"

$(SMOKE_C_IMAGE_BIN): $(SMOKE_C_SOURCE) tests/parity/c/ui_image_backend.h tests/vendor/stb_image_write.h | $(BUILD_DIR) reference-c-init
	$(Q)$(C_REFERENCE_CC) -DSMOKE_IMAGE_BACKEND \
		-std=c99 -Wall -Wextra -Wno-pragmas -O2 \
		-Itests/parity/c -Itests/vendor -Ireference-c -Ireference-c/mods \
		"$(SMOKE_C_SOURCE)" -o "$@" -lm

$(SMOKE_ODIN_IMAGE_BIN): examples/smoke/main.odin smgui/ui.odin smgui/image/image.odin psf2/psf2.odin | $(BUILD_DIR)
	$(Q)$(ODIN) build examples/smoke $(ODIN_FLAGS) -out:"$@"

$(PNG_COMPARE_BIN): tests/parity/compare/main.odin | $(BUILD_DIR)
	$(Q)$(ODIN) build tests/parity/compare $(ODIN_FLAGS) -out:"$@"

$(PARITY_ACTUAL_DIR):
	$(Q)mkdir -p "$@"

.PHONY: smoke-images
smoke-images: $(SMOKE_C_IMAGE_BIN) $(SMOKE_ODIN_IMAGE_BIN) | $(PARITY_ACTUAL_DIR)
	$(Q)"$(SMOKE_C_IMAGE_BIN)" "$(SMOKE_C_PNG)"
	$(Q)"$(SMOKE_ODIN_IMAGE_BIN)" --output "$(SMOKE_ODIN_PNG)"
	$(Q)printf 'Wrote %s\nWrote %s\n' "$(SMOKE_C_PNG)" "$(SMOKE_ODIN_PNG)"

.PHONY: smoke-compare
smoke-compare: smoke-images $(PNG_COMPARE_BIN)
	$(Q)"$(PNG_COMPARE_BIN)" "$(SMOKE_C_PNG)" "$(SMOKE_ODIN_PNG)"

$(PARITY_C_BIN): tests/parity/c/cases.c tests/parity/c/ui_image_backend.h tests/vendor/stb_image_write.h | $(BUILD_DIR) reference-c-init
	$(Q)$(C_REFERENCE_CC) -std=c99 -Wall -Wextra -Wno-pragmas -O2 \
		-Itests/parity/c -Itests/vendor -Ireference-c -Ireference-c/mods \
		tests/parity/c/cases.c -o "$@" -lm

$(PARITY_ODIN_BIN): tests/parity/cases/main.odin smgui/ui.odin smgui/image/image.odin psf2/psf2.odin | $(BUILD_DIR)
	$(Q)$(ODIN) build tests/parity/cases $(ODIN_FLAGS) -out:"$@"

.PHONY: parity-case
parity-case: $(PARITY_C_BIN) $(PARITY_ODIN_BIN) $(PNG_COMPARE_BIN) | $(PARITY_ACTUAL_DIR)
	$(Q)"$(PARITY_C_BIN)" "$(CASE)" "$(PARITY_C_PNG)" "$(WIDTH)" "$(HEIGHT)"
	$(Q)"$(PARITY_ODIN_BIN)" "$(CASE)" "$(PARITY_ODIN_PNG)" "$(WIDTH)" "$(HEIGHT)"
	$(Q)"$(PNG_COMPARE_BIN)" "$(PARITY_C_PNG)" "$(PARITY_ODIN_PNG)"

.PHONY: parity
parity:
	$(Q)for parity_case in $(PARITY_CASES); do \
		echo "Parity $$parity_case"; \
		$(MAKE) parity-case CASE="$$parity_case"; \
	done

.PHONY: parity-fuzz
parity-fuzz:
	$(Q)tests/parity/fuzz.sh "$(FUZZ_SEED)" "$(FUZZ_CASES)" | \
	while read -r index parity_case width height; do \
		echo "Fuzz seed=$(FUZZ_SEED) case=$$index $$parity_case $${width}x$${height}"; \
		$(MAKE) parity-case CASE="$$parity_case" WIDTH="$$width" HEIGHT="$$height" || { \
			echo "Replay: make parity-case CASE=$$parity_case WIDTH=$$width HEIGHT=$$height" >&2; \
			exit 1; \
		}; \
	done

.PHONY: clean
clean:
	$(Q)rm -rf "$(BUILD_DIR)"
	$(Q)if [ -f "$(C_EXAMPLES_DIR)/Makefile" ]; then $(MAKE) -C "$(C_EXAMPLES_DIR)" clean; fi
