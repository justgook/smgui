package main

/*
Default screen1 migration target, paired with tests/manual/smoke.c.

This form tree is derived from reference-c/docs/screen1.png. Keep its strings,
initial state, dimensions, and forms aligned with the C counterpart. Add missing
screen1 controls to both versions as their parity slices land.
*/

import psf2 "../../psf2"
import smgui "../../smgui"
import image_backend "../../smgui/image"
import raylib_backend "../../smgui/raylib"
import "core:fmt"
import "core:os"

main :: proc() {
	texts := []string {
		"Widget parity smoke",
		"File",
		"Language",
		"Popups",
		"Item1",
		"Item2",
		"Labels",
		"Inputs",
		"Active",
		"Inactive",
		"Buttons",
		"Press Me",
		"one",
		"two",
		"three",
		"First line\nSecond line",
	}
	options := texts[12:15]

	menu_option := 0
	button_option := 0
	checkbox_option := false
	radio_option := 0
	integer_value := 26
	option_value := 0
	progress_value := 42
	color_value: u32 = 0xffd06020
	float_value: f32 = 3.141
	text_value: smgui.Text_Buffer
	if error := smgui.text_buffer_init(&text_value, "", 64); error != .None {
		fail("initializing text input", error)
	}
	defer smgui.text_buffer_deinit(&text_value)

	image_pixels := []u8 {
		0x20, 0x60, 0xd0, 0xff, 0xd0, 0x80, 0x20, 0xff,
		0x40, 0xc0, 0x60, 0xff, 0xd0, 0x30, 0x80, 0xff,
	}
	sample_image := smgui.Image{width = 2, height = 2, pitch = 8, pixels = image_pixels}

	popup_children := []smgui.Form {
		{
			kind = .Button,
			flags = {.No_Break},
			label = 11,
			binding = smgui.bind(&button_option),
			value = 1,
		},
		{
			kind = .Button,
			flags = {.Disabled},
			label = 11,
			binding = smgui.bind(&button_option),
			value = 2,
		},
	}
	file_menu := []smgui.Form {
		{kind = .Radio, flags = {.No_Bullet}, label = 4, binding = smgui.bind(&menu_option), value = 1},
		{kind = .Radio, flags = {.No_Bullet}, label = 5, binding = smgui.bind(&menu_option), value = 2},
	}
	language_menu := []smgui.Form {
		{kind = .Radio, flags = {.No_Bullet}, label = 12, binding = smgui.bind(&menu_option), value = 3},
		{kind = .Radio, flags = {.No_Bullet}, label = 13, binding = smgui.bind(&menu_option), value = 4},
	}
	popup_menu := []smgui.Form {
		{kind = .Toggle, flags = {.No_Bullet}, label = 4},
	}
	label_fields := []smgui.Form {
		{kind = .Label, flags = {.No_Break}, label = 4},
		{kind = .Decimal_32, flags = {.No_Break}, width = 28, binding = smgui.bind(&integer_value)},
		{kind = .Hexadecimal_32, flags = {.No_Break}, width = 36, binding = smgui.bind(&integer_value)},
		{
			kind = .Progress_Bar,
			flags = {.No_Break},
			x = smgui.relative(10),
			width = 100,
			binding = smgui.bind(&progress_value),
			maximum = 100,
		},
		{kind = .Decimal_Float, width = 80, binding = smgui.bind(&float_value)},
		{kind = .Multiline_Label, label = 15},
		{kind = .Status, width = 160, text = "Ready"},
		{kind = .Image, flags = {.No_Break}, width = 32, height = 16, icon = &sample_image},
		{kind = .Icon, width = 32, height = 24, icon = &sample_image},
		{kind = .Color, width = 100, binding = smgui.bind(&color_value)},
	}
	active_inputs := []smgui.Form {
		{
			kind = .Text_Input,
			flags = {.No_Break},
			width = 130,
			binding = smgui.bind(&text_value),
			max_length = 64,
		},
		{
			kind = .Select,
			flags = {.No_Break},
			x = smgui.relative(10),
			margin = 17,
			width = 80,
			binding = smgui.bind(&option_value),
			options = options,
		},
		{
			kind = .Option,
			flags = {.No_Break},
			x = smgui.relative(10),
			margin = 17,
			width = 90,
			binding = smgui.bind(&option_value),
			options = options,
		},
		{
			kind = .Integer_32,
			flags = {.No_Break},
			x = smgui.relative(10),
			margin = 17,
			width = 72,
			binding = smgui.bind(&integer_value),
			minimum = 1,
			maximum = 32,
		},
		{
			kind = .Float_Input,
			flags = {.No_Break},
			x = smgui.relative(10),
			margin = 17,
			width = 100,
			binding = smgui.bind(&float_value),
			float_minimum = 1,
			float_maximum = 32,
			float_increment = 0.25,
		},
		{
			kind = .Slider,
			x = smgui.relative(10),
			width = 60,
			binding = smgui.bind(&integer_value),
			minimum = 1,
			maximum = 32,
		},
	}
	inactive_inputs := clone_disabled_inputs(active_inputs)
	defer delete(inactive_inputs)
	input_fields := []smgui.Form {
		{kind = .Toggle, flags = {.Force_Break}, label = 8},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = active_inputs},
		{kind = .Toggle, flags = {.Force_Break}, label = 9},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = inactive_inputs},
	}
	active_buttons := []smgui.Form {
		{
			kind = .Checkbox,
			flags = {.No_Break},
			label = 4,
			binding = smgui.bind(&checkbox_option),
		},
		{
			kind = .Radio,
			flags = {.No_Break},
			x = smgui.relative(10),
			label = 4,
			binding = smgui.bind(&radio_option),
			value = 0,
		},
		{
			kind = .Radio,
			flags = {.No_Break},
			label = 5,
			binding = smgui.bind(&radio_option),
			value = 1,
		},
		{kind = .Button, x = smgui.relative(10), margin = -1, label = 4, binding = smgui.bind(&button_option), value = 1},
	}
	inactive_buttons := clone_disabled_buttons(active_buttons)
	defer delete(inactive_buttons)
	button_fields := []smgui.Form {
		{kind = .Toggle, flags = {.Force_Break}, label = 8},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = active_buttons},
		{kind = .Toggle, flags = {.Force_Break}, label = 9},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = inactive_buttons},
	}
	forms := []smgui.Form {
		{
			kind = .Popup,
			flags = {.Horizontal_Scroll, .Vertical_Scroll, .Draggable, .Resizable},
			x = smgui.absolute(455),
			y = smgui.absolute(315),
			width = 110,
			height = 90,
			margin = 10,
			pitch = 10,
			children = popup_children,
		},
		{kind = .Toggle, flags = {.No_Bullet, .No_Break}, x = smgui.relative(10), margin = 8, label = 1},
		{kind = .Menu, flags = {.Hidden}, width = 100, margin = 4, children = file_menu},
		{kind = .Toggle, flags = {.No_Bullet, .No_Break}, x = smgui.relative(10), margin = 8, label = 2},
		{kind = .Menu, flags = {.Hidden}, width = 100, margin = 4, children = language_menu},
		{kind = .Toggle, flags = {.No_Bullet, .Force_Break}, x = smgui.relative(10), margin = 8, label = 3},
		{kind = .Menu, flags = {.Hidden}, width = 100, margin = 4, children = popup_menu},
		{kind = .Toggle, flags = {.Force_Break}, label = 6},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = label_fields},
		{kind = .Toggle, flags = {.Force_Break}, label = 7},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = input_fields},
		{kind = .Toggle, flags = {.Force_Break}, label = 10},
		{kind = .Division, flags = {.Force_Break}, width_percentage = 100, margin = 4, children = button_fields},
	}
	forms[1].binding = smgui.bind(&forms[2])
	forms[3].binding = smgui.bind(&forms[4])
	forms[5].binding = smgui.bind(&forms[6])
	popup_menu[0].binding = smgui.bind(&forms[0])
	forms[7].binding = smgui.bind(&forms[8])
	forms[9].binding = smgui.bind(&forms[10])
	forms[11].binding = smgui.bind(&forms[12])
	input_fields[0].binding = smgui.bind(&input_fields[1])
	input_fields[2].binding = smgui.bind(&input_fields[3])
	button_fields[0].binding = smgui.bind(&button_fields[1])
	button_fields[2].binding = smgui.bind(&button_fields[3])

	backend: smgui.Backend
	raylib_state: raylib_backend.State
	image_state: image_backend.State
	writing_image := false
	if len(os.args) == 1 {
		// Matches glClearColor(0.0, 0.0, 0.25, 1.0) in reference-c/examples/widgets.c.
		if error := raylib_backend.set_background(&raylib_state, 0, 0, 64, 255);
		   error != .None {
			fail("configuring presentation background", error)
		}
		backend = raylib_backend.create(&raylib_state)
	} else if len(os.args) == 3 && os.args[1] == "--output" {
		writing_image = true
		backend = image_backend.create(&image_state, os.args[2])
	} else {
		fmt.eprintf("usage: %s [--output OUTPUT.png]\n", os.args[0])
		os.exit(2)
	}

	ctx: smgui.Context
	if error := smgui.init(&ctx, backend, texts, 640, 480); error != .None {
		fail("initializing smoke test", error)
	}
	defer {
		if error := smgui.deinit(&ctx); error != .None {
			fmt.eprintln("SMGUI shutdown failed:", error)
		}
	}

	font, error := psf2.default_font()
	if error != .None {
		fail("loading the built-in PSF2 font", error)
	}
	if error = psf2.configure(&ctx, &font); error != .None {
		fail("configuring the PSF2 font", error)
	}

	for {
		_, state, poll_error := smgui.poll_event(&ctx, forms)
		if poll_error != .None {
			fail("polling smoke test", poll_error)
		}
		if state == .Closed {
			break
		}
	}
	if writing_image && !image_state.succeeded {
		fmt.eprintln("Failed to write smoke-test image:", os.args[2])
		os.exit(1)
	}
}

clone_disabled_inputs :: proc(source: []smgui.Form) -> []smgui.Form {
	result := make([]smgui.Form, len(source))
	copy(result, source)
	for &field in result {
		field.flags += {.Disabled}
	}
	return result
}

clone_disabled_buttons :: proc(source: []smgui.Form) -> []smgui.Form {
	result := make([]smgui.Form, len(source))
	copy(result, source)
	for &field in result {
		field.flags += {.Disabled}
	}
	return result
}

@(private = "file")
fail :: proc(operation: string, error: smgui.Error) -> ! {
	fmt.eprintf("Error %s: %v\n", operation, error)
	os.exit(1)
}
