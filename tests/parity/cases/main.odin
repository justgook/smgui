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
		os.args[1] == "radio-pressed"
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
	   os.args[1] == "slider-midpoint" {
		ctx.mouse_x = -1
		ctx.mouse_y = -1
	}
	if interaction_case {
		buttons: smgui.Input_Buttons
		if os.args[1] == "button-pressed" ||
		   os.args[1] == "checkbox-pressed" ||
		   os.args[1] == "radio-pressed" {
			buttons += {.Mouse_Left}
		}
		if error := smgui.push_event(&ctx, {kind = .Mouse, buttons = buttons, x = 10, y = 10});
		   error != .None {
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
