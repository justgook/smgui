# Parity tests

Parity testing will run equivalent deterministic fixtures against:

1. the pinned `reference-c` implementation;
2. the Odin implementation;
3. scripted input/state transitions; and
4. the resulting software framebuffers.

The first milestone uses PSF2 and headless image adapters so pixel comparisons
do not depend on native window capture or a presentation backend.

## Small element fixtures

```sh
make parity-case CASE=empty
make parity
```

`parity-case` renders one named C/Odin case and compares decoded RGBA pixels.
`parity` runs the registry of completed, expected-green cases. The first tracer
is a 64×48 empty framebuffer; label positioning is next.

## Widget smoke fixture

```sh
make smoke-images   # write both PNGs under tests/parity/actual
make smoke-compare  # decode and compare RGBA pixels; non-zero on mismatch
```

Both adapters encode their software framebuffer with the pinned
`stb_image_write` implementation. `tests/parity/compare` decodes both outputs
to RGBA before comparison, so parity does not depend on compressed PNG bytes.

The initial fixture deliberately records existing differences. The first run
identified and fixed Odin's opaque framebuffer clear. The current first
mismatch is at `(0,2)`, where text/layout pixels begin at a different vertical
position. This is parity work, not image-adapter behavior.

## Seeded fuzz fixtures

Fuzzing will use the same C/Odin image and comparison path. Generation is
bounded and deterministic: a run accepts a seed and case count, prints both,
and preserves the generated case on failure. Only Form kinds and states with
passing small fixtures enter the fuzz pool. A discovered mismatch is replayed
by seed, minimized, and promoted to a named deterministic fixture before the
underlying behavior is changed.
