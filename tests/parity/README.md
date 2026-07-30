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
`parity` runs the registry of completed, expected-green cases. Current green
cases are `empty`, `label-normal`, `button-normal`, and
`button-explicit-size`, `button-hover`, `button-pressed`, `button-disabled`, and
`checkbox-normal`, `checkbox-checked`, `checkbox-hover`, `checkbox-pressed`, and
`checkbox-disabled`, `radio-normal`, `radio-selected`, `radio-hover`, and
`radio-pressed`, `radio-disabled`, `slider-minimum`, `slider-midpoint`, and
`slider-maximum`, `slider-interaction`, `slider-disabled`, `progress-minimum`, `progress-midpoint`, and
`progress-maximum`, `progress-disabled`, `decimal-normal`, `decimal-negative`, and
`decimal-explicit-size`, `decimal-disabled`, `hex-normal`, `hex-zero`, `hex-explicit-size`, `hex-disabled`, `float-normal`, `float-magnitude`, `float-explicit-size`, `float-disabled`, `text-input-normal`, and `text-input-empty`.

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

```sh
make parity-fuzz                         # seed 1, 20 cases
make parity-fuzz FUZZ_SEED=123 FUZZ_CASES=10
```

Fuzzing uses the same C/Odin image and comparison path. Generation is bounded
and deterministic: every run prints its seed, case number, dimensions, and an
exact replay command on failure. The current pool varies framebuffer dimensions
from 32–256 by 24–192 across the completed `empty`, `label-normal`,
`button-normal`, `button-explicit-size`, `button-hover`, `button-pressed`, and
`button-disabled`, `checkbox-normal`, `checkbox-checked`, `checkbox-hover`, and
`checkbox-pressed`, `checkbox-disabled`, `radio-normal`, `radio-selected`, and
`radio-hover`, `radio-pressed`, `radio-disabled`, `slider-minimum`, and
`slider-midpoint`, `slider-maximum`, `slider-interaction`, and `slider-disabled`, `progress-minimum`, `progress-midpoint`, and
`progress-maximum`, `progress-disabled`, `decimal-normal`, and `decimal-negative`, `decimal-explicit-size`, `decimal-disabled`, `hex-normal`, `hex-zero`, `hex-explicit-size`, `hex-disabled`, `float-normal`, `float-magnitude`, `float-explicit-size`, `float-disabled`, `text-input-normal`, and `text-input-empty` fixtures.
Form kinds and states enter the pool only after their small fixtures pass.

A discovered mismatch is replayed, minimized, and promoted to a named
deterministic fixture before the underlying behavior is changed.
