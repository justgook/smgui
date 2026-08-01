package smgui

import "core:testing"

Test_Backend_State :: struct {
	ctx:       ^Context,
	pending:   Event,
	has_event: bool,
}

Test_Font_State :: struct {
	last_text: string,
}

@(test)
render_clears_unpainted_pixels_to_transparent_black :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 4, 3); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	for &pixel in ctx.screen.pixels {
		pixel = 0xff
	}
	if error := render(&ctx, nil); error != .None {
		testing.expectf(t, false, "render failed: %v", error)
		return
	}
	for pixel in ctx.screen.pixels {
		testing.expect_value(t, pixel, u8(0))
	}
}

@(test)
resize_reallocates_framebuffer_and_requests_layout :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 4, 3); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	ctx.flags = {}
	if error := resize_framebuffer(&ctx, 7, 5); error != .None {
		testing.expectf(t, false, "resize failed: %v", error)
		return
	}
	testing.expect_value(t, ctx.screen.width, 7)
	testing.expect_value(t, ctx.screen.height, 5)
	testing.expect_value(t, ctx.screen.pitch, 28)
	testing.expect_value(t, len(ctx.screen.pixels), 140)
	testing.expect(t, .Refresh in ctx.flags)
	testing.expect(t, .Recalculate in ctx.flags)
}

@(test)
popup_wrap_uses_configured_vertical_pitch :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 64, 64); error != .None {
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
		return
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
		return
	}
	children := []Form {
		{kind = .Button, flags = {.No_Break}, width = 30, height = 8},
		{kind = .Button, width = 30, height = 8},
	}
	forms := []Form {
		{kind = .Popup, x = absolute(5), y = absolute(5), width = 50, height = 50, margin = 2, pitch = 6, children = children},
	}
	if error := render(&ctx, forms); error != .None {
		testing.expectf(t, false, "render failed: %v", error)
		return
	}
	testing.expect_value(
		t,
		children[1].computed_y - children[0].computed_y,
		children[0].computed_height + forms[0].pitch,
	)
}

@(test)
multiline_labels_and_status_fields_render :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test", "Hover description"}
	if error := init(&ctx, test_backend(&backend_state), texts, 160, 80); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	font: Test_Font_State
	if error := set_font_hooks(&ctx, test_font_bounds, recording_font_draw); error != .None {
		testing.expectf(t, false, "set_font_hooks failed: %v", error)
		return
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
		return
	}
	forms := []Form {
		{
			kind = .Multiline_Label,
			flags = {.No_Break},
			text = "one\nlonger",
			background = 0xff332211,
			description = 1,
		},
		{kind = .Status, width = 80, text = "Ready"},
	}
	ctx.hovered = &forms[0]
	if error := render(&ctx, forms); error != .None {
		testing.expectf(t, false, "render failed: %v", error)
		return
	}
	// Reference UI_MLINE uses the widest line and one default-font height per line.
	testing.expect_value(t, forms[0].computed_width, 54)
	testing.expect_value(t, forms[0].computed_height, 32)
	// Reference UI_STATUS has no intrinsic width and uses default font height plus four pixels.
	testing.expect_value(t, forms[1].computed_width, 80)
	testing.expect_value(t, forms[1].computed_height, 20)
	testing.expect_value(t, font.last_text, "Hover description")
	testing.expect(t, ctx.screen.pixels[0] != 0)
}

@(test)
image_and_icon_fields_render_and_activate :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 24, 16); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	pixels := []u8 {
		10, 20, 30, 255, 40, 50, 60, 255,
		70, 80, 90, 255, 100, 110, 120, 255,
	}
	image := Image{width = 2, height = 2, pitch = 8, pixels = pixels}
	selected := 0
	forms := []Form {
		{
			kind = .Image,
			flags = {.No_Break},
			width = 4,
			height = 2,
			icon = &image,
			binding = bind(&selected),
			value = 7,
		},
		{kind = .Icon, flags = {.Disabled}, width = 4, height = 4, icon = &image},
	}
	if error := render(&ctx, forms); error != .None {
		testing.expectf(t, false, "render failed: %v", error)
		return
	}
	// UI_IMAGE tiles its source when the form is larger than the source image.
	testing.expect_value(t, ctx.screen.pixels[0], ctx.screen.pixels[8])
	testing.expect_value(t, forms[0].computed_width, 4)
	testing.expect_value(t, forms[0].computed_height, 2)
	// UI_ICON preserves aspect ratio and bilinearly scales into its explicit box.
	icon_pixel := forms[1].computed_y * ctx.screen.pitch + forms[1].computed_x * 4
	testing.expect(t, ctx.screen.pixels[icon_pixel + 3] != 0)
	testing.expect_value(t, ctx.screen.pixels[icon_pixel], ctx.screen.pixels[icon_pixel + 1])
	testing.expect_value(t, ctx.screen.pixels[icon_pixel + 1], ctx.screen.pixels[icon_pixel + 2])

	poll_for_test(t, &ctx, forms)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 1, 1, {.Mouse_Left})
	testing.expect_value(t, selected, 7)
}

