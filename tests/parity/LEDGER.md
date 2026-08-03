# Core parity ledger

This ledger maps the supported public surface of `reference-c/ui.h` to the
Odin API and the fixtures that prove parity. It is the source of truth for
Milestone 2 parity work; structural implementation alone does not mark an item
green.

## Status

- **Green** — an equivalent C/Odin deterministic fixture is registered in
  `PARITY_CASES` and its framebuffer/state comparison passes.
- **Focused** — covered by an Odin behavioral test, but not yet by an equivalent
  C/Odin fixture.
- **Smoke** — represented in both paired smoke fixtures; `smoke-compare` is still
  red, so this is not parity proof.
- **Missing** — no parity fixture covers the public behavior yet.

Fixture names refer to `tests/parity/c/cases.c` and
`tests/parity/cases/main.odin`. Focused test names refer to
`smgui/ui_test.odin`.

## Public operations

| Reference C | Odin | Status | Evidence / next fixture |
|---|---|---|---|
| `ui_fonthook` | `set_font_hooks` | Missing | Add callback success/error propagation fixture. Existing framebuffer fixtures configure different C/Odin font implementations and do not prove hook parity. |
| `ui_font` | `set_font` | Missing | Add valid/invalid font selection fixture. |
| `ui_swcursor` | `set_software_cursor` | Focused, Smoke | `software_cursor_draws_and_hardware_cursor_restores_backend_cursor`; paired smoke cursor. Add cursor movement/clipping fixture. |
| `ui_hwcursor` | `use_hardware_cursor` | Focused | Same focused test; add backend-call/state fixture. |
| `ui_theme` | `set_theme` | Missing | Add theme replacement and redraw-timing fixture. Known gap: Odin requests refresh while C only replaces the theme. |
| `ui_skin` | `set_skin` | Focused | `make skin-parity` compares atlas rendering and scrollbar metrics across representative controls. Add direct-array, cursor, and redraw-timing fixtures; C does not request refresh here. |
| `ui_pngskin` | `set_png_skin` | Green, Focused | `make skin-parity` loads the bundled zTXt atlas in C and Odin; `png_skin_decodes_atlas_comment_and_replaces_owned_pixels` also covers tEXt, zTXt, replacement, and invalid input. |
| `ui_refresh` | `refresh` | Focused | Known gap: C sets both refresh and recalculate; Odin currently sets refresh only. Add explicit state/layout fixture. |
| `ui_settxt` | `set_texts` | Missing | Add runtime localization/title update fixture. Known gap: C resets cached font metrics and immediately recalculates the active form. |
| `ui_getclipboard` | `clipboard_text` | Missing | Add backend success/failure fixture. |
| `ui_setclipboard` | `set_clipboard_text` | Missing | Add backend success/failure fixture. |
| `ui_getmouse` | `mouse_position` | Focused | Mouse coordinates asserted indirectly by event tests. Add direct query fixture. |
| `ui_init` | `init` | Green | Every registered fixture covers the successful lifecycle; invalid input/backend failure still need focused cross-implementation assertions. |
| `ui_fullscreen` | `toggle_fullscreen` | Missing | Add backend invocation/error fixture. |
| `ui_getwindow` | `native_window` | Missing | Add native handle fixture. |
| `ui_event` | `poll_event` | Green | All scripted interaction fixtures; expand for event kinds below. |
| `ui_free` | `deinit` | Green, Focused | Every registered fixture plus custom finalization and PNG ownership tests. |

Odin-native `Text_Buffer`, typed `Binding`, `push_event`, and
`resize_framebuffer` replace C pointer/string and private queue helpers. Their
observable behavior belongs to the corresponding form and event rows below.

## Form kinds

