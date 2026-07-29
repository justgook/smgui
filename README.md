# SMGUI for Odin

An idiomatic Odin rewrite of the state-mode graphical user interface toolkit
[SMGUI](https://gitlab.com/bztsrc/smgui).

The original ANSI C project is pinned as the [`reference-c`](reference-c) git
submodule. It remains the behavioral reference for API, event, and framebuffer
parity tests.

## Bootstrap

```sh
git submodule update --init --recursive
make check
make odin-build
```

Use `make help` to list Odin and reference-C build targets.

## Layout

- `smgui/ui.odin` — backend-independent interface and implementation target
- `smgui/{sdl2,sdl3,glfw,raylib,sokol}` — presentation and event adapters
- `smgui/widgets` — optional custom widgets
- `psf2`, `ssfn` — font packages
- `reference-c` — pinned original implementation
- `tests/parity` — behavioral and framebuffer parity harness

The Odin interface intentionally uses slices, enums, bit sets, and typed errors
rather than preserving C source compatibility.