@(test)
color_input_opens_picker_and_commits_selection :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 400, 320); error != .None {
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
		return
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
		return
	}
	color: u32 = 0xffff0000
	forms := []Form{{kind = .Color, binding = bind(&color)}}
	poll_for_test(t, &ctx, forms)
	testing.expect_value(t, forms[0].computed_width, 92)
	testing.expect_value(t, forms[0].computed_height, 20)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 1, 1, {.Mouse_Left})
	testing.expect(t, ctx.popup == &forms[0])
	original := color
	// Select the center of the saturation/value square, then commit with Enter.
	send_mouse_for_test(t, &ctx, &backend_state, forms, 40 + 128, 20 + 8 + 128, {.Mouse_Left})
	testing.expect(t, ctx.color != original)
	testing.expect_value(t, color, original)
	send_key_for_test(t, &ctx, &backend_state, forms, "Enter")
	testing.expect(t, ctx.popup == nil)
	testing.expect(t, color != original)
	testing.expect_value(t, ctx.color_history[0], color)
}

@(test)
toggle_and_icon_buttons_match_reference_interactions :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test", "Toggle"}
	if error := init(&ctx, test_backend(&backend_state), texts, 120, 80); error != .None {
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
		return
	}
	if error := set_font(&ctx, &font); error != .None {
		testing.expectf(t, false, "set_font failed: %v", error)
		return
	}
	pixels := []u8 {
		10, 20, 30, 255, 40, 50, 60, 255,
		70, 80, 90, 255, 100, 110, 120, 255,
	}
	image := Image{width = 2, height = 2, pitch = 8, pixels = pixels}
	target := Form{kind = .Division, flags = {.Hidden}}
	mask := 2
	forms := []Form {
		{
			kind = .Toggle_Button,
			x = absolute(2),
			y = absolute(2),
			label = 1,
			icon = &image,
			binding = bind(&target),
		},
		{
			kind = .Icon_Button,
			x = absolute(2),
			y = absolute(32),
			icon = &image,
			binding = bind(&mask),
			value = 2,
		},
	}
	poll_for_test(t, &ctx, forms)
	testing.expect_value(t, forms[0].computed_width, 68)
	testing.expect_value(t, forms[0].computed_height, 20)
	testing.expect_value(t, forms[1].computed_width, 2)
	testing.expect_value(t, forms[1].computed_height, 2)
	icon_pixel := forms[1].computed_y * ctx.screen.pitch + forms[1].computed_x * 4
	testing.expect(t, ctx.screen.pixels[icon_pixel + 3] != 0)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 10, 10, {.Mouse_Left})
	testing.expect(t, .Hidden in target.flags)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 10, 10, {.Released})
	testing.expect(t, .Hidden not_in target.flags)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 2, 32, {.Mouse_Left})
	testing.expect_value(t, mask, 0)
}

@(test)
line_connector_and_curve_fields_render :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 64, 48); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	line_points := []i16{2, 2, 20, 2, 20, 12, 0, 0}
	vertical_points := []i16{24, 4, 40, 20}
	horizontal_points := []i16{4, 24, 24, 40}
	curve_points := []i16{30, 26, 58, 42, 34, 42, 54, 26}
	forms := []Form {
		{kind = .Lines, points = line_points, value = int(0xffffffff)},
		{kind = .Vertical_Connector, points = vertical_points, value = int(0xff40c080)},
		{kind = .Horizontal_Connector, points = horizontal_points, value = int(0xffc08040)},
		{kind = .Curve, points = curve_points, value = int(0xff8080ff)},
	}
	if error := render(&ctx, forms); error != .None {
		testing.expectf(t, false, "render failed: %v", error)
		return
	}
	pixel := 2 * ctx.screen.pitch + 2 * 4
	testing.expect(t, ctx.screen.pixels[pixel + 3] != 0)
	nontransparent := 0
	for index := 3; index < len(ctx.screen.pixels); index += 4 {
		if ctx.screen.pixels[index] != 0 {
			nontransparent += 1
		}
	}
	testing.expect(t, nontransparent > 40)
}

