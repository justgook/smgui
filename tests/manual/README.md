# Paired manual smoke test

The smoke test is a project-owned, side-by-side form fixture inspired by
`tmp/screen1.png` / `reference-c/docs/screen1.png`. It uses the same strings,
initial values, 640×480 window, and supported form tree in both implementations.
Every core form kind is represented, including all 8/16/32/64-bit decimal,
hexadecimal, and integer-input variants.

Run each version from the Nix/direnv development shell:

```sh
make smoke-c
make smoke-odin
```

Compare the initial layout and then exercise menus, collapsible sections, text
and numeric inputs, selection controls, sliders, scrollbars, scrollable popups,
wheel routing, custom-form rendering, the software cursor, choices, and buttons. Close one
window before starting the other unless the platform supports running both from
separate terminals. Interactive smoke windows show an FPS meter in the bottom-right.
`make c-run` also shows the meter by applying `widgets-fps.patch` to a generated
build copy of upstream `widgets.c`; the pinned Reference C submodule is unchanged.

The fixture excludes higher-level Odin-only widgets that have no Reference C
form counterpart. Core `ui.h` form coverage must remain paired: additions or
changes belong in **both** smoke examples.

Generate deterministic PNGs directly from the two software framebuffers:

```sh
make smoke-images
```

This writes ignored local artifacts to:

- `tests/parity/actual/smoke-c.png`
- `tests/parity/actual/smoke-odin.png`

Compare their decoded RGBA pixels with:

```sh
make smoke-compare
```

The compare command exits non-zero and reports the first differing coordinate
until parity is reached. Window screenshots remain a development aid; these
headless framebuffer images are the acceptance surface.
