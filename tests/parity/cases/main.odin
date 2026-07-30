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
	text_input_empty_value: smgui.Text_Buffer
	if error := smgui.text_buffer_init(&text_input_empty_value, "", 15); error != .None {
		fmt.eprintln("failed to initialize empty text input buffer")
		os.exit(1)
	}
	defer smgui.text_buffer_deinit(&text_input_empty_value)
	text_input_empty := []smgui.Form {
		{kind = .Text_Input, binding = smgui.bind_text(&text_input_empty_value)},
	}
	text_input_explicit_size := []smgui.Form {
		{
			kind = .Text_Input,
			width = 76,
			height = 28,
			binding = smgui.bind_text(&text_input_value),
		},
	}
	text_input_edit_value: smgui.Text_Buffer
	if error := smgui.text_buffer_init(&text_input_edit_value, "Hello", 15); error != .None {
		fmt.eprintln("failed to initialize editable text input buffer")
		os.exit(1)
	}
	defer smgui.text_buffer_deinit(&text_input_edit_value)
	text_input_edit := []smgui.Form {
		{
			kind = .Text_Input,
			width = 76,
			height = 28,
			binding = smgui.bind_text(&text_input_edit_value),
		},
	}
	text_input_disabled := []smgui.Form {
		{kind = .Text_Input, flags = {.Disabled}, binding = smgui.bind_text(&text_input_value)},
	}
	numeric_input_value := 42
	numeric_input_decrement_value := 42
	numeric_input_increment_value := 42
	numeric_input_normal := []smgui.Form {
		{
			kind = .Integer_64,
			binding = smgui.bind(&numeric_input_value),
			minimum = 0,
			maximum = 100,
			increment = 5,
		},
	}
	numeric_input_explicit_size := []smgui.Form {
		{
			kind = .Integer_64,
			width = 90,
			height = 28,
			binding = smgui.bind(&numeric_input_value),
			minimum = 0,
			maximum = 100,
			increment = 5,
		},
	}
	numeric_input_decrement := []smgui.Form {
		{
			kind = .Integer_64,
			binding = smgui.bind(&numeric_input_decrement_value),
			minimum = 0,
			maximum = 100,
			increment = 5,
		},
	}
	numeric_input_increment := []smgui.Form {
		{
			kind = .Integer_64,
			binding = smgui.bind(&numeric_input_increment_value),
			minimum = 0,
			maximum = 100,
			increment = 5,
		},
	}
	numeric_input_disabled := []smgui.Form {
		{
			kind = .Integer_64,
			flags = {.Disabled},
			binding = smgui.bind(&numeric_input_value),
			minimum = 0,
			maximum = 100,
			increment = 5,
		},
	}
	select_value := 0
	select_choice_value := -1
	select_options := []string{"Alpha", "Beta"}
	select_normal := []smgui.Form {
		{kind = .Select, binding = smgui.bind(&select_value), options = select_options},
	}
	select_explicit_size := []smgui.Form {
		{
			kind = .Select,
			width = 76,
			height = 28,
			binding = smgui.bind(&select_value),
			options = select_options,
		},
	}
	select_pressed := []smgui.Form {
		{kind = .Select, binding = smgui.bind(&select_value), options = select_options},
	}
	select_open := []smgui.Form {
		{
			kind = .Select,
			y = smgui.absolute(10),
			binding = smgui.bind(&select_value),
			options = select_options,
		},
	}
	select_choice := []smgui.Form {
		{
			kind = .Select,
			y = smgui.absolute(10),
			binding = smgui.bind(&select_choice_value),
			options = select_options,
		},
	}
	select_disabled := []smgui.Form {
		{
			kind = .Select,
			flags = {.Disabled},
			binding = smgui.bind(&select_value),
			options = select_options,
		},
	}
	option_value := 0
	option_decrement_value := 0
	option_increment_value := 1
	option_options := []string{"One", "Two"}
	option_normal := []smgui.Form {
		{kind = .Option, binding = smgui.bind(&option_value), options = option_options},
	}
	option_explicit_size := []smgui.Form {
		{
			kind = .Option,
			width = 90,
			height = 28,
			binding = smgui.bind(&option_value),
			options = option_options,
		},
	}
	option_decrement := []smgui.Form {
		{kind = .Option, binding = smgui.bind(&option_decrement_value), options = option_options},
	}
	option_increment := []smgui.Form {
		{kind = .Option, binding = smgui.bind(&option_increment_value), options = option_options},
	}
	option_disabled := []smgui.Form {
		{
			kind = .Option,
			flags = {.Disabled},
			binding = smgui.bind(&option_value),
			options = option_options,
		},
	}
	division_label_children := []smgui.Form{{kind = .Label, label = 1}}
	division_intrinsic := []smgui.Form {
		{kind = .Division, x = smgui.absolute(5), y = smgui.absolute(5), margin = 4, children = division_label_children},
	}
	division_percentage := []smgui.Form {
		{kind = .Division, width_percentage = 100, margin = 4, children = division_label_children},
	}
	popup_empty_children := []smgui.Form{}
	popup_content_children := []smgui.Form{{kind = .Label, label = 1}}
	popup_normal := []smgui.Form {
		{kind = .Popup, x = smgui.absolute(5), y = smgui.absolute(5), width = 50, height = 35, children = popup_empty_children},
	}
	popup_intrinsic := []smgui.Form {
		{kind = .Popup, x = smgui.absolute(5), y = smgui.absolute(5), children = popup_content_children},
	}
	popup_no_border := []smgui.Form {
		{kind = .Popup, flags = {.No_Border}, x = smgui.absolute(5), y = smgui.absolute(5), width = 50, height = 35, children = popup_empty_children},
	}
	popup_no_shadow := []smgui.Form {
		{kind = .Popup, flags = {.No_Shadow}, x = smgui.absolute(5), y = smgui.absolute(5), width = 50, height = 35, children = popup_empty_children},
	}
	popup_title := []smgui.Form {
		{kind = .Popup, x = smgui.absolute(5), y = smgui.absolute(5), width = 55, height = 40, label = 6, children = popup_empty_children},
	}
	popup_draggable := []smgui.Form {
		{kind = .Popup, flags = {.Draggable}, x = smgui.absolute(5), y = smgui.absolute(5), width = 55, height = 40, label = 6, children = popup_empty_children},
	}
	popup_chrome := []smgui.Form {
		{kind = .Popup, flags = {.Draggable, .Resizable}, x = smgui.absolute(5), y = smgui.absolute(5), width = 55, height = 40, children = popup_empty_children},
	}
	popup_resizable := []smgui.Form {
		{kind = .Popup, flags = {.Resizable}, x = smgui.absolute(5), y = smgui.absolute(5), width = 50, height = 35, children = popup_empty_children},
	}
	popup_hidden := []smgui.Form {
		{kind = .Popup, flags = {.Hidden}, x = smgui.absolute(5), y = smgui.absolute(5), width = 50, height = 35, children = popup_empty_children},
	}
	popup_close := []smgui.Form {
		{kind = .Popup, flags = {.Draggable}, x = smgui.absolute(5), y = smgui.absolute(5), width = 55, height = 40, label = 6, children = popup_empty_children},
	}
	popup_drag := []smgui.Form {
		{kind = .Popup, flags = {.Draggable}, x = smgui.absolute(5), y = smgui.absolute(5), width = 55, height = 40, children = popup_empty_children},
	}
	popup_resize := []smgui.Form {
		{kind = .Popup, flags = {.Resizable}, x = smgui.absolute(5), y = smgui.absolute(5), width = 55, height = 40, children = popup_empty_children},
	}
	menu_label_children := []smgui.Form{{kind = .Label, label = 8}}
	menu_disabled_children := []smgui.Form{{kind = .Label, flags = {.Disabled}, label = 8}}
	menu_choice_value := 0
	menu_choice_children := []smgui.Form {
		{kind = .Radio, label = 8, binding = smgui.bind(&menu_choice_value), value = 1},
	}
	menu_closed := []smgui.Form {
		{kind = .Toggle, label = 7},
		{kind = .Menu, flags = {.Hidden}, x = smgui.absolute(5), y = smgui.absolute(22), width = 50, height = 24, children = menu_label_children},
	}
	menu_button_closed := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_button_closed[0].flags = {.No_Bullet}
	menu_button_closed[0].margin = 4
	menu_button_closed[1].children = menu_label_children
	menu_button_open := []smgui.Form{menu_button_closed[0], menu_button_closed[1]}
	menu_button_open[1].children = menu_label_children
	menu_open := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_open[1].children = menu_label_children
	menu_intrinsic := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_intrinsic[1].width = 0
	menu_intrinsic[1].height = 0
	menu_intrinsic[1].children = menu_label_children
	menu_anchored := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_anchored[1].x = {}
	menu_anchored[1].y = {}
	menu_anchored[1].children = menu_label_children
	menu_hover := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_hover[1].children = menu_label_children
	menu_disabled := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_disabled[1].children = menu_disabled_children
	menu_choice := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_choice[1].children = menu_choice_children
	menu_outside_close := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_outside_close[1].children = menu_label_children
	menu_escape_close := []smgui.Form{menu_closed[0], menu_closed[1]}
	menu_escape_close[1].children = menu_label_children
	menu_closed[0].binding = smgui.bind(&menu_closed[1])
	menu_button_closed[0].binding = smgui.bind(&menu_button_closed[1])
	menu_button_open[0].binding = smgui.bind(&menu_button_open[1])
	menu_open[0].binding = smgui.bind(&menu_open[1])
	menu_intrinsic[0].binding = smgui.bind(&menu_intrinsic[1])
	menu_anchored[0].binding = smgui.bind(&menu_anchored[1])
	menu_hover[0].binding = smgui.bind(&menu_hover[1])
	menu_disabled[0].binding = smgui.bind(&menu_disabled[1])
	menu_choice[0].binding = smgui.bind(&menu_choice[1])
	menu_outside_close[0].binding = smgui.bind(&menu_outside_close[1])
	menu_escape_close[0].binding = smgui.bind(&menu_escape_close[1])
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
	case "text-input-empty":
		forms = text_input_empty
	case "text-input-explicit-size":
		forms = text_input_explicit_size
	case "text-input-edit":
		forms = text_input_edit
	case "text-input-disabled":
		forms = text_input_disabled
	case "numeric-input-normal":
		forms = numeric_input_normal
	case "numeric-input-explicit-size":
		forms = numeric_input_explicit_size
	case "numeric-input-decrement":
		forms = numeric_input_decrement
	case "numeric-input-increment":
		forms = numeric_input_increment
	case "numeric-input-disabled":
		forms = numeric_input_disabled
	case "select-normal":
		forms = select_normal
	case "select-explicit-size":
		forms = select_explicit_size
	case "select-pressed":
		forms = select_pressed
	case "select-open":
		forms = select_open
	case "select-choice":
		forms = select_choice
	case "select-disabled":
		forms = select_disabled
	case "option-normal":
		forms = option_normal
	case "option-explicit-size":
		forms = option_explicit_size
	case "option-decrement":
		forms = option_decrement
	case "option-increment":
		forms = option_increment
	case "option-disabled":
		forms = option_disabled
	case "division-intrinsic":
		forms = division_intrinsic
	case "division-percentage":
		forms = division_percentage
	case "popup-normal":
		forms = popup_normal
	case "popup-intrinsic":
		forms = popup_intrinsic
	case "popup-no-border":
		forms = popup_no_border
	case "popup-no-shadow":
		forms = popup_no_shadow
	case "popup-title":
		forms = popup_title
	case "popup-draggable":
		forms = popup_draggable
	case "popup-chrome":
		forms = popup_chrome
	case "popup-resizable":
		forms = popup_resizable
	case "popup-hidden":
		forms = popup_hidden
	case "popup-close":
		forms = popup_close
	case "popup-drag":
		forms = popup_drag
	case "popup-resize":
		forms = popup_resize
	case "menu-closed":
		forms = menu_closed
	case "menu-button-closed":
		forms = menu_button_closed
	case "menu-button-open":
		forms = menu_button_open
	case "menu-open":
		forms = menu_open
	case "menu-intrinsic":
		forms = menu_intrinsic
	case "menu-anchored":
		forms = menu_anchored
	case "menu-hover":
		forms = menu_hover
	case "menu-disabled":
		forms = menu_disabled
	case "menu-choice":
		forms = menu_choice
	case "menu-outside-close":
		forms = menu_outside_close
	case "menu-escape-close":
		forms = menu_escape_close
	case:
		fmt.eprintf("unknown parity case: %s\n", os.args[1])
		os.exit(2)
	}

	texts := []string{"Parity fixture", "Label", "Button", "Btn", "Check", "Radio", "Panel", "Menu", "Open"}
	interaction_case :=
		os.args[1] == "button-hover" ||
		os.args[1] == "button-pressed" ||
		os.args[1] == "checkbox-hover" ||
		os.args[1] == "checkbox-pressed" ||
		os.args[1] == "radio-hover" ||
		os.args[1] == "radio-pressed" ||
		os.args[1] == "slider-interaction" ||
		os.args[1] == "text-input-edit" ||
		os.args[1] == "numeric-input-decrement" ||
		os.args[1] == "numeric-input-increment" ||
		os.args[1] == "select-pressed" ||
		os.args[1] == "select-open" ||
		os.args[1] == "select-choice" ||
		os.args[1] == "option-decrement" ||
		os.args[1] == "option-increment" ||
		os.args[1] == "popup-close" ||
		os.args[1] == "popup-drag" ||
		os.args[1] == "popup-resize" ||
		os.args[1] == "menu-open" ||
		os.args[1] == "menu-button-open" ||
		os.args[1] == "menu-intrinsic" ||
		os.args[1] == "menu-anchored" ||
		os.args[1] == "menu-hover" ||
		os.args[1] == "menu-disabled" ||
		os.args[1] == "menu-choice" ||
		os.args[1] == "menu-outside-close" ||
		os.args[1] == "menu-escape-close"
	capture_delay := 0
	if interaction_case {
		capture_delay = 1
	}
	if os.args[1] == "menu-hover" || os.args[1] == "menu-disabled" ||
	   os.args[1] == "menu-choice" || os.args[1] == "menu-outside-close" ||
	   os.args[1] == "menu-escape-close" {
		capture_delay = 4
	} else if os.args[1] == "popup-drag" || os.args[1] == "popup-resize" {
		capture_delay = 4
	} else if os.args[1] == "popup-close" || os.args[1] == "menu-open" ||
	          os.args[1] == "menu-button-open" ||
	          os.args[1] == "menu-intrinsic" || os.args[1] == "menu-anchored" {
		capture_delay = 2
	} else if os.args[1] == "select-pressed" {
		capture_delay = 2
	} else if os.args[1] == "select-open" {
		capture_delay = 3
	} else if os.args[1] == "text-input-edit" {
		capture_delay = 3
	} else if os.args[1] == "select-choice" {
		capture_delay = 5
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
	   os.args[1] == "slider-maximum" ||
	   os.args[1] == "select-normal" ||
	   os.args[1] == "select-explicit-size" ||
	   os.args[1] == "option-normal" ||
	   os.args[1] == "option-explicit-size" {
		ctx.mouse_x = -1
		ctx.mouse_y = -1
	}
	if interaction_case {
		buttons: smgui.Input_Buttons
		if os.args[1] == "button-pressed" ||
		   os.args[1] == "checkbox-pressed" ||
		   os.args[1] == "radio-pressed" ||
		   os.args[1] == "slider-interaction" ||
		   os.args[1] == "numeric-input-decrement" ||
		   os.args[1] == "numeric-input-increment" ||
		   os.args[1] == "select-pressed" ||
		   os.args[1] == "select-open" ||
		   os.args[1] == "select-choice" ||
		   os.args[1] == "option-decrement" ||
		   os.args[1] == "option-increment" ||
		   os.args[1] == "popup-close" ||
		   os.args[1] == "popup-drag" ||
		   os.args[1] == "popup-resize" ||
		   os.args[1] == "menu-open" ||
		   os.args[1] == "menu-button-open" ||
		   os.args[1] == "menu-intrinsic" ||
		   os.args[1] == "menu-anchored" ||
		   os.args[1] == "menu-hover" ||
		   os.args[1] == "menu-disabled" ||
		   os.args[1] == "menu-choice" ||
		   os.args[1] == "menu-outside-close" ||
		   os.args[1] == "menu-escape-close" {
			buttons += {.Mouse_Left}
		}
		event_x := 10
		event_y := 10
		if os.args[1] == "slider-interaction" {
			event_x = 29
		} else if os.args[1] == "text-input-edit" {
			event_x = 60
			buttons = {.Mouse_Left}
		} else if os.args[1] == "numeric-input-increment" {
			event_x = 61
		} else if os.args[1] == "option-increment" {
			event_x = 55
		} else if os.args[1] == "popup-close" {
			event_x = 50
		} else if os.args[1] == "popup-resize" {
			event_x, event_y = 57, 42
		} else if os.args[1] == "select-open" || os.args[1] == "select-choice" {
			event_y = 15
		}
		if os.args[1] == "select-pressed" ||
		   os.args[1] == "select-open" ||
		   os.args[1] == "select-choice" {
			if error := smgui.push_event(
				&ctx,
				{kind = .Mouse, x = event_x, y = event_y},
			); error != .None {
				fmt.eprintf("select hover injection failed: %v\n", error)
				os.exit(1)
			}
		}
		if os.args[1] == "popup-close" || os.args[1] == "popup-drag" ||
		   os.args[1] == "popup-resize" || os.args[1] == "menu-open" ||
		   os.args[1] == "menu-button-open" ||
		   os.args[1] == "menu-intrinsic" || os.args[1] == "menu-anchored" ||
		   os.args[1] == "menu-hover" ||
		   os.args[1] == "menu-disabled" || os.args[1] == "menu-choice" ||
		   os.args[1] == "menu-outside-close" || os.args[1] == "menu-escape-close" {
			if error := smgui.push_event(
				&ctx,
				{kind = .Mouse, x = event_x, y = event_y},
			); error != .None {
				fmt.eprintf("menu warmup injection failed: %v\n", error)
				os.exit(1)
			}
		}
		if error := smgui.push_event(
			&ctx,
			{kind = .Mouse, buttons = buttons, x = event_x, y = event_y},
		); error != .None {
			fmt.eprintf("event injection failed: %v\n", error)
			os.exit(1)
		}
		if os.args[1] == "menu-hover" || os.args[1] == "menu-disabled" ||
		   os.args[1] == "menu-choice" || os.args[1] == "menu-outside-close" ||
		   os.args[1] == "menu-escape-close" {
			idle_x, idle_y := 10, 30
			if os.args[1] == "menu-outside-close" {
				idle_x, idle_y = 60, 10
			}
			if error := smgui.push_event(
				&ctx,
				{kind = .Key, key = smgui.key_input("x"), x = idle_x, y = idle_y},
			); error != .None {
				fmt.eprintf("menu idle injection failed: %v\n", error)
				os.exit(1)
			}
		}
		if os.args[1] == "menu-hover" || os.args[1] == "menu-disabled" ||
		   os.args[1] == "menu-choice" {
			second_event := smgui.Event {
				kind = .Key,
				key = smgui.key_input("x"),
				x = 10,
				y = 30,
			}
			if os.args[1] == "menu-choice" {
				second_event.kind = .Mouse
				second_event.buttons = {.Mouse_Left, .Released}
			}
			if error := smgui.push_event(
				&ctx,
				second_event,
			); error != .None {
				fmt.eprintf("menu item injection failed: %v\n", error)
				os.exit(1)
			}
		} else if os.args[1] == "menu-outside-close" {
			if error := smgui.push_event(
				&ctx,
				{kind = .Mouse, buttons = {.Mouse_Left}, x = 60, y = 10},
			); error != .None {
				fmt.eprintf("menu outside injection failed: %v\n", error)
				os.exit(1)
			}
		}
		if os.args[1] == "popup-drag" || os.args[1] == "popup-resize" {
			end_x, end_y := 25, 20
			if os.args[1] == "popup-resize" {
				end_x, end_y = 47, 32
			}
			if error := smgui.push_event(
				&ctx,
				{kind = .Mouse, buttons = {.Mouse_Left}, x = end_x, y = end_y},
			); error != .None {
				fmt.eprintf("popup motion injection failed: %v\n", error)
				os.exit(1)
			}
			if error := smgui.push_event(
				&ctx,
				{kind = .Mouse, buttons = {.Released}, x = end_x, y = end_y},
			); error != .None {
				fmt.eprintf("popup release injection failed: %v\n", error)
				os.exit(1)
			}
		}
		if os.args[1] == "select-open" || os.args[1] == "select-choice" {
			if error := smgui.push_event(
				&ctx,
				{kind = .Mouse, buttons = {.Released}, x = event_x, y = event_y},
			); error != .None {
				fmt.eprintf("select release injection failed: %v\n", error)
				os.exit(1)
			}
			if os.args[1] == "select-choice" {
				for _ in 0 ..< 2 {
					if error := smgui.push_event(
						&ctx,
						{kind = .Key, key = smgui.key_input("Enter")},
					); error != .None {
						fmt.eprintf("select choice injection failed: %v\n", error)
						os.exit(1)
					}
				}
			}
		}
		if os.args[1] == "text-input-edit" {
			if error := smgui.push_event(&ctx, {kind = .Key, key = smgui.key_input("!")});
			   error != .None {
				fmt.eprintf("key injection failed: %v\n", error)
				os.exit(1)
			}
			if error := smgui.push_event(&ctx, {kind = .Key, key = smgui.key_input("Enter")});
			   error != .None {
				fmt.eprintf("commit injection failed: %v\n", error)
				os.exit(1)
			}
		}
	}
	if os.args[1] == "menu-escape-close" {
		if error := smgui.push_event(&ctx, {kind = .Key, key = smgui.key_input("\e")});
		   error != .None {
			fmt.eprintf("menu escape injection failed: %v\n", error)
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
	if os.args[1] == "division-intrinsic" &&
	   (division_intrinsic[0].computed_width != 57 || division_intrinsic[0].computed_height != 32) {
		fmt.eprintf(
			"intrinsic division measured %dx%d instead of 57x32\n",
			division_intrinsic[0].computed_width,
			division_intrinsic[0].computed_height,
		)
		os.exit(1)
	}
	if os.args[1] == "division-percentage" &&
	   (division_percentage[0].computed_width != max(width, 57) || division_percentage[0].computed_height != 32) {
		fmt.eprintf(
			"percentage division measured %dx%d instead of %dx32\n",
			division_percentage[0].computed_width,
			division_percentage[0].computed_height,
			max(width, 57),
		)
		os.exit(1)
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
	if os.args[1] == "text-input-edit" &&
	   smgui.text_buffer_string(&text_input_edit_value) != "Hello!" {
		fmt.eprintf(
			"text input edit produced %q instead of Hello!\n",
			smgui.text_buffer_string(&text_input_edit_value),
		)
		os.exit(1)
	}
	if os.args[1] == "numeric-input-decrement" && numeric_input_decrement_value != 37 {
		fmt.eprintf("numeric decrement produced %d instead of 37\n", numeric_input_decrement_value)
		os.exit(1)
	}
	if os.args[1] == "numeric-input-increment" && numeric_input_increment_value != 47 {
		fmt.eprintf("numeric increment produced %d instead of 47\n", numeric_input_increment_value)
		os.exit(1)
	}
	if os.args[1] == "select-choice" && select_choice_value != 0 {
		fmt.eprintf("select choice produced %d instead of 0\n", select_choice_value)
		os.exit(1)
	}
	if os.args[1] == "option-decrement" && option_decrement_value != 1 {
		fmt.eprintf("option decrement produced %d instead of 1\n", option_decrement_value)
		os.exit(1)
	}
	if os.args[1] == "option-increment" && option_increment_value != 0 {
		fmt.eprintf("option increment produced %d instead of 0\n", option_increment_value)
		os.exit(1)
	}
	if os.args[1] == "popup-close" && .Hidden not_in popup_close[0].flags {
		fmt.eprintln("popup close did not hide the popup")
		os.exit(1)
	}
	if os.args[1] == "popup-drag" {
		expected_x := min(20, width - 56)
		expected_y := min(15, height - 41)
		if popup_drag[0].computed_x != expected_x || popup_drag[0].computed_y != expected_y {
			fmt.eprintf(
				"popup drag moved to %d,%d instead of %d,%d\n",
				popup_drag[0].computed_x,
				popup_drag[0].computed_y,
				expected_x,
				expected_y,
			)
			os.exit(1)
		}
	}
	if os.args[1] == "popup-resize" &&
	   (popup_resize[0].computed_width != 45 || popup_resize[0].computed_height != 30) {
		fmt.eprintf(
			"popup resize produced %dx%d instead of 45x30\n",
			popup_resize[0].computed_width,
			popup_resize[0].computed_height,
		)
		os.exit(1)
	}
	if os.args[1] == "menu-choice" && menu_choice_value != 1 {
		fmt.eprintln("menu choice did not mutate its bound value")
		os.exit(1)
	}
	if !image_state.succeeded {
		fmt.eprintf("failed to write %s\n", os.args[2])
		os.exit(1)
	}
}
