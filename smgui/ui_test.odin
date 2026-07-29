package smgui

import "core:testing"

Test_Backend_State :: struct {
	ctx:       ^Context,
	pending:   Event,
	has_event: bool,
}

@(test)
interactive_controls_mutate_bound_state :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test", "Apply", "Enabled", "Easy", "Hard"}
	if error := init(&ctx, test_backend(&backend_state), texts, 100, 100); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	font := 1
	if error := set_font_hooks(&ctx, test_font_bounds, test_font_draw); error != .None {
		testing.expectf(t, false, "set_font_hooks failed: %v", error)
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
	}

	apply := false
	enabled := false
	choice := 0
	disabled_action := false
	forms := []Form {
		{kind = .Button, x = absolute(10), y = absolute(10), label = 1, binding = bind(&apply)},
		{
			kind = .Checkbox,
			x = absolute(10),
			y = absolute(40),
			label = 2,
			binding = bind(&enabled),
		},
		{
			kind = .Radio,
			x = absolute(50),
			y = absolute(40),
			label = 4,
			binding = bind(&choice),
			value = 1,
		},
		{
			kind = .Button,
			flags = {.Disabled},
			x = absolute(10),
			y = absolute(70),
			label = 1,
			binding = bind(&disabled_action),
		},
	}

	poll_for_test(t, &ctx, forms)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 15, {.Mouse_Left})
	testing.expect(t, !apply)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 15, {.Released})
	testing.expect(t, apply)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 45, {.Mouse_Left})
	testing.expect(t, enabled)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 55, 45, {.Mouse_Left})
	testing.expect_value(t, choice, 1)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 75, {.Mouse_Left})
	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 75, {.Released})
	testing.expect(t, !disabled_action)
}

@(test)
flow_layout_positions_children_inside_divisions :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test", "A", "Button", "B"}
	if error := init(&ctx, test_backend(&backend_state), texts, 200, 100); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	font := 1
	if error := set_font_hooks(&ctx, test_font_bounds, test_font_draw); error != .None {
		testing.expectf(t, false, "set_font_hooks failed: %v", error)
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
	}

	clicked := false
	children := []Form {
		{kind = .Label, flags = {.No_Break}, label = 1},
		{kind = .Button, label = 2, binding = bind(&clicked)},
		{kind = .Label, label = 3},
	}
	forms := []Form {
		{
			kind = .Division,
			x = absolute(10),
			y = absolute(10),
			width = 140,
			height = 80,
			margin = 5,
			children = children,
		},
	}
	if error := render(&ctx, forms); error != .None {
		testing.expectf(t, false, "render failed: %v", error)
	}

	testing.expect_value(t, children[0].computed_x, 15)
	testing.expect_value(t, children[0].computed_y, 15)
	testing.expect_value(t, children[1].computed_x, 32)
	testing.expect_value(t, children[1].computed_y, 15)
	testing.expect_value(t, children[2].computed_x, 15)
	testing.expect_value(t, children[2].computed_y, 49)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 35, 20, {.Mouse_Left})
	send_mouse_for_test(t, &ctx, &backend_state, forms, 35, 20, {.Released})
	testing.expect(t, clicked)
}

@(test)
slider_updates_bound_integer_and_renders_related_displays :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 200, 120); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	font := 1
	if error := set_font_hooks(&ctx, test_font_bounds, test_font_draw); error != .None {
		testing.expectf(t, false, "set_font_hooks failed: %v", error)
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
	}

	value := 0
	forms := []Form {
		{
			kind = .Slider,
			x = absolute(10),
			y = absolute(10),
			width = 110,
			binding = bind(&value),
			minimum = 0,
			maximum = 100,
		},
		{
			kind = .Progress_Bar,
			x = absolute(10),
			y = absolute(40),
			width = 110,
			binding = bind(&value),
			minimum = 0,
			maximum = 100,
		},
		{kind = .Decimal_64, x = absolute(10), y = absolute(70), binding = bind(&value)},
	}
	poll_for_test(t, &ctx, forms)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 65, 15, {.Mouse_Left})
	testing.expect_value(t, value, 50)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 200, 15, {.Mouse_Left})
	testing.expect_value(t, value, 100)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 200, 15, {.Released})
	testing.expect(t, ctx.horizontal_bar == nil)
}

@(private = "file")
poll_for_test :: proc(t: ^testing.T, ctx: ^Context, forms: []Form) {
	_, state, error := poll_event(ctx, forms)
	testing.expect_value(t, error, Error.None)
	testing.expect_value(t, state, Poll_State.Running)
}

@(private = "file")
send_mouse_for_test :: proc(
	t: ^testing.T,
	ctx: ^Context,
	backend: ^Test_Backend_State,
	forms: []Form,
	x, y: int,
	buttons: Input_Buttons,
) {
	backend.pending = {
		kind    = .Mouse,
		buttons = buttons,
		x       = x,
		y       = y,
	}
	backend.has_event = true
	poll_for_test(t, ctx, forms)
}

@(private = "file")
test_backend :: proc(state: ^Test_Backend_State) -> Backend {
	return {
		data = state,
		init = test_backend_init,
		deinit = test_backend_operation,
		poll = test_backend_poll,
		redraw = test_backend_operation,
	}
}

@(private = "file")
test_backend_init :: proc(
	data: rawptr,
	ctx: ^Context,
	title: string,
	width, height: int,
	icon: ^Image,
) -> Error {
	state := (^Test_Backend_State)(data)
	state.ctx = ctx
	_ = title
	_ = width
	_ = height
	_ = icon
	return .None
}

@(private = "file")
test_backend_operation :: proc(data: rawptr) -> Error {
	_ = data
	return .None
}

@(private = "file")
test_backend_poll :: proc(data: rawptr) -> (bool, Error) {
	state := (^Test_Backend_State)(data)
	if !state.has_event {
		return false, .None
	}
	state.ctx.mouse_x = state.pending.x
	state.ctx.mouse_y = state.pending.y
	error := push_event(state.ctx, state.pending)
	state.has_event = false
	return false, error
}

@(private = "file")
test_font_bounds :: proc(
	font: rawptr,
	text: string,
	width: ^int,
	height: ^int,
	left: ^int,
	top: ^int,
) -> Error {
	_ = font
	width^ = len(text) * 9
	height^ = 16
	left^ = 0
	top^ = 0
	return .None
}

@(private = "file")
test_font_draw :: proc(
	font: rawptr,
	text: string,
	destination: []u8,
	color: u32,
	x, y, left, top, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) -> Error {
	_ = font
	_ = text
	_ = destination
	_ = color
	_ = x
	_ = y
	_ = left
	_ = top
	_ = pitch
	_ = crop_x0
	_ = crop_y0
	_ = crop_x1
	_ = crop_y1
	return .None
}
