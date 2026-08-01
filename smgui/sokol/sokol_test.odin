package smgui_sokol

import smgui ".."
import "base:runtime"
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

init_test_context_from_callback :: proc "c" (ctx: ^smgui.Context) -> bool {
	context = runtime.default_context()
	return init_test_context(ctx)
}

deinit_test_context_from_callback :: proc "c" (ctx: ^smgui.Context) {
	context = runtime.default_context()
	_ = smgui.deinit(ctx)
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
resize_preserves_framebuffer_mouse_coordinates :: proc(t: ^testing.T) {
	ctx: smgui.Context
	if !init_test_context_from_callback(&ctx) {testing.expect(t, false); return}
	defer deinit_test_context_from_callback(&ctx)
	state := State{ctx = &ctx}
	selected := 0
	forms := []smgui.Form {
		{
			kind = .Button,
			x = smgui.absolute(10),
			y = smgui.absolute(40),
			width = 20,
			height = 10,
			binding = smgui.bind(&selected),
			value = 1,
		},
	}
	resize_source := sapp.Event {
		type = .RESIZED,
		framebuffer_width = 64,
		framebuffer_height = 96,
	}
	app_event(&resize_source, &state)
	mouse_source := sapp.Event {
		type = .MOUSE_DOWN,
		mouse_button = .LEFT,
		mouse_x = 17,
		mouse_y = 46,
	}
	app_event(&mouse_source, &state)
	testing.expect_value(t, state.error, smgui.Error.None)
	testing.expect_value(t, ctx.screen.width, 64)
	testing.expect_value(t, ctx.screen.height, 96)
	resize_event, _, resize_error := smgui.poll_event(&ctx, forms)
	_, _, mouse_error := smgui.poll_event(&ctx, forms)
	testing.expect_value(t, resize_error, smgui.Error.None)
	testing.expect_value(t, mouse_error, smgui.Error.None)
	testing.expect_value(t, resize_event.kind, smgui.Event_Kind.Resize)
	// Sokol reports mouse positions in framebuffer pixels, including after resize.
	testing.expect_value(t, ctx.mouse_x, 17)
	testing.expect_value(t, ctx.mouse_y, 46)
	testing.expect_value(t, forms[0].computed_y, 40)
	testing.expect(t, ctx.hovered == &forms[0])
	testing.expect(t, ctx.pressed == &forms[0])
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
skin_cursor_hotspot_is_at_image_center :: proc(t: ^testing.T) {
	cursor := smgui.Image{width = 34, height = 34}
	x, y := cursor_hotspot(&cursor)
	testing.expect_value(t, x, 17)
	testing.expect_value(t, y, 17)
}

@(test)
special_keys_use_smgui_names :: proc(t: ^testing.T) {
	testing.expect_value(t, special_key_text(.ESCAPE), "Escape")
	testing.expect_value(t, special_key_text(.KP_ENTER), "Enter")
	testing.expect_value(t, special_key_text(.PAGE_DOWN), "PgDown")
	testing.expect_value(t, special_key_text(.A), "")
}