@(test)
vertical_and_horizontal_scrollbars_render_and_drag :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 140, 120); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	horizontal_value := 0
	vertical_value := 0
	forms := []Form {
		{
			kind = .Horizontal_Scrollbar,
			x = absolute(5),
			y = absolute(5),
			width = 100,
			maximum = 300,
			binding = bind(&horizontal_value),
		},
		{
			kind = .Vertical_Scrollbar,
			x = absolute(115),
			y = absolute(5),
			height = 100,
			maximum = 300,
			binding = bind(&vertical_value),
		},
	}
	poll_for_test(t, &ctx, forms)
	testing.expect_value(t, forms[0].computed_width, 100)
	testing.expect_value(t, forms[0].computed_height, 10)
	testing.expect_value(t, forms[1].computed_width, 10)
	testing.expect_value(t, forms[1].computed_height, 100)
	track_pixel := 5 * ctx.screen.pitch + 5 * 4
	testing.expect(t, ctx.screen.pixels[track_pixel + 3] != 0)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 6, 6, {.Mouse_Left})
	send_mouse_for_test(t, &ctx, &backend_state, forms, 70, 6, {.Mouse_Left})
	testing.expect(t, horizontal_value > 0 && horizontal_value <= 200)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 70, 6, {.Released})
	testing.expect(t, ctx.horizontal_bar == nil)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 116, 6, {.Mouse_Left})
	send_mouse_for_test(t, &ctx, &backend_state, forms, 116, 70, {.Mouse_Left})
	testing.expect(t, vertical_value > 0 && vertical_value <= 200)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 116, 70, {.Released})
	testing.expect(t, ctx.vertical_bar == nil)
}

@(test)
popup_container_scrollbars_clip_and_move_content :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 180, 140); error != .None {
		testing.expectf(t, false, "init failed: %v", error)
		return
	}
	defer {
		if error := deinit(&ctx); error != .None {
			testing.expectf(t, false, "deinit failed: %v", error)
		}
	}
	children := []Form {
		{kind = .Button, flags = {.No_Break}, width = 80, height = 24},
		{kind = .Button, width = 80, height = 24},
		{kind = .Button, flags = {.No_Break}, width = 80, height = 24},
		{kind = .Button, width = 80, height = 24},
		{kind = .Button, flags = {.No_Break}, width = 80, height = 24},
		{kind = .Button, width = 80, height = 24},
	}
	forms := []Form {
		{
			kind = .Popup,
			flags = {.Horizontal_Scroll, .Vertical_Scroll},
			x = absolute(10),
			y = absolute(10),
			width = 110,
			height = 70,
			margin = 2,
			pitch = 2,
			children = children,
		},
	}
	poll_for_test(t, &ctx, forms)
	popup := &forms[0]
	testing.expect(t, popup.source_width > 0)
	testing.expect(t, popup.source_height > 0)
	initial_child_x := children[0].computed_x
	initial_child_y := children[0].computed_y

	send_mouse_for_test(t, &ctx, &backend_state, forms, 20, 20, {.Direction_Down})
	testing.expect(t, popup.offset_y > 0)
	poll_for_test(t, &ctx, forms)
	testing.expect(t, children[0].computed_y < initial_child_y)

	horizontal_y := popup.content_y + popup.content_height
	send_mouse_for_test(t, &ctx, &backend_state, forms, popup.content_x + 1, horizontal_y + 1, {.Mouse_Left})
	send_mouse_for_test(t, &ctx, &backend_state, forms, popup.content_x + popup.source_width - 2, horizontal_y + 1, {.Mouse_Left})
	testing.expect(t, popup.offset_x > 0)
	poll_for_test(t, &ctx, forms)
	testing.expect(t, children[0].computed_x < initial_child_x)
	send_mouse_for_test(t, &ctx, &backend_state, forms, popup.content_x, horizontal_y, {.Released})
	testing.expect(t, ctx.horizontal_bar == nil)
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
	testing.expect_value(t, children[1].computed_x, 24)
	testing.expect_value(t, children[1].computed_y, 15)
	testing.expect_value(t, children[2].computed_x, 15)
	testing.expect_value(t, children[2].computed_y, 35)

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
	testing.expect_value(t, value, 51)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 200, 15, {.Mouse_Left})
	testing.expect_value(t, value, 100)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 200, 15, {.Released})
	testing.expect(t, ctx.horizontal_bar == nil)
}

