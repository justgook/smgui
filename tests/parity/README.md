# Parity tests

Parity testing will run equivalent deterministic fixtures against:

1. the pinned `reference-c` implementation;
2. the Odin implementation;
3. scripted input/state transitions; and
4. the resulting software framebuffers.

The first milestone uses PSF2 and a headless runner so pixel comparisons do not
depend on native window capture or a particular presentation backend.
