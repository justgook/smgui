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

Use `make help` to list Odin and reference-C build targets. `make run` launches
the Odin migration target derived from
[`reference-c/docs/screen1.png`](reference-c/docs/screen1.png); `make c-run`
launches the original C `widgets` example behind that screenshot.

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

The default commands show the migration target and its original reference:

```sh
make run                         # Odin target with Raylib
make c-run                       # upstream reference-c/examples/widgets.c
```

This target stays intentionally visible while parity work proceeds, making
cross-form layout gaps and missing controls obvious. For exact paired form trees
used by framebuffer comparison, run:

```sh
make smoke-odin
make smoke-c
```

Other examples and backends remain selectable explicitly:

```sh
make run EXAMPLE=basic BACKEND=raylib
make run BACKEND=sokol              # same smoke forms via Sokol
make c-example-run C_EXAMPLE=helloworld
```

Both `make run` commands render the same `examples/smoke` form tree. The Sokol
adapter uses [`sokol-odin`](vendor/sokol-odin) and owns the platform loop, so
Sokol applications call `smgui/sokol.run` with their context, forms, and
optional init/frame hooks. `make sokol-libs` builds its native libraries;
normal `make check` and Sokol builds do this automatically.

Run completed small framebuffer fixtures, or generate the large smoke fixture:

```sh
make parity                        # expected-green element/state fixtures
make parity-case CASE=empty
make parity-fuzz FUZZ_SEED=1 FUZZ_CASES=20
make smoke-images
make smoke-compare                 # non-zero until smoke parity is reached
```

See `tests/manual/README.md` for covered controls and the comparison procedure.
`BACKEND` is part of the build interface now; additional values will become
available as their adapters are migrated.
