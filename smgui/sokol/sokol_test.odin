package smgui_sokol

import smgui ".."
import "core:testing"
import sapp "../../vendor/sokol-odin/sokol/app"

test_backend_init :: proc(
	data: rawptr,
	ctx: ^smgui.Context,
	title: string,
	width, height: int,
	icon: ^smgui.Image,
) -> smgui.Error {
	_ = data
	_ = ctx
	_ = title
	_ = width
	_ = height
	_ = icon
	return .None
}

test_backend_poll :: proc(data: rawptr) -> (bool, smgui.Error) {
	_ = data
	return false, .None
}

test_backend_redraw :: proc(data: rawptr) -> smgui.Error {
	_ = data
	return .None
}

init_test_context :: proc(ctx: ^smgui.Context) -> bool {
	return smgui.init(ctx, {
		init = test_backend_init,
		poll = test_backend_poll,
		redraw = test_backend_redraw,
	}, []string{"test"}, 32, 32) == .None
}

@(test)
modifier_translation_preserves_mouse_and_keyboard_state :: proc(t: ^testing.T) {
	buttons := buttons_from_modifiers(
		sapp.MODIFIER_SHIFT | sapp.MODIFIER_CTRL | sapp.MODIFIER_LMB | sapp.MODIFIER_RMB,
	)
	testing.expect(t, .Shift in buttons)
	testing.expect(t, .Control in buttons)
	testing.expect(t, .Mouse_Left in buttons)
	testing.expect(t, .Mouse_Right in buttons)
	testing.expect(t, .Alt not_in buttons)
}

@(test)
mouse_event_is_queued_with_sokol_coordinates :: proc(t: ^testing.T) {
	ctx: smgui.Context
	if !init_test_context(&ctx) {testing.expect(t, false); return}
	defer { _ = smgui.deinit(&ctx) }
	state := State{ctx = &ctx}
	source := sapp.Event {
		type = .MOUSE_DOWN,
		mouse_button = .LEFT,
		mouse_x = 17,
		mouse_y = 23,
		modifiers = sapp.MODIFIER_SHIFT | sapp.MODIFIER_LMB,
	}
	app_event(&source, &state)
	testing.expect_value(t, state.error, smgui.Error.None)
	event, _, error := smgui.poll_event(&ctx, nil)
	testing.expect_value(t, error, smgui.Error.None)
	testing.expect_value(t, event.kind, smgui.Event_Kind.Mouse)
	testing.expect_value(t, event.x, 17)
	testing.expect_value(t, event.y, 23)
	testing.expect(t, .Mouse_Left in event.buttons)
	testing.expect(t, .Shift in event.buttons)
}

@(test)
character_event_is_queued_as_utf8 :: proc(t: ^testing.T) {
	ctx: smgui.Context
	if !init_test_context(&ctx) {testing.expect(t, false); return}
	defer { _ = smgui.deinit(&ctx) }
	state := State{ctx = &ctx}
	source := sapp.Event{type = .CHAR, char_code = 0x03bb}
	app_event(&source, &state)
	testing.expect_value(t, state.error, smgui.Error.None)
	event, _, error := smgui.poll_event(&ctx, nil)
	testing.expect_value(t, error, smgui.Error.None)
	testing.expect_value(t, smgui.key_text(&event.key), "λ")
}

@(test)
mouse_move_bursts_are_coalesced_per_frame :: proc(t: ^testing.T) {
	ctx: smgui.Context
	if !init_test_context(&ctx) {
		testing.expect(t, false)
		return
	}
	defer { _ = smgui.deinit(&ctx) }
	state := State{ctx = &ctx}
	for coordinate in 0 ..< 100 {
		source := sapp.Event {
			type = .MOUSE_MOVE,
			mouse_x = f32(coordinate),
			mouse_y = f32(coordinate + 1),
		}
		app_event(&source, &state)
	}
	testing.expect_value(t, state.error, smgui.Error.None)
	closed, error := create(&state).poll(&state)
	testing.expect(t, !closed)
	testing.expect_value(t, error, smgui.Error.None)
	event, _, poll_error := smgui.poll_event(&ctx, nil)
	testing.expect_value(t, poll_error, smgui.Error.None)
	testing.expect_value(t, event.kind, smgui.Event_Kind.Mouse)
	testing.expect_value(t, event.x, 99)
	testing.expect_value(t, event.y, 100)
}

@(test)
framebuffer_is_composited_over_presentation_clear_color :: proc(t: ^testing.T) {
	source := []u8 {
		0, 0, 0, 0,
		255, 128, 64, 255,
		255, 0, 0, 128,
	}
	destination := make([]u8, len(source))
	defer delete(destination)
	composite_over_clear(destination, source, {0, 0, 0.25, 1})
	expected := [?]u8 {
		0, 0, 64, 255,
		255, 128, 64, 255,
		128, 0, 32, 255,
	}
	for value, index in destination {
		testing.expect_value(t, value, expected[index])
	}
}

@(test)
special_keys_use_smgui_names :: proc(t: ^testing.T) {
	testing.expect_value(t, special_key_text(.ESCAPE), "Escape")
	testing.expect_value(t, special_key_text(.KP_ENTER), "Enter")
	testing.expect_value(t, special_key_text(.PAGE_DOWN), "PgDown")
	testing.expect_value(t, special_key_text(.A), "")
}