| Reference C | Odin `Field_Kind` | Status | Evidence / next fixture |
|---|---|---|---|
| `UI_END` | `End` / slice termination | Green | All registered fixtures use bounded Odin slices; C fixtures retain `UI_END` sentinels. |
| `UI_POPUP` | `Popup` | Green | `popup-normal`, `popup-intrinsic`, chrome/flag and drag/resize/close fixtures. Scrolling remains Focused. |
| `UI_MENU` | `Menu` | Green | `menu-closed` through `menu-escape-close`. |
| `UI_DIV` | `Division` | Green | `division-intrinsic`, `division-percentage`; advanced flow/alignment is Focused. |
| `UI_LABEL` | `Label` | Green | `label-normal`; disabled/menu variants are covered by menu fixtures. |
| `UI_MLINE` | `Multiline_Label` | Green, Focused, Smoke | `multiline-normal`; `multiline_labels_and_status_fields_render`. Explicit sizing, wrapping, and alignment remain to cover. |
| `UI_STATUS` | `Status` | Green, Focused, Smoke | `status-normal`; `multiline_labels_and_status_fields_render`. Hover-description placement remains to cover. |
| `UI_DEC_FLOAT` | `Decimal_Float` | Green | `float-normal`, `float-magnitude`, explicit-size, disabled. |
| `UI_PBAR` | `Progress_Bar` | Green | minimum/midpoint/maximum/disabled fixtures. |
| `UI_IMAGE` | `Image` | Focused, Smoke | `image_and_icon_fields_render_and_activate`. |
| `UI_ICON` | `Icon` | Green, Focused, Smoke | `icon-scaled` and `icon-disabled` cover aspect-preserving bilinear scaling, alpha blending, and grayscale rendering; `image_and_icon_fields_render_and_activate` covers activation. |
| `UI_DEC8/16/32` | `Decimal_8/16/32` | Smoke | Paired all-components smoke; add width/signed-value fixtures for each binding width. |
| `UI_DEC64` | `Decimal_64` | Green, Smoke | `decimal-normal`, negative, explicit-size, disabled; paired smoke. |
| `UI_HEX8/16/32` | `Hexadecimal_8/16/32` | Smoke | Paired all-components smoke; add truncation/format fixtures for each width. |
| `UI_HEX64` | `Hexadecimal_64` | Green, Smoke | `hex-normal`, zero, explicit-size, disabled; paired smoke. |
| `UI_TXTINP` | `Text_Input` | Green | normal/empty/explicit/edit/overflowing-active/disabled fixtures; filters need rows below. |
| `UI_SELECT` | `Select` | Green | normal/explicit/pressed/open/choice/disabled fixtures. |
| `UI_OPTION` | `Option` | Green | normal/explicit/decrement/increment/disabled; wraparound is covered by focused tests only. |
| `UI_FLOAT` | `Float_Input` | Focused, Smoke | Numeric focused tests exercise commit/step; add deterministic C/Odin fixture. |
| `UI_INT8/16/32` | `Integer_8/16/32` | Smoke | Paired all-components smoke; add bounds, commit, and step fixtures for each width. |
| `UI_INT64` | `Integer_64` | Green, Smoke | normal/explicit/decrement/increment/disabled fixtures; paired smoke. |
| `UI_SLIDER` | `Slider` | Green | minimum/midpoint/maximum/interaction/disabled fixtures. |
| `UI_VSCRBAR` | `Vertical_Scrollbar` | Focused, Smoke | `vertical_and_horizontal_scrollbars_render_and_drag`. |
| `UI_HSCRBAR` | `Horizontal_Scrollbar` | Focused, Smoke | `vertical_and_horizontal_scrollbars_render_and_drag`. |
| `UI_COLOR` | `Color` | Focused, Smoke | `color_input_opens_picker_and_commits_selection`. |
| `UI_TOGGLE` | `Toggle` | Green, Focused | Menu-button fixtures plus toggle/container focused interactions. |
| `UI_CHECK` | `Checkbox` | Green | normal/checked/hover/pressed/disabled fixtures. |
| `UI_RADIO` | `Radio` | Green | normal/selected/hover/pressed/disabled and menu-choice fixtures. |
| `UI_BUTTON` | `Button` | Green | normal/explicit/hover/pressed/disabled fixtures. |
| `UI_BTNTGL` | `Toggle_Button` | Focused, Smoke | `toggle_and_icon_buttons_match_reference_interactions`. |
| `UI_BTNICN` | `Icon_Button` | Focused, Smoke | `toggle_and_icon_buttons_match_reference_interactions`. |
| `UI_LINES` | `Lines` | Focused, Smoke | `line_connector_and_curve_fields_render`. |
| `UI_VCONNECT` | `Vertical_Connector` | Focused, Smoke | `line_connector_and_curve_fields_render`. |
| `UI_HCONNECT` | `Horizontal_Connector` | Focused, Smoke | `line_connector_and_curve_fields_render`. |
| `UI_CURVE` | `Curve` | Focused, Smoke | `line_connector_and_curve_fields_render`. |
| `UI_CUSTOM` | `Custom` | Focused, Smoke | `custom_forms_measure_draw_control_popup_and_finalize`. |

