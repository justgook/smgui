# Paired manual smoke test

The smoke test is a project-owned, side-by-side form fixture inspired by
`tmp/screen1.png` / `reference-c/docs/screen1.png`. It uses the same strings,
initial values, 640×480 window, and supported form tree in both implementations.

Run each version from the Nix/direnv development shell:

```sh
make smoke-c
make smoke-odin
```

Compare the initial layout and then exercise menus, collapsible sections, text
and numeric inputs, selection controls, sliders, scrollbars, scrollable popups,
wheel routing, custom-form rendering, choices, and buttons. Close one
window before starting the other unless the platform supports running both from
separate terminals.

The fixture currently excludes the custom file widget, which is not yet
implemented by the Odin port. Add it to **both** smoke examples when its
structural migration slice lands.

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
