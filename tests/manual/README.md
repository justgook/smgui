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
and numeric inputs, selection controls, sliders, choices, and buttons. Close one
window before starting the other unless the platform supports running both from
separate terminals.

The fixture currently excludes controls not yet implemented by the Odin port:
images/icons, color input, scrollbars, toggle/icon buttons, and the custom file
widget. Add each to **both** smoke examples when its parity slice lands.

This visual check is a development aid. Deterministic headless framebuffer
fixtures remain the acceptance test for pixel parity.
