package main

/* Small deterministic Odin framebuffer parity fixtures. */

import psf2 "../../../psf2"
import smgui "../../../smgui"
import image_backend "../../../smgui/image"
import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) != 5 {
		fmt.eprintf("usage: %s CASE OUTPUT.png WIDTH HEIGHT\n", os.args[0])
		os.exit(2)
	}
	width, width_ok := strconv.parse_int(os.args[3], 10)
	height, height_ok := strconv.parse_int(os.args[4], 10)
	if !width_ok || !height_ok || width < 1 || width > 4096 || height < 1 || height > 4096 {
		fmt.eprintf("invalid framebuffer dimensions: %sx%s\n", os.args[3], os.args[4])
		os.exit(2)
	}

	label_normal := []smgui.Form{{kind = .Label, label = 1}}
	button_normal := []smgui.Form{{kind = .Button, label = 2}}
	button_explicit_size := []smgui.Form{{kind = .Button, label = 3, width = 58, height = 28}}
	button_hover := []smgui.Form{{kind = .Button, label = 2}}
	button_pressed := []smgui.Form{{kind = .Button, label = 2}}
	button_disabled := []smgui.Form{{kind = .Button, flags = {.Disabled}, label = 2}}
	checked := false
	checkbox_normal := []smgui.Form{{kind = .Checkbox, label = 4, binding = smgui.bind(&checked)}}
	checked_value := true
	checkbox_checked := []smgui.Form {
		{kind = .Checkbox, label = 4, binding = smgui.bind(&checked_value)},
	}
	checkbox_hover := []smgui.Form{{kind = .Checkbox, label = 4, binding = smgui.bind(&checked)}}
	pressed_value := false
	checkbox_pressed := []smgui.Form {
		{kind = .Checkbox, label = 4, binding = smgui.bind(&pressed_value)},
	}
	checkbox_disabled := []smgui.Form {
		{kind = .Checkbox, flags = {.Disabled}, label = 4, binding = smgui.bind(&checked)},
	}
	radio_value := 0
	radio_normal := []smgui.Form {
		{kind = .Radio, label = 5, binding = smgui.bind(&radio_value), value = 1},
	}
	selected_radio_value := 1
	radio_selected := []smgui.Form {
		{kind = .Radio, label = 5, binding = smgui.bind(&selected_radio_value), value = 1},
	}
	radio_hover := []smgui.Form {
		{kind = .Radio, label = 5, binding = smgui.bind(&radio_value), value = 1},
	}
	pressed_radio_value := 0
	radio_pressed := []smgui.Form {
		{kind = .Radio, label = 5, binding = smgui.bind(&pressed_radio_value), value = 1},
	}
	radio_disabled := []smgui.Form {
		{
			kind = .Radio,
			flags = {.Disabled},
			label = 5,
			binding = smgui.bind(&radio_value),
			value = 1,
		},
	}
	slider_value := 0
	slider_minimum := []smgui.Form {
		{
			kind = .Slider,
			width = 58,
			height = 20,
			binding = smgui.bind(&slider_value),
			minimum = 0,
			maximum = 100,
		},
	}
	slider_midpoint_value := 50
	slider_midpoint := []smgui.Form {
		{
			kind = .Slider,
			width = 58,
			height = 20,
			binding = smgui.bind(&slider_midpoint_value),
			minimum = 0,
			maximum = 100,
		},
	}
	slider_maximum_value := 100
	slider_maximum := []smgui.Form {
		{
			kind = .Slider,
			width = 58,
			height = 20,
			binding = smgui.bind(&slider_maximum_value),
			minimum = 0,
			maximum = 100,
		},
	}
	slider_interaction_value := 0
	slider_interaction := []smgui.Form {
		{
			kind = .Slider,
			width = 58,
			height = 20,
			binding = smgui.bind(&slider_interaction_value),
			minimum = 0,
			maximum = 100,
		},
	}
	slider_disabled := []smgui.Form {
		{
			kind = .Slider,
			flags = {.Disabled},
			width = 58,
			height = 20,
			binding = smgui.bind(&slider_midpoint_value),
			minimum = 0,
			maximum = 100,
		},
	}
	progress_value := 0
	progress_minimum := []smgui.Form {
		{
			kind = .Progress_Bar,
			width = 58,
			height = 20,
			binding = smgui.bind(&progress_value),
			minimum = 0,
			maximum = 100,
		},
	}
	progress_midpoint_value := 50
	progress_midpoint := []smgui.Form {
		{
			kind = .Progress_Bar,
			width = 58,
			height = 20,
			binding = smgui.bind(&progress_midpoint_value),
			minimum = 0,
			maximum = 100,
		},
	}
	progress_maximum_value := 100
	progress_maximum := []smgui.Form {
		{
			kind = .Progress_Bar,
			width = 58,
			height = 20,
			binding = smgui.bind(&progress_maximum_value),
			minimum = 0,
			maximum = 100,
		},
	}
	progress_disabled := []smgui.Form {
		{
			kind = .Progress_Bar,
			flags = {.Disabled},
			width = 58,
			height = 20,
			binding = smgui.bind(&progress_midpoint_value),
			minimum = 0,
			maximum = 100,
		},
	}
	decimal_value := 42
	decimal_normal := []smgui.Form{{kind = .Decimal_64, binding = smgui.bind(&decimal_value)}}
	decimal_negative_value := -42
	decimal_negative := []smgui.Form {
		{kind = .Decimal_64, binding = smgui.bind(&decimal_negative_value)},
	}
	decimal_explicit_size := []smgui.Form {
		{kind = .Decimal_64, width = 58, height = 28, binding = smgui.bind(&decimal_value)},
	}
	decimal_disabled := []smgui.Form {
		{kind = .Decimal_64, flags = {.Disabled}, binding = smgui.bind(&decimal_value)},
	}
	hexadecimal_value := 0x2a
	hex_normal := []smgui.Form{{kind = .Hexadecimal_64, binding = smgui.bind(&hexadecimal_value)}}
	hexadecimal_zero_value := 0
	hex_zero := []smgui.Form {
		{kind = .Hexadecimal_64, binding = smgui.bind(&hexadecimal_zero_value)},
	}
	hex_explicit_size := []smgui.Form {
		{
			kind = .Hexadecimal_64,
			width = 58,
			height = 28,
			binding = smgui.bind(&hexadecimal_value),
		},
	}
	hex_disabled := []smgui.Form {
		{kind = .Hexadecimal_64, flags = {.Disabled}, binding = smgui.bind(&hexadecimal_value)},
	}
	float_value: f32 = 12.345
	float_normal := []smgui.Form{{kind = .Decimal_Float, binding = smgui.bind(&float_value)}}
	float_magnitude_value: f32 = 123456.0
	float_magnitude := []smgui.Form {
		{kind = .Decimal_Float, binding = smgui.bind(&float_magnitude_value)},
	}
	float_explicit_size := []smgui.Form {
		{
			kind = .Decimal_Float,
			width = 76,
			height = 28,
			binding = smgui.bind(&float_magnitude_value),
		},
	}
	float_disabled := []smgui.Form {
		{kind = .Decimal_Float, flags = {.Disabled}, binding = smgui.bind(&float_value)},
	}
	text_input_value: smgui.Text_Buffer
	if error := smgui.text_buffer_init(&text_input_value, "Hello", 15); error != .None {
		fmt.eprintln("failed to initialize text input buffer")
		os.exit(1)
	}
	defer smgui.text_buffer_deinit(&text_input_value)
	text_input_normal := []smgui.Form {
		{kind = .Text_Input, binding = smgui.bind_text(&text_input_value)},
	}
	forms: []smgui.Form
	switch os.args[1] {
	case "empty":
		forms = nil
	case "label-normal":
		forms = label_normal
	case "button-normal":
		forms = button_normal
	case "button-explicit-size":
		forms = button_explicit_size
	case "button-hover":
		forms = button_hover
	case "button-pressed":
		forms = button_pressed
	case "button-disabled":
		forms = button_disabled
	case "checkbox-normal":
		forms = checkbox_normal
	case "checkbox-checked":
		forms = checkbox_checked
	case "checkbox-hover":
		forms = checkbox_hover
	case "checkbox-pressed":
		forms = checkbox_pressed
	case "checkbox-disabled":
		forms = checkbox_disabled
	case "radio-normal":
		forms = radio_normal
	case "radio-selected":
		forms = radio_selected
	case "radio-hover":
		forms = radio_hover
	case "radio-pressed":
		forms = radio_pressed
	case "radio-disabled":
		forms = radio_disabled
	case "slider-minimum":
		forms = slider_minimum
	case "slider-midpoint":
		forms = slider_midpoint
	case "slider-maximum":
		forms = slider_maximum
	case "slider-interaction":
		forms = slider_interaction
	case "slider-disabled":
		forms = slider_disabled
	case "progress-minimum":
		forms = progress_minimum
	case "progress-midpoint":
		forms = progress_midpoint
	case "progress-maximum":
		forms = progress_maximum
	case "progress-disabled":
		forms = progress_disabled
	case "decimal-normal":
		forms = decimal_normal
	case "decimal-negative":
		forms = decimal_negative
	case "decimal-explicit-size":
		forms = decimal_explicit_size
	case "decimal-disabled":
		forms = decimal_disabled
	case "hex-normal":
		forms = hex_normal
	case "hex-zero":
		forms = hex_zero
	case "hex-explicit-size":
		forms = hex_explicit_size
	case "hex-disabled":
		forms = hex_disabled
	case "float-normal":
		forms = float_normal
	case "float-magnitude":
		forms = float_magnitude
	case "float-explicit-size":
		forms = float_explicit_size
	case "float-disabled":
		forms = float_disabled
	case "text-input-normal":
		forms = text_input_normal
	case:
		fmt.eprintf("unknown parity case: %s\n", os.args[1])
		os.exit(2)
	}

	texts := []string{"Parity fixture", "Label", "Button", "Btn", "Check", "Radio"}
	interaction_case :=
		os.args[1] == "button-hover" ||
		os.args[1] == "button-pressed" ||
		os.args[1] == "checkbox-hover" ||
		os.args[1] == "checkbox-pressed" ||
		os.args[1] == "radio-hover" ||
		os.args[1] == "radio-pressed" ||
		os.args[1] == "slider-interaction"
	capture_delay := 0
	if interaction_case {
		capture_delay = 1
	}
	image_state: image_backend.State
	ctx: smgui.Context
	if error := smgui.init(
		&ctx,
		image_backend.create(&image_state, os.args[2], capture_delay),
		texts,
		width,
		height,
	); error != .None {
		fmt.eprintf("init failed: %v\n", error)
		os.exit(1)
	}
	defer {
		if error := smgui.deinit(&ctx); error != .None {
			fmt.eprintf("deinit failed: %v\n", error)
		}
	}
	font, font_error := psf2.default_font()
	if font_error != .None {
		fmt.eprintf("font load failed: %v\n", font_error)
		os.exit(1)
	}
	if error := psf2.configure(&ctx, &font); error != .None {
		fmt.eprintf("font configuration failed: %v\n", error)
		os.exit(1)
	}

	if os.args[1] == "button-normal" ||
	   os.args[1] == "button-explicit-size" ||
	   os.args[1] == "checkbox-normal" ||
	   os.args[1] == "checkbox-checked" ||
	   os.args[1] == "radio-normal" ||
	   os.args[1] == "radio-selected" ||
	   os.args[1] == "slider-minimum" ||
	   os.args[1] == "slider-midpoint" ||
	   os.args[1] == "slider-maximum" {
		ctx.mouse_x = -1
		ctx.mouse_y = -1
	}
	if interaction_case {
		buttons: smgui.Input_Buttons
		if os.args[1] == "button-pressed" ||
		   os.args[1] == "checkbox-pressed" ||
		   os.args[1] == "radio-pressed" ||
		   os.args[1] == "slider-interaction" {
			buttons += {.Mouse_Left}
		}
		event_x := 10
		if os.args[1] == "slider-interaction" {
			event_x = 29
		}
		if error := smgui.push_event(
			&ctx,
			{kind = .Mouse, buttons = buttons, x = event_x, y = 10},
		); error != .None {
			fmt.eprintf("event injection failed: %v\n", error)
			os.exit(1)
		}
	}
	for {
		_, state, error := smgui.poll_event(&ctx, forms)
		if error != .None {
			fmt.eprintf("poll failed: %v\n", error)
			os.exit(1)
		}
		if state == .Closed {
			break
		}
	}
	if os.args[1] == "slider-interaction" && slider_interaction_value != 53 {
		fmt.eprintf("slider interaction produced %d instead of 53\n", slider_interaction_value)
		os.exit(1)
	}
	if os.args[1] == "radio-pressed" && pressed_radio_value != 1 {
		fmt.eprintln("radio press did not update its bound value")
		os.exit(1)
	}
	if os.args[1] == "checkbox-pressed" && !pressed_value {
		fmt.eprintln("checkbox press did not update its bound value")
		os.exit(1)
	}
	if !image_state.succeeded {
		fmt.eprintf("failed to write %s\n", os.args[2])
		os.exit(1)
	}
}
