# Test-only vendored dependencies

`stb_image_write.h` is copied from the Odin toolchain pinned by `flake.nix` so
the reference-C and Odin image adapters use the same stb implementation.

- Upstream: <https://github.com/nothings/stb/blob/master/stb_image_write.h>
- Version declared by header: 1.16
- License: public domain or MIT, as described at the end of the header
- SHA-256: `24d110c51536eea49b99b3ef9eb717e3587338358d41b2596d5b1d1c0b0a18b8`

Do not update this copy independently of the pinned Odin toolchain.