## Form flags

C aliases context-dependent bits (`UI_NOBULLET`/`UI_NOHEADER` and
`UI_FORCEBR`/`UI_POINTER`). Odin exposes distinct semantic flags; this is an
intentional typed-API difference, and fixtures must compare behavior rather
than numeric values.

| Reference C | Odin `Form_Flag` | Status | Evidence / next fixture |
|---|---|---|---|
| `UI_HIDDEN` | `Hidden` | Green | `popup-hidden`, menu closed/open, and `layout-hidden-flow` fixtures. |
| `UI_NOBULLET` | `No_Bullet` | Focused, Smoke | Toggle focused test; add toggle parity fixture. |
| `UI_NOHEADER` | `No_Header` | Focused, Smoke | Popup/container focused coverage; add titled no-header fixture. |
| `UI_NOBR` | `No_Break` | Green, Focused | `layout-flow`, `layout-hidden-flow`; `flow_breaks_no_break_and_alignment_match_reference`. |
| `UI_FORCEBR` | `Force_Break` | Green, Focused | `layout-flow`, `layout-hidden-flow`; same focused flow test. |
| `UI_POINTER` | `Pointer` | Focused, Smoke | Image activation focused test; add pointer/selection fixture. |
| `UI_NOBORDER` | `No_Border` | Green | `popup-no-border`. |
| `UI_NOSHADOW` | `No_Shadow` | Green | `popup-no-shadow`. |
| `UI_ALTSKIN` | `Alternative_Skin` | Missing | Add populated-skin popup/menu fixture. |
| `UI_HSCROLL` | `Horizontal_Scroll` | Focused, Smoke | `popup_container_scrollbars_clip_and_move_content` covers child graphics and font clipping. |
| `UI_VSCROLL` | `Vertical_Scroll` | Focused, Smoke | Same focused clipping and movement test. |
| `UI_SCROLL` | both scroll flags | Focused, Smoke | Same focused test; add combined-scroll parity fixture. |
| `UI_DRAGGABLE` | `Draggable` | Green | `popup-draggable`, `popup-drag`, popup chrome/close fixtures. |
| `UI_RESIZABLE` | `Resizable` | Green | `popup-resizable`, `popup-resize`, `popup-chrome`. |
| `UI_SELECTED` | `Selected` | Focused, Smoke | Button/toggle focused coverage; add selected control fixtures. |
| `UI_DISABLED` | `Disabled` | Green | Button, checkbox, radio, slider, progress, values, inputs, select/option, and menu fixtures. |

### Context flags

| Reference C | Odin `Context_Flag` | Status | Evidence / next fixture |
|---|---|---|---|
| `UI_REFRESH` | `Refresh` | Focused | Rendering and state tests; add explicit lifecycle fixture. |
| `UI_RECALC` | `Recalculate` | Focused | Resize/layout tests; add explicit lifecycle fixture. |
| `UI_CLOSE` | `Close` | Focused | Custom popup close/finalize test. |
| `UI_DONE` | `Done` | Missing | Add close-state/backend termination fixture. |

## Events and buttons

