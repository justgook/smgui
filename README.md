# SMGUI for Odin

An idiomatic Odin rewrite of the state-mode graphical user interface toolkit
[SMGUI](https://gitlab.com/bztsrc/smgui).

The original ANSI C project is pinned as the [`reference-c`](reference-c) git
submodule. It remains the behavioral reference for API, event, and framebuffer
parity tests.

## Bootstrap

Install [Nix](https://nixos.org/download/) and
[direnv](https://direnv.net/), then clone and enter the repository:

```sh
git clone --recurse-submodules <repository-url>
cd smgui
direnv allow
make check
make run
```

Direnv loads the pinned Nix development shell from `flake.nix`, including
Odin, the C toolchain, GLFW, and native graphics dependencies. After changing
`flake.nix` or `flake.lock`, approve it again with `direnv allow`.

Use `make help` to list Odin and reference-C build targets. The pinned C
reference example can be run with `make run-c`.

## Layout

- `examples` — visual/manual migration examples (`make run`)
- `smgui/ui.odin` — backend-independent interface and implementation target
- `smgui/{sdl2,sdl3,glfw,raylib,sokol}` — presentation and event adapters
- `smgui/widgets` — optional custom widgets
- `psf2`, `ssfn` — font packages
- `reference-c` — pinned original implementation
- `tests/parity` — behavioral and framebuffer parity harness

The Odin interface intentionally uses slices, enums, bit sets, and typed errors
rather than preserving C source compatibility.

The growing production-readiness showcase currently uses Raylib:

```sh
make run                         # examples/basic with Raylib
make run EXAMPLE=basic BACKEND=raylib
```

For a manual side-by-side comparison of equivalent C and Odin form trees, run:

```sh
make smoke-c
make smoke-odin
```

Generate and compare the same fixture without opening windows:

```sh
make smoke-images
make smoke-compare                 # non-zero until framebuffer parity is reached
```

See `tests/manual/README.md` for covered controls and the comparison procedure.
`BACKEND` is part of the build interface now; additional values will become
available as their adapters are migrated.