@(test)
text_input_edits_utf8_at_the_cursor :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
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
	buffer: Text_Buffer
	if error := text_buffer_init(&buffer, "ab", 8); error != .None {
		testing.expectf(t, false, "text_buffer_init failed: %v", error)
		return
	}
	defer text_buffer_deinit(&buffer)

	forms := []Form {
		{
			kind = .Text_Input,
			x = absolute(10),
			y = absolute(10),
			width = 120,
			binding = bind(&buffer),
			max_length = 8,
		},
	}
	poll_for_test(t, &ctx, forms)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 15, {.Mouse_Left})
	testing.expect(t, ctx.text_field != nil)

	send_key_for_test(t, &ctx, &backend_state, forms, "c")
	send_key_for_test(t, &ctx, &backend_state, forms, "Left")
	send_key_for_test(t, &ctx, &backend_state, forms, "X")
	testing.expect_value(t, text_buffer_string(&buffer), "abXc")
	send_key_for_test(t, &ctx, &backend_state, forms, "Backspace")
	send_key_for_test(t, &ctx, &backend_state, forms, "End")
	send_key_for_test(t, &ctx, &backend_state, forms, "é")
	testing.expect_value(t, text_buffer_string(&buffer), "abcé")
	send_key_for_test(t, &ctx, &backend_state, forms, "Enter")
	testing.expect(t, ctx.text_field == nil)
}

@(test)
numeric_inputs_commit_text_and_step_with_buttons :: proc(t: ^testing.T) {
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

	integer_value := 10
	float_value: f32 = 1.5
	forms := []Form {
		{
			kind = .Integer_64,
			x = absolute(10),
			y = absolute(10),
			width = 120,
			binding = bind(&integer_value),
			minimum = 0,
			maximum = 100,
			increment = 1,
		},
		{
			kind = .Float_Input,
			x = absolute(10),
			y = absolute(45),
			width = 120,
			binding = bind(&float_value),
			float_minimum = 0,
			float_maximum = 10,
			float_increment = 0.25,
		},
	}
	poll_for_test(t, &ctx, forms)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 70, 15, {.Mouse_Left})
	send_key_for_test(t, &ctx, &backend_state, forms, "Home")
	send_key_for_test(t, &ctx, &backend_state, forms, "Delete")
	send_key_for_test(t, &ctx, &backend_state, forms, "5")
	send_key_for_test(t, &ctx, &backend_state, forms, "Enter")
	testing.expect_value(t, integer_value, 50)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 120, 15, {.Mouse_Left})
	testing.expect_value(t, integer_value, 51)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 15, {.Mouse_Left})
	testing.expect_value(t, integer_value, 50)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 70, 50, {.Mouse_Left})
	send_key_for_test(t, &ctx, &backend_state, forms, "End")
	send_key_for_test(t, &ctx, &backend_state, forms, "Backspace")
	send_key_for_test(t, &ctx, &backend_state, forms, "75")
	send_key_for_test(t, &ctx, &backend_state, forms, "Enter")
	testing.expect_value(t, float_value, f32(1.75))
}

