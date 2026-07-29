# Parity tests

Parity testing will run equivalent deterministic fixtures against:

1. the pinned `reference-c` implementation;
2. the Odin implementation;
3. scripted input/state transitions; and
4. the resulting software framebuffers.

The first milestone uses PSF2 and headless image adapters so pixel comparisons
do not depend on native window capture or a presentation backend.

## Widget smoke fixture

```sh
make smoke-images   # write both PNGs under tests/parity/actual
make smoke-compare  # decode and compare RGBA pixels; non-zero on mismatch
```

Both adapters encode their software framebuffer with the pinned
`stb_image_write` implementation. `tests/parity/compare` decodes both outputs
to RGBA before comparison, so parity does not depend on compressed PNG bytes.

The initial fixture deliberately records existing differences. Current first
mismatch: the C framebuffer leaves untouched background pixels transparent
black, while the Odin renderer fills them with `Theme_Color.Background`.
Layout differences follow after that pixel. These are parity work, not image
adapter behavior.