| Reference C | Odin | Status | Evidence / next fixture |
|---|---|---|---|
| `UI_EVT_NONE` | `Event_Kind.None` | Green | Idle path in every framebuffer fixture. |
| `UI_EVT_MOUSE` | `Mouse` | Green | Hover, press, release, drag, resize, select/menu choice fixtures. |
| `UI_EVT_GAMEPAD` | `Gamepad` | Focused | Custom routing/passthrough test; add navigation/control parity fixtures. |
| `UI_EVT_KEY` | `Key` | Green | Text edit, select choice, menu escape fixtures. |
| `UI_EVT_DROP` | `Drop` | Focused | Event passthrough/custom-control tests; add payload parity fixture. |
| `UI_EVT_RESIZE` | `Resize` | Focused | Framebuffer resize and event passthrough tests; add C/Odin fixture. |
| `UI_BTN_L` | `Mouse_Left` | Green | Press, drag, resize, and choice fixtures. |
| `UI_BTN_M`, `UI_BTN_R` | `Mouse_Middle`, `Mouse_Right` | Focused | Passthrough routing only; add control-consumption fixtures. |
| `UI_BTN_U`, `UI_BTN_D` | `Direction_Up`, `Direction_Down` | Focused | `wheel_controls_consume_mouse_events_and_other_events_pass_through`. |
| gamepad face/system/trigger/stick buttons | matching `Gamepad_*` values | Focused | Custom control receives typed gamepad events; per-control behavior is missing. |
| `UI_BTN_RELEASE` | `Released` | Green | Pressed/interaction/drag/resize fixtures. |
| `UI_BTN_SHIFT`, `CONTROL`, `ALT`, `GUI` | `Shift`, `Control`, `Alt`, `Gui` | Focused | Text/event routing tests; add shortcut and modifier parity fixtures. |
| `x`, `y` | `Event.x`, `Event.y` | Green | Scripted mouse fixtures. |
| `rx`, `ry` | `right_x`, `right_y` | Focused | Gamepad passthrough test; add axis parity fixture. |
| `key[8]` | `Key_Input` | Green, Focused | Text editing and menu escape; add truncation/multibyte fixture. |
| `fn` | `file_name` | Focused | Drop passthrough test; add payload lifetime fixture. |

## Positioning, alignment, filters, and bindings

These are fields of the public form API and therefore remain part of parity
hardening even though they are not separate C operations.

| Surface | Status | Evidence / next fixture |
|---|---|---|
| Relative flow | Green | `layout-flow` and `layout-right-flow` cover nested origin, wrapping, and row continuation. |
| Absolute position | Green | Popup, division, and `layout-alignment` fixtures. |
| Percent / percent-plus | Green | `division-percentage` and `layout-percent`. Zero-percent packed edge behavior remains unrepresented. |
| Absolute from right/bottom | Green | `layout-from-end` and typed `absolute_from_end`; behavior follows Reference C's packed 127%-minus-inset result. |
| Left/top alignment | Green | Default element fixtures. |
| Right/center/bottom/middle alignment | Green, Focused | `layout-alignment`, `layout-right-flow`; `flow_breaks_no_break_and_alignment_match_reference`. |
| `UI_FILTER_NONE` | Green | Text-input edit fixture. |
| `UI_FILTER_ID/VAR/EXPR/HEX/PASS` | Focused | UTF-8/text and color/numeric focused tests; add one deterministic fixture per filter. |
| Odin `Integer` and `Decimal` filters | Focused | Odin-native explicit numeric filters; map to C input-kind behavior in numeric fixtures. |
| Boolean/integer/float/color/text/form/custom bindings | Green or Focused by owning form row | Add binding error/invalid-kind cases alongside each form fixture. |

## Next parity slices

Work top-down from the smallest unsupported surfaces:

1. Multiline explicit sizing/wrapping/alignment and status hover-description fixtures.
2. Image and icon intrinsic/scaled/grayscale/activation fixtures.
3. Color input closed/open/commit/cancel fixtures.
4. Toggle, toggle-button, and icon-button state fixtures.
5. Lines, connectors, and curve fixtures.
6. Standalone and popup scrollbar fixtures.
7. Absolute fill-width/fill-height and zero-percent packed layout edge fixtures.
8. Drop, resize, wheel, gamepad, and modifier event fixtures.
9. Custom callback/lifecycle fixtures.
10. Theme, skin, PNG skin, cursor, clipboard, window, and fullscreen operations.
11. Width-specific display and numeric-input variants.
12. Paired widget smoke convergence.