@(test)
select_and_option_controls_choose_bound_values :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test"}
	if error := init(&ctx, test_backend(&backend_state), texts, 200, 140); error != .None {
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

	selected := 0
	options := []string{"one", "two", "three"}
	forms := []Form {
		{
			kind = .Select,
			x = absolute(10),
			y = absolute(10),
			width = 120,
			binding = bind(&selected),
			options = options,
		},
		{
			kind = .Option,
			x = absolute(10),
			y = absolute(90),
			width = 120,
			binding = bind(&selected),
			options = options,
		},
	}
	poll_for_test(t, &ctx, forms)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 30, 15, {.Mouse_Left})
	testing.expect(t, ctx.popup == nil)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 30, 15, {.Released})
	testing.expect(t, ctx.popup == &forms[0])
	popup_x := ctx.popup_x
	popup_y := ctx.popup_y + 2
	row_height := forms[0].computed_height - 4
	send_mouse_for_test(
		t,
		&ctx,
		&backend_state,
		forms,
		popup_x + 5,
		popup_y + row_height * 2 + 5,
		{.Mouse_Left},
	)
	testing.expect_value(t, selected, 2)
	testing.expect(t, ctx.popup == nil)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 30, 15, {.Mouse_Left})
	send_mouse_for_test(t, &ctx, &backend_state, forms, 30, 15, {.Released})
	send_key_for_test(t, &ctx, &backend_state, forms, "Up")
	send_key_for_test(t, &ctx, &backend_state, forms, "Enter")
	testing.expect_value(t, selected, 1)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 120, 95, {.Mouse_Left})
	testing.expect_value(t, selected, 2)
	send_mouse_for_test(t, &ctx, &backend_state, forms, 15, 95, {.Mouse_Left})
	testing.expect_value(t, selected, 1)
}

@(test)
menu_toggle_opens_and_popup_closes_from_title :: proc(t: ^testing.T) {
	backend_state: Test_Backend_State
	ctx: Context
	texts := []string{"test", "Menu", "Show popup", "Popup", "First", "Second"}
	if error := init(&ctx, test_backend(&backend_state), texts, 240, 180); error != .None {
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

	choice := 0
	popup_children := []Form{{kind = .Label, label = 2}}
	menu_children := []Form {
		{kind = .Toggle, flags = {.No_Bullet}, label = 2},
		{kind = .Radio, flags = {.No_Bullet}, label = 4, binding = bind(&choice), value = 1},
		{kind = .Radio, flags = {.No_Bullet}, label = 5, binding = bind(&choice), value = 2},
	}
	forms := []Form {
		{kind = .Toggle, flags = {.No_Bullet}, x = absolute(10), y = absolute(10), label = 1},
		{kind = .Menu, flags = {.Hidden}, width = 120, margin = 4, children = menu_children},
		{
			kind = .Popup,
			flags = {.Hidden, .Draggable},
			x = absolute(50),
			y = absolute(40),
			width = 140,
			height = 90,
			margin = 8,
			label = 3,
			children = popup_children,
		},
	}
	forms[0].binding = bind(&forms[1])
	menu_children[0].binding = bind(&forms[2])
	poll_for_test(t, &ctx, forms)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 20, 15, {.Mouse_Left})
	testing.expect(t, .Hidden not_in forms[1].flags)
	testing.expect(t, ctx.menu == &forms[1])
	poll_for_test(t, &ctx, forms)
	send_mouse_for_test(
		t,
		&ctx,
		&backend_state,
		forms,
		menu_children[0].computed_x + 5,
		menu_children[0].computed_y + 5,
		{.Mouse_Left},
	)
	testing.expect(t, .Hidden not_in forms[2].flags)
	testing.expect(t, .Hidden in forms[1].flags)

	poll_for_test(t, &ctx, forms)
	send_mouse_for_test(
		t,
		&ctx,
		&backend_state,
		forms,
		forms[2].computed_x + forms[2].computed_width - 8,
		forms[2].computed_y + 8,
		{.Mouse_Left},
	)
	testing.expect(t, .Hidden in forms[2].flags)

	send_mouse_for_test(t, &ctx, &backend_state, forms, 20, 15, {.Mouse_Left})
	poll_for_test(t, &ctx, forms)
	send_mouse_for_test(
		t,
		&ctx,
		&backend_state,
		forms,
		menu_children[1].computed_x + 5,
		menu_children[1].computed_y + 5,
		{.Mouse_Left},
	)
	testing.expect_value(t, choice, 1)
	testing.expect(t, ctx.menu == nil)
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
send_key_for_test :: proc(
	t: ^testing.T,
	ctx: ^Context,
	backend: ^Test_Backend_State,
	forms: []Form,
	key: string,
) {
	backend.pending = {
		kind = .Key,
		key  = key_input(key),
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
recording_font_draw :: proc(
	font: rawptr,
	text: string,
	destination: []u8,
	color: u32,
	x, y, left, top, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) -> Error {
	state := (^Test_Font_State)(font)
	state.last_text = text
	return test_font_draw(
		font,
		text,
		destination,
		color,
		x,
		y,
		left,
		top,
		pitch,
		crop_x0,
		crop_y0,
		crop_x1,
		crop_y1,
	)
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
