# SMGUI Odin migration context

## Purpose

SMGUI is an idiomatic Odin rewrite of the pinned C implementation in
`reference-c`. The target is **1:1 observable behavior**, not source or ABI
compatibility. Odin callers should receive the same layout, state transitions,
events, and framebuffer output while using Odin-native types and errors.

## Domain language

- **Reference C** — the pinned `reference-c` submodule; the behavioral authority.
- **Odin port** — the implementation under `smgui` and its optional font/widget
  packages.
- **Parity slice** — one independently testable reference behavior migrated from
  end to end.
- **Form** — a declarative UI entry (`smgui.Form` / `ui_form_t`).
- **Context** — all runtime, input, layout, and framebuffer state for one UI.
- **Adapter** — presentation and platform-event integration behind
  `smgui.Backend`.
- **Fixture** — deterministic forms, state, and scripted events run against both
  implementations.
- **Behavioral parity** — equivalent state, events, errors, geometry, and pixels
  for a fixture. Equivalent does not require C-compatible names or memory
  layout.

## Migration invariants

1. `reference-c` stays pinned; changes belong in the Odin port or test harness.
2. Core layout, control, and drawing behavior stays backend-independent.
3. Adapters translate platform input and present `Context.screen`; they do not
   implement widget behavior.
4. Public Odin interfaces prefer slices, enums, bit sets, and typed errors over
   C source compatibility.
5. Unsupported work returns `Error.Not_Implemented`; no operation reports
   success before performing its documented work.
6. Tests compare decoded RGBA output from deterministic software framebuffers,
   not window screenshots or compressed PNG bytes.
7. Every user-visible parity slice updates both `tests/manual/smoke.c` and
   `examples/smoke/main.odin` so their shared fixture stays equivalent.
8. A commit contains one coherent parity slice or one prerequisite for parity.

## Work loop and definition of done

For each job:

1. Name the next possible parity slice and identify its C reference.
2. Recommend the smallest high-leverage next slice.
3. Add or update a deterministic test that defines the expected behavior.
4. Implement the slice without unrelated cleanup.
5. Run `make check`, `make test`, and any slice-specific parity command.
6. Update the checklist below and nearby module status comments.
7. Commit in the existing style, for example
   `✨(widget): add image and icon forms`.
8. Report behavior delivered, tests run, commit, and the next candidate.

A parity slice is done when:

- its supported inputs, outputs, state transitions, and error cases are explicit;
- equivalent C and Odin fixtures cover the public behavior;
- deterministic geometry/framebuffer output matches where the slice renders;
- `make check` and `make test` pass;
- both paired manual smoke examples are updated when the behavior is
  user-visible;
- no placeholder success path remains for the slice; and
- documentation/checklists describe the resulting state.

The project is done when every supported public C operation, form kind, flag,
and event path has a completed parity slice on every supported adapter.

## Parity test layers

1. **Element fixtures** — small deterministic images for one Form kind, size, or
   interaction state. `make parity` runs only fixtures already expected to
   match; a new fixture is added red and fixed before the next one.
2. **Widget smoke fixture** — one large representative composition that exposes
   cross-Form layout differences. It may remain red while smaller slices are
   being completed.
3. **Seeded fuzz fixtures** — bounded random screen sizes, values, Form order,
   and supported flags. Fuzzing may use only Form behaviors whose deterministic
   element fixtures are green. Every failure reports its seed and generated
   case so it can be replayed exactly and promoted to a deterministic regression
   fixture.

Fuzz runs are reproducible by default: CI uses recorded seeds and a fixed case
count. An explicit random-seed mode is for local discovery and must print the
chosen seed before generating input.

## Ordered migration checklist

This is the canonical next-work list. Module-local status comments summarize
only their module and must agree with this list.

### Foundation

- [x] Pin the C reference as a submodule.
- [x] Provide a reproducible Nix/direnv environment for Odin and C.
- [x] Implement the Odin public types, backend seam, framebuffer lifecycle, and
  bounded event queue.
- [x] Add paired C/Odin manual smoke examples for currently migrated widgets.
- [x] Build headless stb image adapters and decoded-RGBA comparison tooling.
- [x] Pass the 64×48 empty-framebuffer tracer fixture.
- [x] Pass the normal-label glyph, baseline, and intrinsic-size fixture.
- [x] Pass the normal button fixture.
- [x] Pass the explicit-size button fixture.
- [x] Pass the scripted button-hover fixture.
- [x] Pass the scripted button-pressed fixture.
- [x] Pass the button-disabled fixture.
- [x] Pass the normal unchecked checkbox fixture.
- [x] Pass the checked checkbox fixture.
- [x] Pass the scripted checkbox-hover fixture.
- [x] Pass the scripted checkbox-pressed fixture and bound-value mutation.
- [x] Pass the checkbox-disabled fixture.
- [x] Pass the normal unselected radio fixture.
- [x] Pass the selected radio fixture.
- [ ] Pass radio hover, pressed, and disabled fixtures.
- [x] Add reproducible bounded framebuffer-size fuzzing for completed fixtures;
  expand its Form pool only as element fixtures turn green.
- [ ] Make the paired widget smoke framebuffer fixture match reference C.
- [ ] Add a parity ledger mapping public `ui.h` operations, form kinds, flags,
  and events to fixtures.

### Core parity slices

- [ ] Backfill reference parity fixtures for migrated labels, buttons, choices,
  flow divisions, value displays, sliders, progress bars, text/numeric inputs,
  selects/options, popups, and menus.
- [ ] Migrate multiline labels and status fields.
- [ ] Migrate image and icon fields.
- [ ] Migrate color input.
- [ ] Migrate toggle buttons and icon buttons.
- [ ] Migrate line, connector, and curve drawing fields.
- [ ] Migrate vertical and horizontal scrollbars.
- [ ] Migrate scrolling, dragging, resizing, and remaining alignment behavior.
- [ ] Complete drop, resize, wheel, gamepad, and remaining event processing.
- [ ] Migrate custom-form callbacks and lifecycle behavior.
- [ ] Implement software cursor and PNG skin loading.

### Packages and adapters

- [ ] Complete PSF2 Unicode-table parity.
- [ ] Port SSFN.
- [ ] Port the file, table, and text-on-screen optional widgets.
- [ ] Complete and test GLFW, SDL2, SDL3, Sokol, and WASM adapters.
- [ ] Complete remaining Raylib events and adapter parity.
- [ ] Make the showcase backend-selectable and represent every production
  module.
