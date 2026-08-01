package smgui

/*
Port of: reference-c/ui.h

Purpose:
  Backend-independent state-mode GUI types, layout, rendering, and event logic.

Status:
  [x] Idiomatic Odin public interface declared
  [x] Typed errors, slices, enums, and bit sets declared
  [x] Backend adapter seam declared
  [x] Framebuffer lifecycle and bounded event queue implemented
  [x] Labels, multiline labels, status fields, images, icons, color inputs, buttons, checkboxes, and radio buttons render
  [x] Buttons, toggle/icon buttons, checkboxes, radio buttons, sliders, images, icons, and color inputs mutate bound state
  [x] Integer/float displays, sliders, and progress bars render
  [x] UTF-8 text input, horizontal cursor viewport, cursor editing, and input filters implemented
  [x] Integer and floating-point text/stepper inputs implemented
  [x] Select dropdowns and option steppers implemented
  [x] Line, connector, and curve drawing primitives implemented
  [x] Standalone vertical and horizontal scrollbars implemented
  [x] Relative flow layout and division containers implemented
  [x] Popup/menu overlay layout, rendering, toggles, and event routing implemented
  [x] Popup dragging, resizing, clipped container scrolling, and child text clipping implemented
  [x] Reference nested flow origins, breaks, wrapping, percentages, from-end positions, and alignment implemented
  [x] Wheel routing, event consumption, and drop/resize/gamepad passthrough implemented
  [x] Custom bounds, view, control, popup, and finalization callbacks implemented
  [x] Software cursor and PNG skin loading implemented

Definition of done:
  - `make check` passes
  - Every public operation has behavioral parity coverage
  - Deterministic framebuffer fixtures match reference-c
  - No operation reports success before doing its documented work
*/

import "core:c"
import "core:fmt"
import "core:math"
import "core:strconv"
import "core:strings"
import stbi "vendor:stb/image"

Error :: enum {
	None,
	Invalid_Input,
	Backend_Failure,
	Out_Of_Memory,
	Event_Queue_Full,
	Not_Implemented,
}

Theme_Color :: enum {
	Foreground,
	Title,
	Background,
	Shadow,
	Toggle_Foreground,
	Toggle_Background,
	Highlight_Foreground,
	Highlight_Background,
	Disabled_Foreground,
	Disabled_Background,
	Scrollbar_Background,
	Input_Foreground,
	Input_Light_Border,
	Input_Dark_Border,
	Input_Background,
	Input_Selected_Foreground,
	Input_Selected_Border,
	Input_Cursor,
	Button_Foreground,
	Button_Light_Shadow,
	Button_Dark_Shadow,
	Button_Normal_Border,
	Button_Selected_Foreground,
	Button_Selected_Light_Shadow,
	Button_Selected_Dark_Shadow,
	Button_Selected_Border,
	Button_Light_Inner_Border,
	Button_Dark_Inner_Border,
	Button_Light_Background,
	Button_Dark_Background,
	Progress_Light,
	Progress_Background,
	Progress_Dark,
	Count,
}

Skin_Image :: enum {
	Cursor,
	Popup_Top_Left,
	Popup_Top_Middle,
	Popup_Top_Right,
	Popup_Middle_Left,
	Popup_Background,
	Popup_Middle_Right,
	Popup_Bottom_Left,
	Popup_Bottom_Middle,
	Popup_Bottom_Right,
	Popup_Title,
	Popup_Close,
	Alternative_Top_Left,
	Alternative_Top_Middle,
	Alternative_Top_Right,
	Alternative_Middle_Left,
	Alternative_Background,
	Alternative_Middle_Right,
	Alternative_Bottom_Left,
	Alternative_Bottom_Middle,
	Alternative_Bottom_Right,
	Alternative_Title,
	Alternative_Close,
	Menu_Left,
	Menu_Background,
	Menu_Right,
	Highlight,
	Input,
	Progress_Background,
	Slider_Left,
	Slider_Middle,
	Slider_Right,
	Slider_Button,
	Vertical_Scrollbar_Top,
	Vertical_Scrollbar_Middle,
	Vertical_Scrollbar_Bottom,
	Vertical_Scrollbar_Button_Top,
	Vertical_Scrollbar_Button_Middle,
	Vertical_Scrollbar_Button_Bottom,
	Horizontal_Scrollbar_Left,
	Horizontal_Scrollbar_Middle,
	Horizontal_Scrollbar_Right,
	Horizontal_Scrollbar_Button_Left,
	Horizontal_Scrollbar_Button_Middle,
	Horizontal_Scrollbar_Button_Right,
	Checkbox_Off,
	Checkbox_On,
	Radio_Off,
	Radio_On,
	Button_Normal_Left,
	Button_Normal_Middle,
	Button_Normal_Right,
	Button_Pressed_Left,
	Button_Pressed_Middle,
	Button_Pressed_Right,
	Button_Selected_Left,
	Button_Selected_Middle,
	Button_Selected_Right,
	Arrow_Left_Normal,
	Arrow_Down_Normal,
	Arrow_Right_Normal,
	Arrow_Left_Pressed,
	Arrow_Down_Pressed,
	Arrow_Right_Pressed,
	Arrow_Left_Selected,
	Arrow_Down_Selected,
	Arrow_Right_Selected,
	Count,
}

Field_Kind :: enum u8 {
	End,
	Popup,
	Menu,
	Division,
	Label,
	Multiline_Label,
	Status,
	Decimal_Float,
	Progress_Bar,
	Image,
	Icon,
	Decimal_8,
	Decimal_16,
	Decimal_32,
	Decimal_64,
	Hexadecimal_8,
	Hexadecimal_16,
	Hexadecimal_32,
	Hexadecimal_64,
	Text_Input,
	Select,
	Option,
	Float_Input,
	Integer_8,
	Integer_16,
	Integer_32,
	Integer_64,
	Slider,
	Vertical_Scrollbar,
	Horizontal_Scrollbar,
	Color,
	Toggle,
	Checkbox,
	Radio,
	Button,
	Toggle_Button,
	Icon_Button,
	Lines,
	Vertical_Connector,
	Horizontal_Connector,
	Curve,
	Custom,
}

Horizontal_Alignment :: enum u8 {
	Left,
	Right,
	Center,
}

Vertical_Alignment :: enum u8 {
	Top,
	Bottom,
	Middle,
}

Form_Flag :: enum {
	Hidden,
	No_Bullet,
	No_Header,
	No_Break,
	Force_Break,
	Pointer,
	No_Border,
	No_Shadow,
	Alternative_Skin,
	Horizontal_Scroll,
	Vertical_Scroll,
	Draggable,
	Resizable,
	Selected,
	Disabled,
}

Form_Flags :: bit_set[Form_Flag;u16]

Context_Flag :: enum {
	Refresh,
	Recalculate,
	Close,
	Done,
}

Context_Flags :: bit_set[Context_Flag;u64]

Text_Filter :: enum u8 {
	None,
	Identifier,
	Variable,
	Expression,
	Hexadecimal,
	Integer,
	Decimal,
	Password,
}

Event_Kind :: enum u8 {
	None,
	Mouse,
	Gamepad,
	Key,
	Drop,
	Resize,
}

Input_Button :: enum {
	Mouse_Left,
	Mouse_Middle,
	Mouse_Right,
	Direction_Up,
	Direction_Down,
	Gamepad_A,
	Gamepad_B,
	Gamepad_X,
	Gamepad_Y,
	Gamepad_Back,
	Gamepad_Start,
	Gamepad_Guide,
	Gamepad_Left_Trigger,
	Gamepad_Right_Trigger,
	Gamepad_Left_Stick,
	Gamepad_Right_Stick,
	Released,
	Shift,
	Control,
	Alt,
	Gui,
}

Input_Buttons :: bit_set[Input_Button;u32]

Position_Mode :: enum u8 {
	Relative,
	Absolute,
	Percent,
	Percent_Plus,
	Absolute_From_End,
}

Position :: struct {
	mode:   Position_Mode,
	value:  i32,
	offset: i32,
}

Image :: struct {
	width:  int,
	height: int,
	pitch:  int,
	pixels: []u8,
}

Key_Input :: struct {
	bytes:  [16]u8,
	length: u8,
}

key_input :: proc(text: string) -> Key_Input {
	key: Key_Input
	length := min(len(text), len(key.bytes))
	copy(key.bytes[:], transmute([]u8)(text[:length]))
	key.length = u8(length)
	return key
}

key_text :: proc(key: ^Key_Input) -> string {
	if key == nil {
		return ""
	}
	return string(key.bytes[:key.length])
}

Event :: struct {
	kind:      Event_Kind,
	buttons:   Input_Buttons,
	x:         int,
	y:         int,
	right_x:   int,
	right_y:   int,
	key:       Key_Input,
	file_name: string,
}

Binding_Kind :: enum u8 {
	None,
	Boolean,
	Integer,
	Float,
	Color,
	Text,
	Image,
	Forms,
	Custom,
}

Binding :: struct {
	kind: Binding_Kind,
	data: rawptr,
}

Text_Buffer :: struct {
	data:       [dynamic]u8,
	max_length: int,
}

@(require_results)
text_buffer_init :: proc(
	buffer: ^Text_Buffer,
	initial: string = "",
	max_length: int = 256,
) -> Error {
	if buffer == nil || max_length < 1 || len(initial) > max_length {
		return .Invalid_Input
	}
	buffer.data = make([dynamic]u8, 0, max_length) or_else nil
	if buffer.data == nil {
		return .Out_Of_Memory
	}
	buffer.max_length = max_length
	if (append(&buffer.data, initial) or_else -1) < 0 {
		delete(buffer.data)
		buffer^ = {}
		return .Out_Of_Memory
	}
	return .None
}

text_buffer_deinit :: proc(buffer: ^Text_Buffer) {
	if buffer == nil {
		return
	}
	if buffer.data != nil {
		delete(buffer.data)
	}
	buffer^ = {}
}

text_buffer_string :: proc(buffer: ^Text_Buffer) -> string {
	if buffer == nil || buffer.data == nil {
		return ""
	}
	return string(buffer.data[:])
}

Font_Bounds_Proc :: #type proc(
	font: rawptr,
	text: string,
	width: ^int,
	height: ^int,
	left: ^int,
	top: ^int,
) -> Error

Font_Draw_Proc :: #type proc(
	font: rawptr,
	text: string,
	destination: []u8,
	color: u32,
	x, y, left, top, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) -> Error

Bounds_Proc :: #type proc(
	ctx: ^Context,
	x, y, width, height: int,
	form: ^Form,
	desired_width, desired_height: ^int,
) -> Error

View_Proc :: #type proc(ctx: ^Context, x, y, width, height: int, form: ^Form) -> Error

Control_Proc :: #type proc(
	ctx: ^Context,
	x, y, width, height: int,
	form: ^Form,
	event: ^Event,
) -> Error

Finalize_Proc :: #type proc(ctx: ^Context, form: ^Form)
Compare_Proc :: #type proc(left, right: rawptr) -> int

Custom_Widget :: struct {
	bounds:       Bounds_Proc,
	view:         View_Proc,
	control:      Control_Proc,
	finalize:     Finalize_Proc,
	comparators:  []Compare_Proc,
	data:         rawptr,
	string_index: int,
	indices:      []int,
	table_text:   string,
}

Form :: struct {
	kind:                 Field_Kind,
	horizontal_alignment: Horizontal_Alignment,
	vertical_alignment:   Vertical_Alignment,
	flags:                Form_Flags,
	x, y:                 Position,
	width, height:        int,
	width_percentage:     int,
	height_percentage:    int,
	margin:               int,
	pitch:                int,
	left, top:            int,
	description:          int,
	computed_x:           int,
	computed_y:           int,
	computed_width:       int,
	computed_height:      int,
	content_x:            int,
	content_y:            int,
	content_width:        int,
	content_height:       int,
	binding:              Binding,
	minimum:              i64,
	maximum:              i64,
	increment:            i64,
	max_length:           int,
	filter:               Text_Filter,
	float_minimum:        f32,
	float_maximum:        f32,
	float_increment:      f32,
	icon:                 ^Image,
	value:                int,
	label:                int,
	text:                 string,
	offset_x, offset_y:   int,
	minimum_width:        int,
	minimum_height:       int,
	source_width:         int,
	source_height:        int,
	foreground:           u32,
	background:           u32,
	custom:               Custom_Widget,
	options:              []string,
	selected_option:      int,
	points:               []i16,
	children:             []Form,
}

Backend_Init_Proc :: #type proc(
	data: rawptr,
	ctx: ^Context,
	title: string,
	width, height: int,
	icon: ^Image,
) -> Error
Backend_Proc :: #type proc(data: rawptr) -> Error
Backend_Title_Proc :: #type proc(data: rawptr, title: string) -> Error
Backend_Set_Clipboard_Proc :: #type proc(data: rawptr, text: string) -> Error
Backend_Get_Clipboard_Proc :: #type proc(data: rawptr) -> (string, Error)
Backend_Window_Proc :: #type proc(data: rawptr) -> rawptr
Backend_Event_Proc :: #type proc(data: rawptr) -> (closed: bool, error: Error)

Backend :: struct {
	data:          rawptr,
	init:          Backend_Init_Proc,
	deinit:        Backend_Proc,
	poll:          Backend_Event_Proc,
	redraw:        Backend_Proc,
	focus:         Backend_Proc,
	fullscreen:    Backend_Proc,
	set_title:     Backend_Title_Proc,
	set_clipboard: Backend_Set_Clipboard_Proc,
	get_clipboard: Backend_Get_Clipboard_Proc,
	hide_cursor:   Backend_Proc,
	show_cursor:   Backend_Proc,
	hide_keyboard: Backend_Proc,
	show_keyboard: Backend_Proc,
	native_window: Backend_Window_Proc,
}

MAX_EVENTS :: 16
MAX_POPUPS :: 16
THEME_COLOR_COUNT :: int(Theme_Color.Count)
SKIN_IMAGE_COUNT :: int(Skin_Image.Count)

Context :: struct {
	screen:         Image,
	skin:           [SKIN_IMAGE_COUNT]Image,
	backend:        Backend,
	skin_buffer:    []u8,
	software_cursor: Image,
	theme:          [THEME_COLOR_COUNT]u32,
	texts:          []string,
	font:           rawptr,
	font_bounds:    Font_Bounds_Proc,
	font_draw:      Font_Draw_Proc,
	form:           []Form,
	menu:           ^Form,
	menu_anchor:    ^Form,
	hovered:        ^Form,
	dragged:        ^Form,
	resized:        ^Form,
	pressed:        ^Form,
	pressed_part:   i8,
	vertical_bar:   ^Form,
	horizontal_bar: ^Form,
	scrollbar_width: int,
	scrollbar_height: int,
	scrollbar_grab: int,
	scrollbar_start: int,
	scrollbar_end: int,
	scrollbar_range: int,
	text_field:     ^Form,
	text_cursor:    int,
	text_scroll:    int,
	edit_buffer:    Text_Buffer,
	popup:          ^Form,
	popup_x:        int,
	popup_y:        int,
	popup_width:    int,
	popup_height:   int,
	color:          u32,
	color_history:  [16]u32,
	color_hue:      int,
	color_saturation: int,
	color_value:    int,
	color_mode:     int,
	color_edit:     [8]u8,
	color_cursor:   int,
	curve_x:        int,
	curve_y:        int,
	drag_x:         int,
	drag_y:         int,
	default_size:   int,
	default_top:    int,
	popups:         [MAX_POPUPS]^Form,
	popup_count:    int,
	events:         [MAX_EVENTS]Event,
	event_head:     int,
	event_tail:     int,
	flags:          Context_Flags,
	mouse_x:        int,
	mouse_y:        int,
	last_mouse_x:   int,
	last_mouse_y:   int,
	clip_x0:        int,
	clip_y0:        int,
	clip_x1:        int,
	clip_y1:        int,
}

DEFAULT_THEME := [THEME_COLOR_COUNT]u32 {
	0xffa0a0a0,
	0xff707070,
	0xff3f3f3f,
	0x3f000000,
	0xffffffff,
	0xff3f3f3f,
	0xffffffff,
	0xff7f7f7f,
	0xff2f2f2f,
	0xff373737,
	0xff101010,
	0xffc0c0c0,
	0xff5f5f5f,
	0xff2f2f2f,
	0xff1f1f1f,
	0xffffffff,
	0xffffffff,
	0xffffffff,
	0xff000000,
	0xff5f5f5f,
	0xff373737,
	0xff101010,
	0xff000000,
	0xff5f5f5f,
	0xff373737,
	0xff001010,
	0xff5f5f5f,
	0xff1f1f1f,
	0xff474747,
	0xff373737,
	0xffaf0000,
	0xff7f0000,
	0xff5f0000,
}

relative :: proc(value: int) -> Position {
	return {mode = .Relative, value = i32(value)}
}

absolute :: proc(value: int) -> Position {
	return {mode = .Absolute, value = i32(value)}
}

absolute_from_end :: proc(inset: int) -> Position {
	return {mode = .Absolute_From_End, value = i32(inset)}
}

percent :: proc(value: int, offset: int = 0) -> Position {
	return {mode = .Percent, value = i32(value), offset = i32(offset)}
}

bind :: proc {
	bind_boolean,
	bind_integer,
	bind_color,
	bind_float,
	bind_text,
	bind_form,
}

bind_boolean :: proc(value: ^bool) -> Binding {
	return {kind = .Boolean, data = value}
}

bind_integer :: proc(value: ^int) -> Binding {
	return {kind = .Integer, data = value}
}

bind_color :: proc(value: ^u32) -> Binding {
	return {kind = .Color, data = value}
}

bind_float :: proc(value: ^f32) -> Binding {
	return {kind = .Float, data = value}
}

bind_text :: proc(value: ^Text_Buffer) -> Binding {
	return {kind = .Text, data = value}
}

bind_form :: proc(value: ^Form) -> Binding {
	return {kind = .Forms, data = value}
}

@(require_results, tag = "reference:ui_fonthook")
set_font_hooks :: proc(ctx: ^Context, bounds: Font_Bounds_Proc, draw: Font_Draw_Proc) -> Error {
	if ctx == nil || bounds == nil || draw == nil {
		return .Invalid_Input
	}
	ctx.font_bounds = bounds
	ctx.font_draw = draw
	return .None
}

@(require_results, tag = "reference:ui_font")
set_font :: proc(ctx: ^Context, font: rawptr) -> Error {
	if ctx == nil || font == nil {
		return .Invalid_Input
	}
	ctx.font = font
	return .None
}

@(require_results, tag = "reference:ui_swcursor")
set_software_cursor :: proc(ctx: ^Context, cursor: ^Image) -> Error {
	if ctx == nil || cursor == nil || !image_valid(cursor) {
		if ctx != nil {
			ctx.software_cursor = {}
		}
		return .Invalid_Input
	}
	ctx.software_cursor = cursor^
	if ctx.backend.hide_cursor != nil {
		if error := ctx.backend.hide_cursor(ctx.backend.data); error != .None {
			ctx.software_cursor = {}
			return error
		}
	}
	ctx.flags += {.Refresh}
	return .None
}

@(require_results, tag = "reference:ui_hwcursor")
use_hardware_cursor :: proc(ctx: ^Context) -> Error {
	if ctx == nil {
		return .Invalid_Input
	}
	ctx.software_cursor = {}
	if ctx.backend.show_cursor != nil {
		if error := ctx.backend.show_cursor(ctx.backend.data); error != .None {
			return error
		}
	}
	ctx.flags += {.Refresh}
	return .None
}

@(require_results, tag = "reference:ui_theme")
set_theme :: proc(ctx: ^Context, theme: []u32) -> Error {
	if ctx == nil || len(theme) != THEME_COLOR_COUNT {
		return .Invalid_Input
	}
	copy(ctx.theme[:], theme)
	return refresh(ctx)
}

@(require_results, tag = "reference:ui_skin")
set_skin :: proc(ctx: ^Context, skin: []Image) -> Error {
	if ctx == nil || len(skin) != SKIN_IMAGE_COUNT {
		return .Invalid_Input
	}
	copy(ctx.skin[:], skin)
	ctx.scrollbar_width = max(
		ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Top)].width,
		max(
			ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Middle)].width,
			ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Bottom)].width,
		),
	)
	ctx.scrollbar_height = max(
		ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Left)].height,
		max(
			ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Middle)].height,
			ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Right)].height,
		),
	)
	cursor := &ctx.skin[int(Skin_Image.Cursor)]
	if image_valid(cursor) {
		_ = set_software_cursor(ctx, cursor)
	} else {
		ctx.software_cursor = {}
	}
	return refresh(ctx)
}

@(require_results, tag = "reference:ui_pngskin")
set_png_skin :: proc(ctx: ^Context, png: []u8) -> Error {
	if ctx == nil || len(png) < 16 {
		return .Invalid_Input
	}
	width, height, channels: c.int
	decoded := stbi.load_from_memory(raw_data(png), c.int(len(png)), &width, &height, &channels, 4)
	if decoded == nil || width < 1 || height < 1 {
		return .Invalid_Input
	}
	defer stbi.image_free(decoded)
	pixel_count := int(width) * int(height) * 4
	owned := make([]u8, pixel_count) or_else nil
	if owned == nil {
		return .Out_Of_Memory
	}
	for index in 0 ..< pixel_count {
		owned[index] = decoded[index]
	}
	comment, comment_owned, found := png_skin_comment(png)
	if !found {
		delete(owned)
		return .Invalid_Input
	}
	if comment_owned != nil {
		defer delete(comment_owned)
	}

	skin: [SKIN_IMAGE_COUNT]Image
	position := 0
	atlas_width := int(width)
	atlas_height := int(height)
	skin_index := 0
	for skin_index < SKIN_IMAGE_COUNT {
		x, ok_x := parse_skin_number(comment, &position)
		y, ok_y := parse_skin_number(comment, &position)
		image_width, ok_width := parse_skin_number(comment, &position)
		image_height, ok_height := parse_skin_number(comment, &position)
		if !ok_x || !ok_y || !ok_width || !ok_height {
			break
		}
		for position < len(comment) && comment[position] != '\n' && comment[position] != ')' &&
		    comment[position] != ']' && comment[position] != '}' && comment[position] != '>' {
			position += 1
		}
		if image_width > 0 && image_height > 0 && x >= 0 && y >= 0 &&
		   x + image_width <= atlas_width && y + image_height <= atlas_height {
			offset := (y * atlas_width + x) * 4
			skin[skin_index] = {
				width = image_width,
				height = image_height,
				pitch = atlas_width * 4,
				pixels = owned[offset:],
			}
			skin_index += 1
		}
	}
	old_buffer := ctx.skin_buffer
	if error := set_skin(ctx, skin[:]); error != .None {
		delete(owned)
		return error
	}
	ctx.skin_buffer = owned
	if old_buffer != nil {
		delete(old_buffer)
	}
	return .None
}

@(private = "file")
png_u32_be :: proc(bytes: []u8, offset: int) -> (u32, bool) {
	if offset < 0 || offset + 4 > len(bytes) {
		return 0, false
	}
	return u32(bytes[offset]) << 24 | u32(bytes[offset + 1]) << 16 |
	       u32(bytes[offset + 2]) << 8 | u32(bytes[offset + 3]), true
}

@(private = "file")
png_skin_comment :: proc(png: []u8) -> (comment: []u8, owned: []u8, found: bool) {
	position := 8
	for position + 12 <= len(png) {
		length_u32, valid := png_u32_be(png, position)
		if !valid || u64(length_u32) > u64(len(png)) {
			return nil, nil, false
		}
		length := int(length_u32)
		data_start := position + 8
		data_end := data_start + length
		if data_end + 4 > len(png) {
			return nil, nil, false
		}
		chunk_type := string(png[position + 4:position + 8])
		data := png[data_start:data_end]
		if chunk_type == "tEXt" && len(data) >= 8 && string(data[:8]) == "Comment\x00" {
			return data[8:], nil, true
		}
		if chunk_type == "zTXt" && len(data) >= 9 && string(data[:8]) == "Comment\x00" && data[8] == 0 {
			decoded_length: c.int
			decoded := stbi.zlib_decode_malloc_guesssize_headerflag(
				raw_data(data[9:]),
				c.int(len(data) - 9),
				65536,
				&decoded_length,
				true,
			)
			if decoded == nil || decoded_length < 0 {
				return nil, nil, false
			}
			owned = make([]u8, int(decoded_length)) or_else nil
			if owned == nil {
				stbi.image_free(decoded)
				return nil, nil, false
			}
			for index in 0 ..< len(owned) {
				owned[index] = decoded[index]
			}
			stbi.image_free(decoded)
			return owned, owned, true
		}
		position = data_end + 4
	}
	return nil, nil, false
}

@(private = "file")
parse_skin_number :: proc(text: []u8, position: ^int) -> (int, bool) {
	for position^ < len(text) && (text[position^] < '0' || text[position^] > '9') {
		position^ += 1
	}
	if position^ >= len(text) {
		return 0, false
	}
	value := 0
	for position^ < len(text) && text[position^] >= '0' && text[position^] <= '9' {
		value = value * 10 + int(text[position^] - '0')
		position^ += 1
	}
	return value, true
}

@(require_results, tag = "reference:ui_refresh")
refresh :: proc(ctx: ^Context) -> Error {
	if ctx == nil {
		return .Invalid_Input
	}
	ctx.flags += {.Refresh}
	return .None
}

@(require_results, tag = "reference:ui_settxt")
set_texts :: proc(ctx: ^Context, texts: []string) -> Error {
	if ctx == nil || len(texts) == 0 {
		return .Invalid_Input
	}
	ctx.texts = texts
	if ctx.backend.set_title != nil {
		if error := ctx.backend.set_title(ctx.backend.data, texts[0]); error != .None {
			return error
		}
	}
	return refresh(ctx)
}

@(require_results, tag = "reference:ui_getclipboard")
clipboard_text :: proc(ctx: ^Context) -> (string, Error) {
	if ctx == nil || ctx.backend.get_clipboard == nil {
		return "", .Invalid_Input
	}
	return ctx.backend.get_clipboard(ctx.backend.data)
}

@(require_results, tag = "reference:ui_setclipboard")
set_clipboard_text :: proc(ctx: ^Context, text: string) -> Error {
	if ctx == nil || len(text) == 0 || ctx.backend.set_clipboard == nil {
		return .Invalid_Input
	}
	return ctx.backend.set_clipboard(ctx.backend.data, text)
}

@(require_results, tag = "reference:ui_getmouse")
mouse_position :: proc(ctx: ^Context) -> (x, y: int, error: Error) {
	if ctx == nil {
		return 0, 0, .Invalid_Input
	}
	return ctx.mouse_x, ctx.mouse_y, .None
}

@(require_results, tag = "reference:ui_init")
init :: proc(
	ctx: ^Context,
	backend: Backend,
	texts: []string,
	width, height: int,
	icon: ^Image = nil,
) -> Error {
	if ctx == nil || width < 1 || height < 1 || len(texts) == 0 || backend.init == nil {
		return .Invalid_Input
	}
	ctx^ = {}
	ctx.screen.width = width
	ctx.screen.height = height
	ctx.screen.pitch = width * 4
	ctx.screen.pixels = make([]u8, height * ctx.screen.pitch) or_else nil
	if ctx.screen.pixels == nil {
		return .Out_Of_Memory
	}
	if error := text_buffer_init(&ctx.edit_buffer, "", 128); error != .None {
		delete(ctx.screen.pixels)
		ctx^ = {}
		return error
	}
	ctx.backend = backend
	ctx.texts = texts
	ctx.theme = DEFAULT_THEME
	ctx.scrollbar_width = 10
	ctx.scrollbar_height = 10
	ctx.clip_x1 = width
	ctx.clip_y1 = height
	ctx.flags = {.Refresh, .Recalculate}

	if error := ctx.backend.init(ctx.backend.data, ctx, texts[0], width, height, icon);
	   error != .None {
		delete(ctx.screen.pixels)
		text_buffer_deinit(&ctx.edit_buffer)
		ctx^ = {}
		return error
	}
	return .None
}

@(require_results, tag = "reference:ui_fullscreen")
toggle_fullscreen :: proc(ctx: ^Context) -> Error {
	if ctx == nil || ctx.backend.fullscreen == nil {
		return .Invalid_Input
	}
	return ctx.backend.fullscreen(ctx.backend.data)
}

@(require_results, tag = "reference:ui_getwindow")
native_window :: proc(ctx: ^Context) -> (rawptr, Error) {
	if ctx == nil || ctx.backend.native_window == nil {
		return nil, .Invalid_Input
	}
	return ctx.backend.native_window(ctx.backend.data), .None
}

Poll_State :: enum {
	Running,
	Closed,
}

@(require_results, tag = "reference:ui_event")
poll_event :: proc(ctx: ^Context, form: []Form) -> (Event, Poll_State, Error) {
	if ctx == nil || ctx.backend.poll == nil || ctx.backend.redraw == nil {
		return {}, .Closed, .Invalid_Input
	}
	closed, error := ctx.backend.poll(ctx.backend.data)
	if error != .None {
		return {}, .Closed, error
	}
	if closed {
		return {}, .Closed, .None
	}
	ctx.form = form
	if error = render(ctx, form); error != .None {
		return {}, .Running, error
	}
	if error = ctx.backend.redraw(ctx.backend.data); error != .None {
		return {}, .Running, error
	}

	if ctx.event_tail == ctx.event_head {
		update_hover(ctx, form)
		return {}, .Running, .None
	}
	event := ctx.events[ctx.event_tail]
	ctx.event_tail = (ctx.event_tail + 1) % MAX_EVENTS
	if error = process_event(ctx, form, &event); error != .None {
		return event, .Running, error
	}
	return event, .Running, .None
}

@(require_results, tag = "reference:ui_free")
deinit :: proc(ctx: ^Context) -> Error {
	if ctx == nil {
		return .Invalid_Input
	}
	finalize_forms(ctx, ctx.form)
	backend_error := Error.None
	if ctx.backend.deinit != nil {
		backend_error = ctx.backend.deinit(ctx.backend.data)
	}
	if ctx.screen.pixels != nil {
		delete(ctx.screen.pixels)
	}
	if ctx.skin_buffer != nil {
		delete(ctx.skin_buffer)
	}
	text_buffer_deinit(&ctx.edit_buffer)
	ctx^ = {}
	return backend_error
}

@(private = "file")
finalize_forms :: proc(ctx: ^Context, forms: []Form) {
	for &field in forms {
		if field.kind == .End {
			break
		}
		if field.kind == .Custom && field.custom.finalize != nil {
			field.custom.finalize(ctx, &field)
		}
		if len(field.children) > 0 {
			finalize_forms(ctx, field.children)
		}
	}
}

@(require_results)
render :: proc(ctx: ^Context, form: []Form) -> Error {
	if ctx == nil || len(ctx.screen.pixels) == 0 {
		return .Invalid_Input
	}
	ctx.form = form
	// Match reference-c `_ui_redraw`: untouched UI-layer pixels remain
	// transparent so the presentation adapter may supply the window background.
	ctx.clip_x0 = 0
	ctx.clip_y0 = 0
	ctx.clip_x1 = ctx.screen.width
	ctx.clip_y1 = ctx.screen.height
	for &pixel in ctx.screen.pixels {
		pixel = 0
	}
	if _, _, error := layout_forms(ctx, form, 0, 0, ctx.screen.width, ctx.screen.height, 8, 0);
	   error != .None {
		return error
	}
	if error := draw_forms(ctx, form); error != .None {
		return error
	}
	if error := draw_overlay_containers(ctx, form); error != .None {
		return error
	}
	if ctx.popup != nil {
		if ctx.popup.kind == .Select {
			if error := draw_select_popup(ctx, ctx.popup); error != .None {
				return error
			}
		} else if ctx.popup.kind == .Color {
			if error := draw_color_popup(ctx, ctx.popup); error != .None {
				return error
			}
		} else if ctx.popup.kind == .Custom && ctx.popup.custom.view != nil {
			if error := draw_custom_at(
				ctx,
				ctx.popup,
				ctx.popup_x,
				ctx.popup_y,
				ctx.popup_width,
				ctx.popup_height,
			); error != .None {
				return error
			}
		}
	}
	if image_valid(&ctx.software_cursor) {
		cursor := &ctx.software_cursor
		blit_tiled_image(
			ctx,
			ctx.mouse_x - cursor.width / 2,
			ctx.mouse_y - cursor.height / 2,
			cursor.width,
			cursor.height,
			cursor,
			false,
		)
	}
	ctx.flags -= {.Refresh, .Recalculate}
	return .None
}

// Adapter-facing operations. These form the seam between the core module and
// platform adapters; they are not intended for application-level UI code.
@(require_results, tag = "reference:_ui_evtslot")
push_event :: proc(ctx: ^Context, event: Event) -> Error {
	if ctx == nil {
		return .Invalid_Input
	}
	next_head := (ctx.event_head + 1) % MAX_EVENTS
	if next_head == ctx.event_tail {
		return .Event_Queue_Full
	}
	ctx.events[ctx.event_head] = event
	ctx.event_head = next_head
	return .None
}

@(require_results, tag = "reference:_ui_resize")
resize_framebuffer :: proc(ctx: ^Context, width, height: int) -> Error {
	if ctx == nil || width < 1 || height < 1 {
		return .Invalid_Input
	}
	pixels := make([]u8, width * height * 4) or_else nil
	if pixels == nil {
		return .Out_Of_Memory
	}
	if ctx.screen.pixels != nil {
		delete(ctx.screen.pixels)
	}
	ctx.screen = Image {
		width  = width,
		height = height,
		pitch  = width * 4,
		pixels = pixels,
	}
	ctx.flags += {.Refresh, .Recalculate}
	return .None
}

@(private = "file")
resolve_position :: proc(position: Position, extent: int) -> int {
	switch position.mode {
	case .Percent, .Percent_Plus:
		return extent * int(position.value) / 100 + int(position.offset)
	case .Absolute_From_End:
		// UI_ABS_RIGHT/UI_ABS_BOTTOM leave the packed percentage bits set;
		// preserve the reference implementation's resulting 127%-minus-inset anchor.
		return extent * 127 / 100 - int(position.value) + int(position.offset)
	case .Relative, .Absolute:
		return int(position.value) + int(position.offset)
	}
	return int(position.value)
}

@(private = "file")
layout_forms :: proc(
	ctx: ^Context,
	forms: []Form,
	x, y, width, height, gap, flow_origin: int,
) -> (
	used_width, used_height: int,
	error: Error,
) {
	cursor_x := x
	cursor_y := y
	right_cursor := x + width - 2 + flow_origin
	row_height := 0
	content_right := x
	content_bottom := y
	previous: ^Form

	for &field in forms {
		if field.kind == .End {
			break
		}
		if .Hidden in field.flags {
			continue
		}
		is_overlay := field.kind == .Popup || field.kind == .Menu
		is_flow := field.x.mode == .Relative && field.y.mode == .Relative && !is_overlay
		field_x, field_y: int
		if is_flow {
			field_x = cursor_x + int(field.x.value) + int(field.x.offset)
			if cursor_x != x {
				field_x += flow_origin
			}
			field_y = cursor_y + int(field.y.value) + int(field.y.offset)
		} else {
			field_x = x + resolve_position(field.x, width)
			field_y = y + resolve_position(field.y, height)
		}
		field_width, field_height, measure_error := measure_form(
			ctx,
			&field,
			field_x,
			field_y,
			width,
			height,
		)
		if measure_error != .None {
			return 0, 0, measure_error
		}
		if !is_flow {
			if field.kind == .Menu && previous != nil && previous.kind == .Toggle &&
			   field.x.mode == .Relative && field.x.value == 0 && field.x.offset == 0 &&
			   field.y.mode == .Relative && field.y.value == 0 && field.y.offset == 0 {
				field_x = previous.computed_x
				if .No_Bullet not_in previous.flags {
					field_x += previous.margin + 7
				}
				field_y = previous.computed_y + previous.computed_height
				if field_x + field_width > x + width {
					field_width = max(x + width - field_x, 0)
				}
			}
		}

		switch field.horizontal_alignment {
		case .Center:
			field_x -= field_width / 2
		case .Right:
			field_x -= field_width
		case .Left:
		}
		switch field.vertical_alignment {
		case .Middle:
			field_y -= field_height / 2
		case .Bottom:
			field_y -= field_height
		case .Top:
		}

		right_aligned_flow := false
		if is_flow {
			continues_row := previous != nil && .No_Break in previous.flags
			right_aligned_flow = field.horizontal_alignment == .Right &&
			                     field.x.value == 0 && field.x.offset == 0
			if right_aligned_flow {
				if right_cursor < x + width - 2 {
					right_cursor -= gap
				}
				right_cursor -= field_width
				row_height = max(row_height, field_height)
				if right_cursor < x {
					right_cursor = x + width - field_width - 2 + flow_origin
					if row_height > 0 {
						row_height += gap
					}
					field_y += row_height
					cursor_y += row_height
					row_height = 0
				}
				field_x = right_cursor
			} else {
				if field_x > x {
					field_x += gap
				}
				if (width > 0 && .Force_Break not_in field.flags) || continues_row {
					if !continues_row && field_x + field_width + 2 >= x + width {
						if row_height > 0 {
							row_height += gap
						}
						field_x = x
						field_y += row_height
						cursor_y += row_height
						row_height = 0
					}
					if field.y.mode == .Relative {
						cursor_y += int(field.y.value) + int(field.y.offset)
					}
					row_height = max(row_height, field_height)
					cursor_x = field_x + field_width
				} else {
					row_height = max(row_height, field_height)
					cursor_y += row_height + gap
					cursor_x = x
					row_height = 0
				}
			}
		}

		if is_overlay {
			if field_x + field_width + 1 > ctx.screen.width {
				field_x = ctx.screen.width - field_width - 1
				if field_x < 1 {
					field_x = 1
					field_width = max(ctx.screen.width - 2, 0)
				}
			}
			if field_y + field_height + 1 > ctx.screen.height {
				field_y = ctx.screen.height - field_height - 1
				if field_y < 1 {
					field_y = 1
					field_height = max(ctx.screen.height - 2, 0)
				}
			}
		}
		field.computed_x = field_x
		field.computed_y = field_y
		field.computed_width = field_width
		field.computed_height = field_height

		if field.kind == .Division || field.kind == .Popup || field.kind == .Menu {
			title_height := 0
			if field.kind == .Popup && field.label > 0 && field.label < len(ctx.texts) {
				_, text_height, _, _, label_error := measure_label(ctx, &field)
				if label_error != .None {
					return 0, 0, label_error
				}
				title_height = text_height + 2
			}
			if field.kind == .Popup && .Draggable in field.flags {
				title_height = max(title_height, 11)
			}
			inner_x := field_x + field.margin
			inner_y := field_y + field.margin
			inner_width := max(field_width - 2 * field.margin, 0)
			inner_height := max(field_height - 2 * field.margin, 0)
			if field.kind != .Division {
				border_offset := 0
				if .No_Border not_in field.flags {
					border_offset = 1
				}
				inner_x += border_offset + 2
				inner_y += border_offset + title_height + 2
				inner_width = max(inner_width - 4, 0)
				inner_height = max(inner_height - title_height - 4, 0)
			}
			field.source_width = 0
			field.source_height = 0
			if field.kind == .Popup {
				has_horizontal := .Horizontal_Scroll in field.flags && field.minimum_width > inner_width
				if has_horizontal {
					inner_height = max(inner_height - ctx.scrollbar_height, 0)
				}
				has_vertical := .Vertical_Scroll in field.flags && field.minimum_height > inner_height
				if has_vertical {
					inner_width = max(inner_width - ctx.scrollbar_width, 0)
				}
				if !has_horizontal && .Horizontal_Scroll in field.flags && field.minimum_width > inner_width {
					has_horizontal = true
					inner_height = max(inner_height - ctx.scrollbar_height, 0)
				}
				if has_horizontal {
					field.source_width = inner_width
					field.offset_x = clamp(field.offset_x, 0, max(field.minimum_width - inner_width, 0))
				} else {
					field.offset_x = 0
				}
				if has_vertical {
					field.source_height = inner_height
					field.offset_y = clamp(field.offset_y, 0, max(field.minimum_height - inner_height, 0))
				} else {
					field.offset_y = 0
				}
			}
			field.content_x = inner_x
			field.content_y = inner_y
			field.content_width = inner_width
			field.content_height = inner_height
			if _, _, child_error := layout_forms(
				ctx,
				field.children,
				inner_x - field.offset_x,
				inner_y - field.offset_y,
				inner_width,
				inner_height,
				field.pitch,
				2,
			); child_error != .None {
				return 0, 0, child_error
			}
		}

		if !right_aligned_flow {
			content_right = max(content_right, field_x + field_width)
			content_bottom = max(content_bottom, field_y + field_height)
		}
		previous = &field
	}
	return content_right - x, content_bottom - y, .None
}

@(private = "file")
measure_form :: proc(
	ctx: ^Context,
	field: ^Form,
	x, y: int,
	available_width, available_height: int,
) -> (
	int,
	int,
	Error,
) {
	width := field.width
	height := field.height
	if field.width_percentage != 0 {
		width += available_width * field.width_percentage / 100
	}
	if field.height_percentage != 0 {
		height += available_height * field.height_percentage / 100
	}
	#partial switch field.kind {
	case .Label:
		text_width, text_height, _, _, error := measure_label(ctx, field)
		if error != .None {
			return 0, 0, error
		}
		if width < 1 {
			width = text_width
		}
		if height < 1 {
			height = text_height + 4
		}
	case .Multiline_Label:
		text, valid := multiline_form_text(ctx, field)
		if !valid || ctx.font == nil || ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		if error := ensure_default_font_metrics(ctx); error != .None {
			return 0, 0, error
		}
		lines := strings.split(text, "\n")
		defer delete(lines)
		if len(lines) > 0 && lines[len(lines) - 1] == "" {
			lines = lines[:len(lines) - 1]
		}
		text_width, text_height := 0, 0
		for line in lines {
			line_width, _, line_left, line_top: int
			if bounds_error := ctx.font_bounds(
				ctx.font,
				line,
				&line_width,
				&text_height,
				&line_left,
				&line_top,
			); bounds_error != .None {
				return 0, 0, bounds_error
			}
			text_width = max(text_width, line_width)
			field.left = max(field.left, line_left)
		}
		if width < 1 {
			width = text_width
		}
		if height < 1 {
			height = max(len(lines) * ctx.default_size, 9)
		}
		field.top = ctx.default_top
	case .Status:
		if error := ensure_default_font_metrics(ctx); error != .None {
			return 0, 0, error
		}
		field.top = ctx.default_top
		if height < 1 {
			height = max(ctx.default_size + 4, 9)
		}
	case .Image:
		if image_valid(field.icon) {
			if width < 1 {
				width = field.icon.width
			}
			if height < 1 {
				height = field.icon.height
			}
		}
	case .Icon:
		// UI_ICON has no intrinsic size; its explicit box controls scaling.
	case .Color:
		if field.binding.kind != .Color || field.binding.data == nil ||
		   ctx.font == nil || ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		text_width, text_height, left, top: int
		if bounds_error := ctx.font_bounds(
			ctx.font,
			"FFFFFFFF",
			&text_width,
			&text_height,
			&left,
			&top,
		); bounds_error != .None {
			return 0, 0, bounds_error
		}
		field.left = left
		field.top = top
		intrinsic_height := text_height + 4
		if width < 1 {
			width = text_width + intrinsic_height
		}
		if height < 1 {
			height = intrinsic_height
		}
	case .Toggle:
		text_width, text_height, left, top, error := measure_label(ctx, field)
		if error != .None {
			return 0, 0, error
		}
		field.left = left
		field.top = top
		if height < 1 {
			height = max(text_height + 4, 9)
		}
		if width < 1 {
			width = text_width + 9
			if .No_Bullet in field.flags {
				width = text_width + 2 * field.margin
			}
		}
	case .Button, .Toggle_Button:
		text_width, text_height := 0, 0
		has_text := field.label > 0 && field.label < len(ctx.texts)
		if has_text {
			if ctx.font == nil || ctx.font_bounds == nil {
				return 0, 0, .Invalid_Input
			}
			if bounds_error := ctx.font_bounds(
				ctx.font,
				ctx.texts[field.label],
				&text_width,
				&text_height,
				&field.left,
				&field.top,
			); bounds_error != .None {
				return 0, 0, bounds_error
			}
		}
		if image_valid(field.icon) {
			if has_text {
				text_width += 4
			}
			text_width += field.icon.width
			text_height = max(text_height, field.icon.height)
		}
		width = max(width, text_width + 8 + int(field.minimum))
		height = max(height, text_height + 4)
	case .Icon_Button:
		if image_valid(field.icon) {
			width = max(width, field.icon.width)
			height = max(height, field.icon.height)
		}
	case .Checkbox, .Radio:
		text_width, text_height, _, _, error := measure_label(ctx, field)
		if error != .None {
			return 0, 0, error
		}
		if height < 1 {
			height = max(text_height + 4, 11)
		}
		if width < 1 {
			width = text_width + height
			if .No_Bullet in field.flags {
				width = text_width + 8
			}
		}
	case .Text_Input:
		if field.binding.kind != .Text ||
		   field.binding.data == nil ||
		   ctx.font == nil ||
		   ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		buffer := (^Text_Buffer)(field.binding.data)
		text := text_buffer_string(buffer)
		text_width, text_height, left, top: int
		if bounds_error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
		   bounds_error != .None {
			return 0, 0, bounds_error
		}
		field.left = left
		field.top = top
		if width < 1 {
			width = text_width
		}
		if height < 1 {
			height = text_height + 4
		}
	case .Select, .Option:
		if field.binding.kind != .Integer ||
		   field.binding.data == nil ||
		   len(field.options) == 0 ||
		   ctx.font == nil ||
		   ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		text_width, text_height, left, top := 0, 0, 0, 0
		for option in field.options {
			option_width, option_height, option_left, option_top: int
			if bounds_error := ctx.font_bounds(
				ctx.font,
				option,
				&option_width,
				&option_height,
				&option_left,
				&option_top,
			); bounds_error != .None {
				return 0, 0, bounds_error
			}
			text_width = max(text_width, option_width)
			text_height = max(text_height, option_height)
			left = max(left, option_left)
			top = max(top, option_top)
		}
		field.left = left
		field.top = top
		if height < 1 {
			height = text_height + 4
		}
		if width < 1 {
			button_count := 1
			if field.kind == .Option {
				button_count = 2
			}
			width = text_width + height * button_count + 4
		}
	case .Integer_8, .Integer_16, .Integer_32, .Integer_64, .Float_Input:
		if field.binding.data == nil || ctx.font == nil || ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		placeholder := "0"
		if field.kind == .Float_Input {
			magnitude := field.float_maximum
			if -field.float_minimum > field.float_maximum {
				magnitude = field.float_minimum
			}
			placeholder = fmt.tprintf("%g.000", magnitude)
		} else {
			magnitude := field.maximum
			if -field.minimum > field.maximum {
				magnitude = field.minimum
			}
			placeholder = fmt.tprintf("%d", magnitude)
		}
		text_width, text_height, left, top: int
		if bounds_error := ctx.font_bounds(
			ctx.font,
			placeholder,
			&text_width,
			&text_height,
			&left,
			&top,
		); bounds_error != .None {
			return 0, 0, bounds_error
		}
		field.left = left
		field.top = top
		intrinsic_height := text_height + 4
		if width < 1 {
			width = text_width + 4 + 2 * intrinsic_height
		}
		if height < 1 {
			height = intrinsic_height
		}
	case .Slider, .Progress_Bar:
		if width < 1 {
			width = min(max(available_width, 100), 180)
		}
		if height < 1 {
			height = 20
		}
	case .Vertical_Scrollbar:
		width = ctx.scrollbar_width
		height = max(height, ctx.scrollbar_height)
	case .Horizontal_Scrollbar:
		width = max(width, ctx.scrollbar_width)
		height = ctx.scrollbar_height
	case .Decimal_8,
	     .Decimal_16,
	     .Decimal_32,
	     .Decimal_64,
	     .Hexadecimal_8,
	     .Hexadecimal_16,
	     .Hexadecimal_32,
	     .Hexadecimal_64,
	     .Decimal_Float:
		if field.binding.data == nil || ctx.font == nil || ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		text_width, text_height, left, top: int
		if bounds_error := ctx.font_bounds(
			ctx.font,
			"0.000",
			&text_width,
			&text_height,
			&left,
			&top,
		); bounds_error != .None {
			return 0, 0, bounds_error
		}
		field.left = left
		field.top = top
		if width < 1 {
			width = text_width
		}
		if height < 1 {
			height = text_height + 4
		}
	case .Custom:
		if field.custom.bounds != nil {
			desired_width, desired_height := 0, 0
			if bounds_error := field.custom.bounds(
				ctx,
				x,
				y,
				width,
				height,
				field,
				&desired_width,
				&desired_height,
			); bounds_error != .None {
				return 0, 0, bounds_error
			}
			width = max(width, desired_width)
			height = max(height, desired_height)
		}
	case .Popup, .Menu:
		content_available_width := 4
		content_available_height := 4
		if width > 0 {
			content_available_width = max(width - 2 * field.margin + 4, 0)
		}
		if height > 0 {
			content_available_height = max(height - 2 * field.margin + 4, 0)
		}
		content_width, content_height, content_error := measure_container_content(
			ctx,
			field.children,
			content_available_width,
			content_available_height,
			field.pitch,
		)
		if content_error != .None {
			return 0, 0, content_error
		}
		field.minimum_width = content_width
		field.minimum_height = content_height
		title_height := 0
		if field.kind == .Popup && field.label > 0 && field.label < len(ctx.texts) {
			title_width, text_height, title_left, title_top, label_error := measure_label(ctx, field)
			if label_error != .None {
				return 0, 0, label_error
			}
			field.left = title_left
			field.top = title_top
			content_width = max(content_width, title_width)
			title_height = text_height + 2
		}
		if .Draggable in field.flags {
			title_height = max(title_height, 11)
		}
		if width < 1 {
			width = max(content_width + 2 * field.margin + 2, 16)
		}
		if height < 1 {
			height = max(content_height + 2 * field.margin + title_height + 2, 16)
		}
	case .Division:
		content_available_width := 4
		content_available_height := 4
		if width > 0 {
			content_available_width = max(width - 2 * field.margin + 4, 0)
		}
		if height > 0 {
			content_available_height = max(height - 2 * field.margin + 4, 0)
		}
		content_width, content_height, content_error := measure_container_content(
			ctx,
			field.children,
			content_available_width,
			content_available_height,
			field.pitch,
		)
		if content_error != .None {
			return 0, 0, content_error
		}
		field.minimum_width = content_width
		field.minimum_height = content_height
		width = max(width, content_width + 2 * field.margin + 4)
		height = max(height, content_height + 2 * field.margin + 4)
	}
	return max(width, 0), max(height, 0), .None
}

@(private = "file")
measure_container_content :: proc(
	ctx: ^Context,
	children: []Form,
	available_width, available_height, gap: int,
) -> (
	width, height: int,
	error: Error,
) {
	return layout_forms(ctx, children, 0, 0, available_width, available_height, gap, 2)
}

@(private = "file")
form_text :: proc(ctx: ^Context, field: ^Form) -> (string, bool) {
	if field != nil && len(field.text) > 0 {
		return field.text, true
	}
	if ctx != nil && field != nil && field.label >= 0 && field.label < len(ctx.texts) {
		return ctx.texts[field.label], true
	}
	return "", false
}

@(private = "file")
multiline_form_text :: proc(ctx: ^Context, field: ^Form) -> (string, bool) {
	if ctx != nil && field != nil && field.label > 0 && field.label < len(ctx.texts) {
		return ctx.texts[field.label], true
	}
	if field != nil && len(field.text) > 0 {
		return field.text, true
	}
	return "", false
}

@(private = "file")
ensure_default_font_metrics :: proc(ctx: ^Context) -> Error {
	if ctx == nil || ctx.font == nil || ctx.font_bounds == nil {
		return .Invalid_Input
	}
	if ctx.default_size > 0 {
		return .None
	}
	width, left: int
	return ctx.font_bounds(
		ctx.font,
		"Ag",
		&width,
		&ctx.default_size,
		&left,
		&ctx.default_top,
	)
}

@(private = "file")
measure_label :: proc(
	ctx: ^Context,
	field: ^Form,
) -> (
	width, height, left, top: int,
	error: Error,
) {
	text, valid := form_text(ctx, field)
	if !valid || ctx.font == nil || ctx.font_bounds == nil {
		return 0, 0, 0, 0, .Invalid_Input
	}
	error = ctx.font_bounds(ctx.font, text, &width, &height, &left, &top)
	return
}

@(private = "file")
draw_overlay_containers :: proc(ctx: ^Context, forms: []Form) -> Error {
	for &field in forms {
		if field.kind == .End {
			break
		}
		if field.kind != .Popup || .Hidden in field.flags {
			continue
		}
		if error := draw_container(ctx, &field); error != .None {
			return error
		}
	}
	if ctx.menu != nil && .Hidden not_in ctx.menu.flags {
		if error := draw_container(ctx, ctx.menu); error != .None {
			return error
		}
	}
	return .None
}

@(private = "file")
draw_container :: proc(ctx: ^Context, field: ^Form) -> Error {
	x, y := field.computed_x, field.computed_y
	width, height := field.computed_width, field.computed_height
	if width < 1 || height < 1 || x >= ctx.screen.width || y >= ctx.screen.height {
		return .Invalid_Input
	}
	background := ctx.theme[int(Theme_Color.Background)]
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	shadow := ctx.theme[int(Theme_Color.Shadow)]
	bordered := field.kind != .Division && .No_Border not_in field.flags
	if bordered {
		draw_outline_rectangle(ctx, x, y, width, height, light, background, dark)
		if .No_Shadow not_in field.flags {
			shadow_right_x := x + width
			fill_rectangle(
				ctx,
				shadow_right_x,
				y + 4,
				min(4, max(ctx.screen.width - 1 - shadow_right_x, 0)),
				height - 4,
				shadow,
			)
			shadow_bottom_y := y + height
			fill_rectangle(
				ctx,
				x + 4,
				shadow_bottom_y,
				min(width, max(ctx.screen.width - 1 - (x + 4), 0)),
				min(4, max(ctx.screen.height - 1 - shadow_bottom_y, 0)),
				shadow,
			)
		}
		x += 1
		y += 1
		width -= 2
		height -= 2
	}
	if field.kind != .Division {
		fill_rectangle(ctx, x, y, width, height, background)
	}
	title_height := 0
	if field.kind == .Popup {
		has_title := field.label > 0 && field.label < len(ctx.texts)
		if has_title {
			_, text_height, _, _, error := measure_label(ctx, field)
			if error != .None {
				return error
			}
			title_height = text_height + 2
		}
		if .Draggable in field.flags {
			title_height = max(title_height, 11)
			fill_rectangle(
				ctx,
				x + 1,
				y + 1,
				width - 12,
				title_height - 2,
				ctx.theme[int(Theme_Color.Title)],
			)
			draw_popup_close(ctx, x + width - 5, y + (title_height + 1) / 2)
		}
		if has_title {
			text_color := ctx.theme[int(Theme_Color.Title)]
			if .Draggable in field.flags {
				text_color = background
			}
			return_error := draw_font(ctx,
				ctx.font,
				ctx.texts[field.label],
				ctx.screen.pixels,
				text_color,
				x + 2 - field.left,
				y + 1,
				field.left,
				field.top,
				ctx.screen.pitch,
				x,
				y,
				min(x + width + 1 - 16, ctx.screen.width),
				min(y + height + 1, ctx.screen.height),
			)
			if return_error != .None {
				return return_error
			}
		}
		if .Resizable in field.flags {
			draw_resize_corner(ctx, x + width - 7, y + height - 7, light)
		}
	}
	if field.kind == .Popup {
		draw_container_scrollbars(ctx, field)
	}
	if field.kind != .Popup || (field.source_width == 0 && field.source_height == 0) {
		return draw_forms(ctx, field.children)
	}
	old_x0, old_y0 := ctx.clip_x0, ctx.clip_y0
	old_x1, old_y1 := ctx.clip_x1, ctx.clip_y1
	ctx.clip_x0 = max(ctx.clip_x0, field.content_x)
	ctx.clip_y0 = max(ctx.clip_y0, field.content_y)
	ctx.clip_x1 = min(ctx.clip_x1, field.content_x + field.content_width)
	ctx.clip_y1 = min(ctx.clip_y1, field.content_y + field.content_height)
	error := draw_forms(ctx, field.children)
	ctx.clip_x0, ctx.clip_y0 = old_x0, old_y0
	ctx.clip_x1, ctx.clip_y1 = old_x1, old_y1
	return error
}

@(private = "file")
draw_container_scrollbars :: proc(ctx: ^Context, field: ^Form) {
	if field.source_width > 0 {
		value := field.offset_x
		flags: Form_Flags
		if ctx.horizontal_bar == field {
			flags += {.Selected}
		}
		bar := Form {
			kind = .Horizontal_Scrollbar,
			flags = flags,
			computed_x = field.content_x,
			computed_y = field.content_y + field.content_height,
			computed_width = field.source_width,
			computed_height = ctx.scrollbar_height,
			binding = bind(&value),
			maximum = i64(field.minimum_width),
		}
		draw_scrollbar(ctx, &bar)
	}
	if field.source_height > 0 {
		value := field.offset_y
		flags: Form_Flags
		if ctx.vertical_bar == field {
			flags += {.Selected}
		}
		bar := Form {
			kind = .Vertical_Scrollbar,
			flags = flags,
			computed_x = field.content_x + field.content_width,
			computed_y = field.content_y,
			computed_width = ctx.scrollbar_width,
			computed_height = field.source_height,
			binding = bind(&value),
			maximum = i64(field.minimum_height),
		}
		draw_scrollbar(ctx, &bar)
	}
}

@(private = "file")
draw_popup_close :: proc(ctx: ^Context, x, y: int) {
	title := ctx.theme[int(Theme_Color.Title)]
	background := ctx.theme[int(Theme_Color.Background)]
	draw_outline_rectangle(ctx, x - 5, y - 5, 9, 9, title, title, title)
	fill_rectangle(ctx, x - 4, y - 4, 7, 7, title)
	for offset in 0 ..< 5 {
		set_pixel(ctx, x - 3 + offset, y - 3 + offset, background)
		set_pixel(ctx, x + 1 - offset, y - 3 + offset, background)
	}
}

@(private = "file")
draw_resize_corner :: proc(ctx: ^Context, x, y: int, color: u32) {
	for row in 0 ..< 5 {
		for column in (6 - row) ..= 6 {
			set_pixel(ctx, x + column, y + row + 2, color)
		}
	}
}

@(private = "file")
draw_forms :: proc(ctx: ^Context, forms: []Form) -> Error {
	for &field in forms {
		if field.kind == .End {
			break
		}
		if .Hidden in field.flags {
			continue
		}
		#partial switch field.kind {
		case .Division:
			if error := draw_container(ctx, &field); error != .None {
				return error
			}
		case .Toggle:
			if error := draw_toggle(ctx, &field); error != .None {
				return error
			}
		case .Label:
			if error := draw_label(ctx, &field); error != .None {
				return error
			}
		case .Multiline_Label:
			if error := draw_multiline_label(ctx, &field); error != .None {
				return error
			}
		case .Status:
			if error := draw_status(ctx, &field); error != .None {
				return error
			}
		case .Image:
			draw_image(ctx, &field)
		case .Icon:
			draw_icon(ctx, &field)
		case .Color:
			if error := draw_color_input(ctx, &field); error != .None {
				return error
			}
		case .Button, .Toggle_Button:
			if error := draw_button(ctx, &field); error != .None {
				return error
			}
		case .Icon_Button:
			draw_icon_button(ctx, &field)
		case .Lines, .Vertical_Connector, .Horizontal_Connector, .Curve:
			draw_line_field(ctx, &field)
		case .Checkbox, .Radio:
			if error := draw_choice(ctx, &field); error != .None {
				return error
			}
		case .Text_Input:
			if error := draw_text_input(ctx, &field); error != .None {
				return error
			}
		case .Select, .Option:
			if error := draw_choice_input(ctx, &field); error != .None {
				return error
			}
		case .Integer_8, .Integer_16, .Integer_32, .Integer_64, .Float_Input:
			if error := draw_numeric_input(ctx, &field); error != .None {
				return error
			}
		case .Slider:
			draw_slider(ctx, &field)
		case .Vertical_Scrollbar, .Horizontal_Scrollbar:
			draw_scrollbar(ctx, &field)
		case .Progress_Bar:
			if error := draw_progress_bar(ctx, &field); error != .None {
				return error
			}
		case .Custom:
			if error := draw_custom(ctx, &field); error != .None {
				return error
			}
		case .Decimal_8,
		     .Decimal_16,
		     .Decimal_32,
		     .Decimal_64,
		     .Hexadecimal_8,
		     .Hexadecimal_16,
		     .Hexadecimal_32,
		     .Hexadecimal_64,
		     .Decimal_Float:
			if error := draw_bound_value(ctx, &field); error != .None {
				return error
			}
		}
	}
	return .None
}

@(private = "file")
draw_custom :: proc(ctx: ^Context, field: ^Form) -> Error {
	return draw_custom_at(
		ctx,
		field,
		field.computed_x,
		field.computed_y,
		field.computed_width,
		field.computed_height,
	)
}

@(private = "file")
draw_custom_at :: proc(ctx: ^Context, field: ^Form, x, y, width, height: int) -> Error {
	if field.custom.view == nil {
		return .None
	}
	old_x0, old_y0 := ctx.clip_x0, ctx.clip_y0
	old_x1, old_y1 := ctx.clip_x1, ctx.clip_y1
	ctx.clip_x0 = max(ctx.clip_x0, x)
	ctx.clip_y0 = max(ctx.clip_y0, y)
	ctx.clip_x1 = min(ctx.clip_x1, x + width)
	ctx.clip_y1 = min(ctx.clip_y1, y + height)
	error := field.custom.view(ctx, x, y, width, height, field)
	ctx.clip_x0, ctx.clip_y0 = old_x0, old_y0
	ctx.clip_x1, ctx.clip_y1 = old_x1, old_y1
	return error
}

@(private = "file")
draw_toggle :: proc(ctx: ^Context, field: ^Form) -> Error {
	if field.label <= 0 || field.label >= len(ctx.texts) || ctx.font_draw == nil {
		return .Invalid_Input
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if .Disabled in field.flags {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	open := false
	if field.binding.kind == .Forms && field.binding.data != nil {
		target := (^Form)(field.binding.data)
		open = .Hidden not_in target.flags
	}
	x := field.computed_x
	if .No_Bullet in field.flags {
		if open {
			foreground = ctx.theme[int(Theme_Color.Toggle_Foreground)]
			fill_rectangle(
				ctx,
				field.computed_x,
				field.computed_y,
				field.computed_width,
				field.computed_height,
				ctx.theme[int(Theme_Color.Toggle_Background)],
			)
		}
		x += field.margin
	} else {
		middle_y := field.computed_y + (field.computed_height - 5) / 2
		if open {
			draw_toggle_triangle(ctx, x + 1, middle_y, false, foreground)
		} else {
			draw_toggle_triangle(ctx, x + 2, middle_y - 2, true, foreground)
		}
		x += 9
	}
	return draw_font(ctx,
		ctx.font,
		ctx.texts[field.label],
		ctx.screen.pixels,
		foreground,
		x - field.left,
		field.computed_y + 2,
		field.left,
		field.top,
		ctx.screen.pitch,
		0,
		0,
		ctx.screen.width,
		ctx.screen.height,
	)
}

@(private = "file")
draw_toggle_triangle :: proc(ctx: ^Context, x, y: int, right: bool, color: u32) {
	if right {
		lengths := [7]int{2, 3, 4, 5, 4, 3, 2}
		for row in 0 ..< 7 {
			for column in 0 ..< lengths[row] {
				set_pixel(ctx, x + column, y + row, color)
			}
		}
		return
	}
	for column in 0 ..< 7 {
		set_pixel(ctx, x + column, y, color)
		set_pixel(ctx, x + column, y + 1, color)
	}
	for row in 2 ..< 5 {
		for column in (row - 1) ..< 8 - row {
			set_pixel(ctx, x + column, y + row, color)
		}
	}
}

@(private = "file")
draw_label :: proc(ctx: ^Context, field: ^Form) -> Error {
	text, valid := form_text(ctx, field)
	if !valid || ctx.font == nil || ctx.font_bounds == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	_, _, left, top, error := measure_label(ctx, field)
	if error != .None {
		return error
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if .Disabled in field.flags {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	} else if ctx.menu != nil && ctx.hovered == field {
		fill_rectangle(
			ctx,
			ctx.menu.computed_x + 1,
			field.computed_y,
			ctx.menu.computed_width - 2,
			field.computed_height,
			ctx.theme[int(Theme_Color.Highlight_Background)],
		)
		foreground = ctx.theme[int(Theme_Color.Highlight_Foreground)]
	}
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		field.computed_x,
		field.computed_y + 2,
		left,
		top,
		ctx.screen.pitch,
		0,
		0,
		ctx.screen.width,
		ctx.screen.height,
	)
}

@(private = "file")
draw_multiline_label :: proc(ctx: ^Context, field: ^Form) -> Error {
	text, valid := multiline_form_text(ctx, field)
	if !valid || ctx.font == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	if field.background != 0 && .Disabled not_in field.flags {
		fill_rectangle(
			ctx,
			field.computed_x,
			field.computed_y,
			field.computed_width,
			field.computed_height,
			field.background,
		)
	}
	foreground := field.foreground
	if foreground == 0 {
		foreground = ctx.theme[int(Theme_Color.Foreground)]
	}
	if .Disabled in field.flags {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	y := field.computed_y
	lines := strings.split(text, "\n")
	defer delete(lines)
	if len(lines) > 0 && lines[len(lines) - 1] == "" {
		lines = lines[:len(lines) - 1]
	}
	for line in lines {
		if y >= field.computed_y + field.computed_height {
			break
		}
		if error := draw_font(ctx,
			ctx.font,
			line,
			ctx.screen.pixels,
			foreground,
			field.computed_x - field.left,
			y + 2,
			field.left,
			field.top,
			ctx.screen.pitch,
			field.computed_x,
			field.computed_y,
			min(field.computed_x + field.computed_width, ctx.screen.width),
			min(field.computed_y + field.computed_height, ctx.screen.height),
		); error != .None {
			return error
		}
		y += ctx.default_size
	}
	return .None
}

@(private = "file")
draw_status :: proc(ctx: ^Context, field: ^Form) -> Error {
	if ctx.font == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	fill_rectangle(
		ctx,
		field.computed_x,
		field.computed_y,
		field.computed_width,
		field.computed_height,
		ctx.theme[int(Theme_Color.Input_Background)],
	)
	text, valid := "", false
	if ctx.hovered != nil && ctx.hovered.description > 0 &&
	   ctx.hovered.description < len(ctx.texts) {
		text, valid = ctx.texts[ctx.hovered.description], true
	} else if len(field.text) > 0 {
		text, valid = field.text, true
	}
	if !valid {
		return .None
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if .Disabled in field.flags {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		field.computed_x - field.left,
		field.computed_y + 2,
		field.left,
		field.top,
		ctx.screen.pitch,
		field.computed_x,
		field.computed_y,
		min(field.computed_x + field.computed_width, ctx.screen.width),
		min(field.computed_y + field.computed_height, ctx.screen.height),
	)
}

@(private = "file")
image_valid :: proc(image: ^Image) -> bool {
	return image != nil &&
	       image.width > 0 &&
	       image.height > 0 &&
	       image.pitch >= image.width * 4 &&
	       len(image.pixels) >= (image.height - 1) * image.pitch + image.width * 4
}

@(private = "file")
blend_image_pixel :: proc(ctx: ^Context, x, y: int, image: ^Image, source_x, source_y: int, grayscale: bool) {
	if !image_valid(image) ||
	   x < 0 || y < 0 || x >= ctx.screen.width || y >= ctx.screen.height ||
	   source_x < 0 || source_y < 0 || source_x >= image.width || source_y >= image.height {
		return
	}
	source := source_y * image.pitch + source_x * 4
	blue := u32(image.pixels[source])
	green := u32(image.pixels[source + 1])
	red := u32(image.pixels[source + 2])
	alpha := u32(image.pixels[source + 3])
	if grayscale {
		gray := (red + green + blue) >> 3
		red, green, blue = gray, gray, gray
	}
	blend_pixel(ctx, x, y, blue | green << 8 | red << 16 | alpha << 24)
}

@(private = "file")
blit_tiled_image :: proc(ctx: ^Context, x, y, width, height: int, image: ^Image, grayscale: bool) {
	if !image_valid(image) || width < 1 || height < 1 {
		return
	}
	x0 := clamp(x, 0, ctx.screen.width)
	y0 := clamp(y, 0, ctx.screen.height)
	x1 := clamp(x + width, 0, ctx.screen.width)
	y1 := clamp(y + height, 0, ctx.screen.height)
	for destination_y in y0 ..< y1 {
		for destination_x in x0 ..< x1 {
			blend_image_pixel(
				ctx,
				destination_x,
				destination_y,
				image,
				(destination_x - x) % image.width,
				(destination_y - y) % image.height,
				grayscale,
			)
		}
	}
}

@(private = "file")
draw_image :: proc(ctx: ^Context, field: ^Form) {
	blit_tiled_image(
		ctx,
		field.computed_x,
		field.computed_y,
		field.computed_width,
		field.computed_height,
		field.icon,
		.Disabled in field.flags,
	)
}

@(private = "file")
interpolate_channel :: proc(a, b: int, fraction: int) -> int {
	return a + ((b - a) * fraction >> 16)
}

@(private = "file")
sample_scaled_channel :: proc(
	image: ^Image,
	x0, y0, x1, y1, fraction_x, fraction_y, channel: int,
) -> u8 {
	c00 := int(image.pixels[y0 * image.pitch + x0 * 4 + channel])
	c01 := int(image.pixels[y0 * image.pitch + x1 * 4 + channel])
	c10 := int(image.pixels[y1 * image.pitch + x0 * 4 + channel])
	c11 := int(image.pixels[y1 * image.pitch + x1 * 4 + channel])
	top := interpolate_channel(c00, c01, fraction_x)
	bottom := interpolate_channel(c10, c11, fraction_x)
	result := interpolate_channel(top, bottom, fraction_y)
	if channel == 3 && result == 254 {
		result = 255
	}
	return u8(clamp(result, 0, 255))
}

@(private = "file")
draw_icon :: proc(ctx: ^Context, field: ^Form) {
	image := field.icon
	if !image_valid(image) || field.computed_width < 2 || field.computed_height < 2 {
		return
	}
	width := field.computed_width
	height := image.height * width / image.width
	if height > field.computed_height {
		height = field.computed_height
		width = image.width * height / image.height
	}
	if width < 2 || height < 2 || width >= 4096 || height >= 4096 {
		return
	}
	x := field.computed_x + (field.computed_width - width) / 2
	y := field.computed_y + (field.computed_height - height) / 2
	for destination_y in 0 ..< height - 1 {
		pixel_y := y + destination_y
		if pixel_y < 0 || pixel_y >= ctx.screen.height {
			continue
		}
		source_y_fixed := destination_y * 65536 * image.height / height
		source_y := min(source_y_fixed >> 16, image.height - 1)
		next_source_y := min(source_y + 1, image.height - 1)
		fraction_y := source_y_fixed & 0xffff
		for destination_x in 0 ..< width - 1 {
			pixel_x := x + destination_x
			if pixel_x < 0 || pixel_x >= ctx.screen.width {
				continue
			}
			source_x_fixed := destination_x * 65536 * image.width / width
			source_x := min(source_x_fixed >> 16, image.width - 1)
			next_source_x := min(source_x + 1, image.width - 1)
			fraction_x := source_x_fixed & 0xffff
			channels: [4]u8
			for channel in 0 ..< 4 {
				channels[channel] = sample_scaled_channel(
					image,
					source_x,
					source_y,
					next_source_x,
					next_source_y,
					fraction_x,
					fraction_y,
					channel,
				)
			}
			blue, green, red := u32(channels[0]), u32(channels[1]), u32(channels[2])
			alpha := u32(channels[3])
			if .Disabled in field.flags {
				gray := (red + green + blue) >> 3
				red, green, blue = gray, gray, gray
			}
			blend_pixel(ctx, pixel_x, pixel_y, blue | green << 8 | red << 16 | alpha << 24)
		}
	}
}

@(private = "file")
draw_checker :: proc(ctx: ^Context, x, y, width, height: int, color: u32) {
	if width < 1 || height < 1 {
		return
	}
	cell := min(width, height) / 2
	if cell < 1 {
		cell = 1
	}
	alpha := u32(u8(color >> 24))
	inverse := 255 - alpha
	blue := u32(u8(color)) * alpha
	green := u32(u8(color >> 8)) * alpha
	red := u32(u8(color >> 16)) * alpha
	for row in 0 ..< height {
		for column in 0 ..< width {
			shade: u32 = 0x5f
			if ((row / cell) & 1) != ((column / cell) & 1) {
				shade = 0x9f
			}
			set_pixel(
				ctx,
				x + column,
				y + row,
				u32(0xff000000) |
					((blue + inverse * shade) >> 8) |
					((green + inverse * shade) >> 8) << 8 |
					((red + inverse * shade) >> 8) << 16,
			)
		}
	}
}

@(private = "file")
bound_color :: proc(field: ^Form) -> (^u32, bool) {
	if field == nil || field.binding.kind != .Color || field.binding.data == nil {
		return nil, false
	}
	return (^u32)(field.binding.data), true
}

@(private = "file")
draw_color_input :: proc(ctx: ^Context, field: ^Form) -> Error {
	value, valid := bound_color(field)
	if !valid || ctx.font == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	x, y := field.computed_x, field.computed_y
	width, height := field.computed_width, field.computed_height
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	background := ctx.theme[int(Theme_Color.Input_Background)]
	foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	if .Selected in field.flags {
		dark = ctx.theme[int(Theme_Color.Button_Selected_Border)]
		light = dark
	}
	if .Disabled in field.flags {
		dark = ctx.theme[int(Theme_Color.Disabled_Background)]
		light = dark
		background = dark
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	if .No_Border not_in field.flags {
		draw_outline_rectangle(ctx, x, y, width, height, dark, background, light)
		x += 1
		y += 1
		width -= 2
		height -= 2
	} else {
		fill_rectangle(ctx, x, y, width, height, background)
	}
	checker_color := value^
	if .Disabled in field.flags {
		checker_color = foreground
	}
	draw_checker(ctx, x + 2, y + 2, height - 4, height - 4, checker_color)
	text := fmt.tprintf("%08x", value^)
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		x + height - field.left,
		y + 1,
		field.left,
		field.top,
		ctx.screen.pitch,
		x + height,
		y + 1,
		min(x + width - 2, ctx.screen.width),
		min(y + height - 2, ctx.screen.height),
	)
}

@(private = "file")
rgb_to_hsv :: proc(color: u32) -> (hue, saturation, value: int) {
	red := int(u8(color >> 16))
	green := int(u8(color >> 8))
	blue := int(u8(color))
	minimum := min(red, min(green, blue))
	value = max(red, max(green, blue))
	delta := value - minimum
	if value == 0 {
		return 0, 0, value
	}
	saturation = delta * 255 / value
	if saturation == 0 {
		return 0, saturation, value
	}
	if red == value {
		hue = 43 * (green - blue) / delta
	} else if green == value {
		hue = 85 + 43 * (blue - red) / delta
	} else {
		hue = 171 + 43 * (red - green) / delta
	}
	if hue < 0 {
		hue += 256
	}
	return
}

@(private = "file")
hsv_to_rgb :: proc(alpha, hue, saturation, value: int) -> u32 {
	red, green, blue := value, value, value
	if saturation != 0 {
		sector := 0
		if hue <= 255 {
			sector = hue / 43
		}
		fraction := (hue - sector * 43) * 6
		p := (value * (255 - saturation) + 127) >> 8
		q := (value * (255 - ((saturation * fraction + 127) >> 8)) + 127) >> 8
		t := (value * (255 - ((saturation * (255 - fraction) + 127) >> 8)) + 127) >> 8
		switch sector {
		case 0: red, green, blue = value, t, p
		case 1: red, green, blue = q, value, p
		case 2: red, green, blue = p, value, t
		case 3: red, green, blue = p, q, value
		case 4: red, green, blue = t, p, value
		case:   red, green, blue = value, p, q
		}
	}
	return u32(alpha & 255) << 24 | u32(red) << 16 | u32(green) << 8 | u32(blue)
}

@(private = "file")
color_edit_string :: proc(ctx: ^Context) -> string {
	return string(ctx.color_edit[:])
}

@(private = "file")
set_color_edit :: proc(ctx: ^Context) {
	text := fmt.tprintf("%08x", ctx.color)
	copy(ctx.color_edit[:], transmute([]u8)(text))
	ctx.color_cursor = 8
}

@(private = "file")
parse_color_edit :: proc(ctx: ^Context) {
	value: u32
	for character in ctx.color_edit {
		value <<= 4
		switch {
		case character >= '0' && character <= '9': value |= u32(character - '0')
		case character >= 'a' && character <= 'f': value |= u32(character - 'a' + 10)
		case character >= 'A' && character <= 'F': value |= u32(character - 'A' + 10)
		case:
		}
	}
	ctx.color = value
	ctx.color_hue, ctx.color_saturation, ctx.color_value = rgb_to_hsv(value)
}

@(private = "file")
draw_color_popup :: proc(ctx: ^Context, field: ^Form) -> Error {
	x, y := ctx.popup_x, ctx.popup_y
	width, height := ctx.popup_width, ctx.popup_height
	if width < 312 || height < 272 {
		return .Invalid_Input
	}
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	background := ctx.theme[int(Theme_Color.Input_Background)]
	if .No_Border not_in field.flags {
		draw_outline_rectangle(ctx, x, y, width, height, dark, background, dark)
		x += 1
		y += 1
		width -= 2
		height -= 2
		if .No_Shadow not_in field.flags {
			fill_rectangle(ctx, x + width + 1, y + 3, 4, height - 2, ctx.theme[int(Theme_Color.Shadow)])
			fill_rectangle(ctx, x + 3, y + height + 1, width + 2, 4, ctx.theme[int(Theme_Color.Shadow)])
		}
	} else {
		fill_rectangle(ctx, x, y, width, height, background)
	}
	checker_width := max(field.computed_height - 6, 1)
	draw_checker(ctx, x + 3, y + 3, checker_width, checker_width, ctx.color)
	if ctx.font_draw != nil {
		if error := draw_font(ctx,
			ctx.font,
			color_edit_string(ctx),
			ctx.screen.pixels,
			ctx.theme[int(Theme_Color.Input_Selected_Foreground)],
			x + checker_width + 5 - field.left,
			y + 2,
			field.left,
			field.top,
			ctx.screen.pitch,
			x + checker_width + 5,
			y + 1,
			min(x + width - 2, ctx.screen.width),
			min(y + field.computed_height + 2, ctx.screen.height),
		); error != .None {
			return error
		}
	}
	picker_y := y + field.computed_height + 8
	for index in 0 ..< 16 {
		draw_checker(ctx, x + 3, picker_y + index * 16 + 2, 12, 12, ctx.color_history[index])
	}
	for row in 0 ..< 256 {
		preview := ctx.color & 0x00ffffff | u32(255 - row) << 24
		draw_checker(ctx, x + 22, picker_y + row, 16, 1, preview)
		for column in 0 ..< 256 {
			color := hsv_to_rgb(255, ctx.color_hue, column, 255 - row)
			if column == ctx.color_saturation || 255 - row == ctx.color_value {
				color = ctx.theme[int(Theme_Color.Input_Cursor)]
			}
			set_pixel(ctx, x + 40 + column, picker_y + row, color)
		}
		hue_color := hsv_to_rgb(255, row, 255, 255)
		if row == ctx.color_hue {
			hue_color = ctx.theme[int(Theme_Color.Input_Cursor)]
		}
		fill_rectangle(ctx, x + 298, picker_y + row, 16, 1, hue_color)
	}
	return .None
}

@(private = "file")
draw_icon_button :: proc(ctx: ^Context, field: ^Form) {
	if !image_valid(field.icon) || !binding_selected(field) {
		return
	}
	x := field.computed_x + (field.computed_width - field.icon.width) / 2
	y := field.computed_y + (field.computed_height - field.icon.height) / 2
	for row in 0 ..< field.icon.height {
		for column in 0 ..< field.icon.width {
			blend_image_pixel(
				ctx,
				x + column,
				y + row,
				field.icon,
				column,
				row,
				.Disabled in field.flags,
			)
		}
	}
}

@(private = "file")
draw_button :: proc(ctx: ^Context, field: ^Form) -> Error {
	has_text := field.label > 0 && field.label < len(ctx.texts)
	if has_text && (ctx.font == nil || ctx.font_bounds == nil || ctx.font_draw == nil) {
		return .Invalid_Input
	}
	text := ""
	text_width, text_height, left, top: int
	if has_text {
		text = ctx.texts[field.label]
		if error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
		   error != .None {
			return error
		}
	}
	width := field.computed_width
	height := field.computed_height
	x := field.computed_x
	y := field.computed_y
	disabled := .Disabled in field.flags
	pressed := ctx.pressed == field
	if field.kind == .Button && binding_selected(field) {
		pressed = true
	}
	hovered := ctx.hovered == field
	outer := ctx.theme[int(Theme_Color.Button_Normal_Border)]
	if disabled {
		outer = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	} else if hovered && !pressed {
		outer = ctx.theme[int(Theme_Color.Button_Selected_Border)]
	}
	if .No_Border not_in field.flags {
		for border_x in x - 1 ..< min(x + width, ctx.screen.width - 1) {
			blend_pixel(ctx, border_x, y - 1, outer)
		}
		for border_x in x ..< min(x + width, ctx.screen.width - 1) {
			blend_pixel(ctx, border_x, y + height, outer)
		}
		for border_y in y ..< y + height {
			blend_pixel(ctx, x - 1, border_y, outer)
			blend_pixel(ctx, x + width, border_y, outer)
		}
	}
	if disabled {
		fill_rectangle(ctx, x, y, width, height, ctx.theme[int(Theme_Color.Disabled_Background)])
	} else {
		light := ctx.theme[int(Theme_Color.Button_Light_Inner_Border)]
		dark := ctx.theme[int(Theme_Color.Button_Dark_Inner_Border)]
		light_background := ctx.theme[int(Theme_Color.Button_Light_Background)]
		dark_background := ctx.theme[int(Theme_Color.Button_Dark_Background)]
		if pressed {
			draw_outline_rectangle(ctx, x, y, width, height, dark, dark_background, light)
			fill_rectangle(
				ctx,
				x + 1,
				y + 1,
				width - 2,
				height - height * 5 / 8 - 1,
				dark_background,
			)
			fill_rectangle(
				ctx,
				x + 1,
				y + height - height * 5 / 8 - 1,
				width - 2,
				height * 5 / 8,
				light_background,
			)
		} else {
			draw_outline_rectangle(ctx, x, y, width, height, light, light_background, dark)
			fill_rectangle(ctx, x + 1, y + 1, width - 2, height * 5 / 8, light_background)
			fill_rectangle(
				ctx,
				x + 1,
				y + height * 5 / 8,
				width - 2,
				height - height * 5 / 8 - 1,
				dark_background,
			)
		}
	}
	content_width := text_width
	if image_valid(field.icon) {
		content_width += field.icon.width
		if has_text {
			content_width += 4
		}
	}
	text_x := x + (width - content_width) / 2
	text_y := y + (height - text_height) / 2
	if pressed && !disabled {
		text_y += 1
	}
	if image_valid(field.icon) {
		icon_x := text_x
		icon_y := y + (height - field.icon.height) / 2
		if pressed && !disabled {
			icon_y += 1
		}
		for row in 0 ..< field.icon.height {
			for column in 0 ..< field.icon.width {
				blend_image_pixel(ctx, icon_x + column, icon_y + row, field.icon, column, row, disabled)
			}
		}
		text_x += field.icon.width
		if has_text {
			text_x += 4
		}
	}
	if has_text && !disabled {
		dark_shadow := ctx.theme[int(Theme_Color.Button_Dark_Shadow)]
		light_shadow := ctx.theme[int(Theme_Color.Button_Light_Shadow)]
		if hovered {
			dark_shadow = ctx.theme[int(Theme_Color.Button_Selected_Dark_Shadow)]
			light_shadow = ctx.theme[int(Theme_Color.Button_Selected_Light_Shadow)]
		}
		if error := draw_font(ctx,
			ctx.font,
			text,
			ctx.screen.pixels,
			dark_shadow,
			text_x - 1 - left,
			text_y - 1,
			left,
			top,
			ctx.screen.pitch,
			1,
			1,
			ctx.screen.width - 1,
			ctx.screen.height - 1,
		); error != .None {
			return error
		}
		if error := draw_font(ctx,
			ctx.font,
			text,
			ctx.screen.pixels,
			light_shadow,
			text_x + 1 - left,
			text_y + 1,
			left,
			top,
			ctx.screen.pitch,
			1,
			1,
			ctx.screen.width - 1,
			ctx.screen.height - 1,
		); error != .None {
			return error
		}
	}
	if !has_text {
		return .None
	}
	foreground := ctx.theme[int(Theme_Color.Button_Foreground)]
	if disabled {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	} else if hovered {
		foreground = ctx.theme[int(Theme_Color.Button_Selected_Foreground)]
	}
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		text_x - left,
		text_y,
		left,
		top,
		ctx.screen.pitch,
		1,
		1,
		ctx.screen.width - 1,
		ctx.screen.height - 1,
	)
}

@(private = "file")
draw_choice :: proc(ctx: ^Context, field: ^Form) -> Error {
	if field.label < 0 ||
	   field.label >= len(ctx.texts) ||
	   ctx.font == nil ||
	   ctx.font_bounds == nil ||
	   ctx.font_draw == nil {
		return .Invalid_Input
	}
	text := ctx.texts[field.label]
	_, text_height, left, top, error := measure_label(ctx, field)
	if error != .None {
		return error
	}
	height := field.computed_height
	x := field.computed_x
	y := field.computed_y
	disabled := .Disabled in field.flags
	selected := binding_selected(field)
	text_x := x
	if .No_Bullet not_in field.flags {
		center_x := x + height / 2
		center_y := y + height / 2
		if field.kind == .Checkbox {
			draw_checkbox(ctx, center_x, center_y, selected, disabled)
		} else {
			draw_radio(ctx, center_x, center_y, selected, disabled)
		}
		text_x += height
	} else if ctx.menu != nil && ctx.hovered == field {
		fill_rectangle(
			ctx,
			x,
			y,
			field.computed_width,
			height,
			ctx.theme[int(Theme_Color.Highlight_Background)],
		)
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if .No_Bullet in field.flags && ctx.menu != nil && ctx.hovered == field {
		foreground = ctx.theme[int(Theme_Color.Highlight_Foreground)]
	}
	if disabled {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		text_x,
		y + (height - text_height) / 2,
		left,
		top,
		ctx.screen.pitch,
		0,
		0,
		ctx.screen.width,
		ctx.screen.height,
	)
}

@(private = "file")
draw_text_input :: proc(ctx: ^Context, field: ^Form) -> Error {
	buffer, valid := bound_text_buffer(field)
	if !valid || ctx.font == nil || ctx.font_bounds == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	disabled := .Disabled in field.flags
	active := ctx.text_field == field && !disabled
	background := ctx.theme[int(Theme_Color.Input_Background)]
	foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	if active {
		foreground = ctx.theme[int(Theme_Color.Input_Selected_Foreground)]
		dark = ctx.theme[int(Theme_Color.Input_Selected_Border)]
		light = dark
	}
	if disabled {
		background = ctx.theme[int(Theme_Color.Disabled_Background)]
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		dark = background
		light = background
	}
	draw_outline_rectangle(
		ctx,
		field.computed_x,
		field.computed_y,
		field.computed_width,
		field.computed_height,
		dark,
		background,
		light,
	)
	fill_rectangle(
		ctx,
		field.computed_x + 1,
		field.computed_y + 1,
		field.computed_width - 2,
		field.computed_height - 2,
		background,
	)
	text := text_buffer_string(buffer)
	if len(text) == 0 && ctx.text_field != field {
		return .None
	}
	visible_start := 0
	cursor_width := 0
	if active {
		cursor := clamp(ctx.text_cursor, 0, len(text))
		ctx.text_scroll = clamp(ctx.text_scroll, 0, cursor)
		available_width := max(field.computed_width - 6, 0)
		for {
			left, top, height: int
			if error := ctx.font_bounds(
				ctx.font,
				text[ctx.text_scroll:cursor],
				&cursor_width,
				&height,
				&left,
				&top,
			); error != .None {
				return error
			}
			if cursor_width < available_width || ctx.text_scroll >= cursor {
				break
			}
			ctx.text_scroll = next_codepoint(transmute([]u8)(text), ctx.text_scroll)
		}
		visible_start = ctx.text_scroll
	}
	if error := draw_font(ctx,
		ctx.font,
		text[visible_start:],
		ctx.screen.pixels,
		foreground,
		field.computed_x + 3 - field.left,
		field.computed_y + 2,
		field.left,
		field.top,
		ctx.screen.pitch,
		field.computed_x + 3,
		field.computed_y + 2,
		field.computed_x + field.computed_width - 3,
		field.computed_y + field.computed_height - 2,
	); error != .None {
		return error
	}
	if active {
		cursor_x := field.computed_x + 3 + cursor_width
		for cursor_y in field.computed_y + 2 ..< field.computed_y + field.computed_height - 2 {
			set_pixel(ctx, cursor_x, cursor_y, ctx.theme[int(Theme_Color.Input_Cursor)])
		}
	}
	return .None
}

@(private = "file")
draw_option_input :: proc(ctx: ^Context, field: ^Form) -> Error {
	selected := ((^int)(field.binding.data))^
	text := ""
	if selected >= 0 && selected < len(field.options) {
		text = field.options[selected]
	}
	x, y := field.computed_x, field.computed_y
	width, height := field.computed_width, field.computed_height
	if height < 2 || width < 2 * height {
		return .None
	}
	input_light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	input_dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	input_background := ctx.theme[int(Theme_Color.Input_Background)]
	input_foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	button_background := ctx.theme[int(Theme_Color.Button_Light_Background)]
	button_light := ctx.theme[int(Theme_Color.Button_Light_Inner_Border)]
	button_dark := ctx.theme[int(Theme_Color.Button_Dark_Inner_Border)]
	triangle_background := input_background
	disabled := .Disabled in field.flags
	if disabled {
		input_background = ctx.theme[int(Theme_Color.Disabled_Background)]
		button_light = input_background
		button_dark = input_background
		triangle_background = input_background
		input_foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		input_light = input_foreground
		input_dark = input_foreground
		button_background = input_foreground
	}
	draw_outline_rectangle(
		ctx,
		x,
		y,
		width,
		height,
		input_dark,
		input_background,
		input_light,
	)
	x += 1
	y += 1
	width -= 2
	height -= 2
	fill_rectangle(ctx, x + height, y, width - 2 * height, height, input_background)
	left_pressed := !disabled && ctx.pressed == field && ctx.pressed_part < 0
	right_pressed := !disabled && ctx.pressed == field && ctx.pressed_part > 0
	left_top, left_bottom := button_light, button_dark
	right_top, right_bottom := button_light, button_dark
	left_shift, right_shift := 0, 0
	if left_pressed {
		left_top, left_bottom = button_dark, button_light
		left_shift = 1
	}
	if right_pressed {
		right_top, right_bottom = button_dark, button_light
		right_shift = 1
	}
	draw_outline_rectangle(
		ctx,
		x,
		y,
		height,
		height,
		left_top,
		button_background,
		left_bottom,
	)
	fill_rectangle(ctx, x + 1, y + 1, height - 2, height - 2, button_background)
	right_x := x + width - height
	draw_outline_rectangle(
		ctx,
		right_x,
		y,
		height,
		height,
		right_top,
		button_background,
		right_bottom,
	)
	fill_rectangle(ctx, right_x + 1, y + 1, height - 2, height - 2, button_background)
	draw_reference_triangle(
		ctx,
		x + height / 2 - 3,
		y + height / 2 - 4 + left_shift,
		false,
		input_light,
		triangle_background,
		input_dark,
	)
	draw_reference_triangle(
		ctx,
		x + width - height / 2 - 2,
		y + height / 2 - 4 + right_shift,
		true,
		input_light,
		triangle_background,
		input_dark,
	)
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		input_foreground,
		x + height + 2 - field.left,
		y + 1,
		field.left,
		field.top,
		ctx.screen.pitch,
		x + height + 2 - field.left,
		y + 1,
		min(x + width - height - 2, ctx.screen.width),
		min(y + height - 2, ctx.screen.height),
	)
}

@(private = "file")
draw_choice_input :: proc(ctx: ^Context, field: ^Form) -> Error {
	if ctx.font == nil ||
	   ctx.font_bounds == nil ||
	   ctx.font_draw == nil ||
	   field.binding.kind != .Integer ||
	   field.binding.data == nil ||
	   len(field.options) == 0 {
		return .Invalid_Input
	}
	if field.kind == .Option {
		return draw_option_input(ctx, field)
	}
	selected := ((^int)(field.binding.data))^
	text := ""
	if selected >= 0 && selected < len(field.options) {
		text = field.options[selected]
	}
	x, y := field.computed_x, field.computed_y
	width, height := field.computed_width, field.computed_height
	if height < 2 || width < height {
		return .None
	}
	input_light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	input_dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	input_background := ctx.theme[int(Theme_Color.Input_Background)]
	input_foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	button_background := ctx.theme[int(Theme_Color.Button_Light_Background)]
	button_light := ctx.theme[int(Theme_Color.Button_Light_Inner_Border)]
	button_dark := ctx.theme[int(Theme_Color.Button_Dark_Inner_Border)]
	triangle_background := input_background
	disabled := .Disabled in field.flags
	if disabled {
		input_background = ctx.theme[int(Theme_Color.Disabled_Background)]
		button_light = input_background
		button_dark = input_background
		triangle_background = input_background
		input_foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		input_light = input_foreground
		input_dark = input_foreground
		button_background = input_foreground
	}
	draw_outline_rectangle(
		ctx,
		x,
		y,
		width,
		height,
		input_dark,
		input_background,
		input_light,
	)
	x += 1
	y += 1
	width -= 2
	height -= 2
	fill_rectangle(ctx, x, y, width - height, height, input_background)
	pressed := !disabled && ctx.pressed == field
	top, bottom := button_light, button_dark
	shift := 0
	if pressed {
		top, bottom = button_dark, button_light
		shift = 1
	}
	button_x := x + width - height
	draw_outline_rectangle(ctx, button_x, y, height, height, top, button_background, bottom)
	fill_rectangle(ctx, button_x + 1, y + 1, height - 2, height - 2, button_background)
	draw_down_triangle(
		ctx,
		x + width - height / 2 - 3,
		y + height / 2 - 2 + shift,
		input_light,
		triangle_background,
		input_dark,
	)
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		input_foreground,
		x + 2 - field.left,
		y + 1,
		field.left,
		field.top,
		ctx.screen.pitch,
		x + 2,
		y + 1,
		min(x + width - height - 2, ctx.screen.width),
		min(y + height - 2, ctx.screen.height),
	)
}

@(private = "file")
draw_select_popup :: proc(ctx: ^Context, field: ^Form) -> Error {
	x, y, width, height, row_height := select_popup_geometry(ctx, field)
	if width < 1 || height < 1 || x >= ctx.screen.width || y >= ctx.screen.height {
		return .Invalid_Input
	}
	border := ctx.theme[int(Theme_Color.Input_Selected_Border)]
	background := ctx.theme[int(Theme_Color.Input_Background)]
	draw_outline_rectangle(ctx, x, y, width, height, border, background, border)
	x += 1
	y += 1
	width -= 2
	height -= 2
	if .No_Shadow not_in field.flags {
		fill_rectangle(ctx, x + width + 1, y + 3, 4, height - 2, ctx.theme[int(Theme_Color.Shadow)])
		fill_rectangle(ctx, x + 3, y + height + 1, width + 2, 4, ctx.theme[int(Theme_Color.Shadow)])
	}
	fill_rectangle(ctx, x, y, width, height, background)
	for option, index in field.options {
		row_y := y + index * row_height
		if row_y + field.top >= ctx.screen.height {
			break
		}
		hovered := ctx.mouse_y >= row_y + 1 && ctx.mouse_y < row_y + 1 + row_height
		foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
		if hovered {
			field.selected_option = index
			fill_rectangle(
				ctx,
				x + 1,
				row_y + 1,
				width - 2,
				row_height,
				ctx.theme[int(Theme_Color.Highlight_Background)],
			)
			foreground = ctx.theme[int(Theme_Color.Highlight_Foreground)]
		}
		if error := draw_font(ctx,
			ctx.font,
			option,
			ctx.screen.pixels,
			foreground,
			x + 2 - field.left,
			row_y + 1,
			field.left,
			field.top,
			ctx.screen.pitch,
			x + 2,
			row_y + 1,
			min(x + width, ctx.screen.width),
			min(row_y + 1 + row_height, ctx.screen.height),
		); error != .None {
			return error
		}
	}
	return .None
}

@(private = "file")
draw_clipped_text :: proc(
	ctx: ^Context,
	text: string,
	x, y, width, height: int,
	color: u32,
) -> Error {
	text_width, text_height, left, top: int
	if error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
	   error != .None {
		return error
	}
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		color,
		x,
		y + (height - text_height) / 2,
		left,
		top,
		ctx.screen.pitch,
		x,
		y,
		x + width,
		y + height,
	)
}

@(private = "file")
select_popup_geometry :: proc(
	ctx: ^Context,
	field: ^Form,
) -> (x, y, width, height, row_height: int) {
	if ctx.popup == field && ctx.popup_width > 0 && ctx.popup_height > 0 {
		return ctx.popup_x,
		       ctx.popup_y,
		       ctx.popup_width,
		       ctx.popup_height,
		       field.computed_height - 4
	}
	x = field.computed_x
	width = field.computed_width
	for option in field.options {
		option_width, option_height, left, top: int
		if ctx.font_bounds(ctx.font, option, &option_width, &option_height, &left, &top) == .None {
			width = max(width, option_width)
		}
	}
	row_height = field.computed_height - 4
	y = field.computed_y - row_height * field.selected_option
	height = 4 + row_height * len(field.options)
	if x + width + 2 >= ctx.screen.width {
		x = ctx.screen.width - width - 2
	}
	if y + height + 2 >= ctx.screen.height {
		y = ctx.screen.height - height - 2
	}
	if x < 0 {
		width += x
		x = 0
	}
	if y < 0 {
		height += y
		y = 0
	}
	return
}

@(private = "file")
draw_numeric_input :: proc(ctx: ^Context, field: ^Form) -> Error {
	if ctx.font == nil || ctx.font_bounds == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	text, valid := numeric_input_text(ctx, field)
	if !valid {
		return .Invalid_Input
	}
	x, y := field.computed_x, field.computed_y
	width, height := field.computed_width, field.computed_height
	if width < 2 * height || height < 2 {
		return .None
	}
	disabled := .Disabled in field.flags
	input_background := ctx.theme[int(Theme_Color.Input_Background)]
	input_foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	input_dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	input_light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	button_light := ctx.theme[int(Theme_Color.Button_Light_Inner_Border)]
	button_dark := ctx.theme[int(Theme_Color.Button_Dark_Inner_Border)]
	button_background := ctx.theme[int(Theme_Color.Button_Light_Background)]
	triangle_background := input_background
	if disabled {
		input_background = ctx.theme[int(Theme_Color.Disabled_Background)]
		input_foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		input_dark = input_foreground
		input_light = input_foreground
		button_light = input_background
		button_dark = input_background
		button_background = input_foreground
		triangle_background = input_background
	}
	draw_outline_rectangle(ctx, x, y, width, height, input_dark, input_background, input_light)
	inner_x, inner_y := x + 1, y + 1
	inner_width, inner_height := width - 2, height - 2
	fill_rectangle(
		ctx,
		inner_x + inner_height,
		inner_y,
		inner_width - 2 * inner_height,
		inner_height,
		input_background,
	)

	left_pressed := !disabled && ctx.pressed == field && ctx.pressed_part < 0
	right_pressed := !disabled && ctx.pressed == field && ctx.pressed_part > 0
	left_top, left_bottom := button_light, button_dark
	right_top, right_bottom := button_light, button_dark
	left_shift, right_shift := 0, 0
	if left_pressed {
		left_top, left_bottom = button_dark, button_light
		left_shift = 1
	}
	if right_pressed {
		right_top, right_bottom = button_dark, button_light
		right_shift = 1
	}
	draw_outline_rectangle(
		ctx,
		inner_x,
		inner_y,
		inner_height,
		inner_height,
		left_top,
		button_background,
		left_bottom,
	)
	fill_rectangle(
		ctx,
		inner_x + 1,
		inner_y + 1,
		inner_height - 2,
		inner_height - 2,
		button_background,
	)
	right_x := inner_x + inner_width - inner_height
	draw_outline_rectangle(
		ctx,
		right_x,
		inner_y,
		inner_height,
		inner_height,
		right_top,
		button_background,
		right_bottom,
	)
	fill_rectangle(
		ctx,
		right_x + 1,
		inner_y + 1,
		inner_height - 2,
		inner_height - 2,
		button_background,
	)
	draw_reference_triangle(
		ctx,
		inner_x + inner_height / 2 - 3,
		inner_y + inner_height / 2 - 4 + left_shift,
		false,
		input_light,
		triangle_background,
		input_dark,
	)
	draw_reference_triangle(
		ctx,
		inner_x + inner_width - inner_height / 2 - 2,
		inner_y + inner_height / 2 - 4 + right_shift,
		true,
		input_light,
		triangle_background,
		input_dark,
	)

	text_width, text_height, left, top: int
	if error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
	   error != .None {
		return error
	}
	text_x :=
		inner_x + inner_height + 2 + inner_width - 2 * inner_height - 4 - text_width - field.left
	if error := draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		input_foreground,
		text_x,
		inner_y + 1,
		field.left,
		field.top,
		ctx.screen.pitch,
		inner_x + inner_height + 2 - field.left,
		inner_y + 1,
		min(inner_x + inner_width - inner_height - 2, ctx.screen.width),
		min(inner_y + inner_height - 2, ctx.screen.height),
	); error != .None {
		return error
	}
	return .None
}

@(private = "file")
draw_down_triangle :: proc(ctx: ^Context, x, y: int, light, background, dark: u32) {
	if x < 0 || y < 0 || x + 7 >= ctx.screen.width || y + 7 >= ctx.screen.height {
		return
	}
	rows := [5]string {
		"ddddddd",
		"dbbbbbl",
		".dbbbl.",
		"..dbl..",
		"...l...",
	}
	for row, row_index in rows {
		for pixel, column in transmute([]u8)(row) {
			color := background
			switch pixel {
			case 'l':
				color = light
			case 'd':
				color = dark
			case 'b':
			case:
				continue
			}
			set_pixel(ctx, x + column, y + row_index, color)
		}
	}
}

@(private = "file")
draw_reference_triangle :: proc(
	ctx: ^Context,
	x, y: int,
	right: bool,
	light, background, dark: u32,
) {
	if x < 0 || y < 0 || x + 7 >= ctx.screen.width || y + 7 >= ctx.screen.height {
		return
	}
	left_rows := [7]string {
		"...db..",
		"..dbl..",
		".dbbl..",
		"dbbbl..",
		".bbbl..",
		"..bbl..",
		"...bl..",
	}
	right_rows := [7]string {
		"bd.....",
		"bbd....",
		"bbbd...",
		"bbbbl..",
		"bbbl...",
		"bbl....",
		"bl.....",
	}
	rows := left_rows[:]
	if right {
		rows = right_rows[:]
	}
	for row, row_index in rows {
		for pixel, column in transmute([]u8)(row) {
			color := background
			switch pixel {
			case 'l':
				color = light
			case 'd':
				color = dark
			case 'b':
			case:
				continue
			}
			set_pixel(ctx, x + column, y + row_index, color)
		}
	}
}

@(private = "file")
draw_symbol :: proc(ctx: ^Context, symbol: string, x, y, width, height: int, color: u32) -> Error {
	text_width, text_height, left, top: int
	if error := ctx.font_bounds(ctx.font, symbol, &text_width, &text_height, &left, &top);
	   error != .None {
		return error
	}
	return draw_font(ctx,
		ctx.font,
		symbol,
		ctx.screen.pixels,
		color,
		x + (width - text_width) / 2,
		y + (height - text_height) / 2,
		left,
		top,
		ctx.screen.pitch,
		x,
		y,
		x + width,
		y + height,
	)
}

@(private = "file")
numeric_input_text :: proc(ctx: ^Context, field: ^Form) -> (string, bool) {
	if ctx.text_field == field {
		return text_buffer_string(&ctx.edit_buffer), true
	}
	if field.kind == .Float_Input {
		if field.binding.kind != .Float || field.binding.data == nil {
			return "", false
		}
		return fmt.tprintf("%g", ((^f32)(field.binding.data))^), true
	}
	value, valid := bound_integer(field)
	if !valid {
		return "", false
	}
	return fmt.tprintf("%d", value), true
}

@(private = "file")
draw_slider :: proc(ctx: ^Context, field: ^Form) {
	x := field.computed_x
	y := field.computed_y
	width := field.computed_width
	height := field.computed_height
	disabled := .Disabled in field.flags
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	background := ctx.theme[int(Theme_Color.Input_Background)]
	foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	if disabled {
		dark = ctx.theme[int(Theme_Color.Disabled_Background)]
		light = dark
		background = dark
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	track_y := y + height / 2 - 3
	draw_outline_rectangle(ctx, x, track_y, width, 5, dark, background, light)
	value, valid := bound_integer(field)
	if !valid {
		value = int(field.minimum)
	}
	minimum := int(field.minimum)
	maximum := int(field.maximum)
	if maximum <= minimum {
		maximum = minimum + 1
	}
	value = clamp(value, minimum, maximum)
	position := (value - minimum) * (width - 9) / (maximum - minimum)
	fill_rectangle(ctx, x + 1, track_y + 1, position + 3, 3, foreground)
	fill_rectangle(ctx, x + position + 3, track_y + 1, width - 4 - position, 3, background)
	draw_monochrome_radio(ctx, x + position + 5, y + height / 2, foreground)
}

@(private = "file")
scrollbar_metrics :: proc(size, current, maximum, minimum_thumb: int) -> (position, thumb: int) {
	clamped_current := clamp(current, 0, max(maximum, 0))
	if size >= maximum || maximum < 1 {
		return 0, max(size, 0)
	}
	thumb = size * size / maximum
	thumb = max(thumb, minimum_thumb)
	position = (size - thumb) * clamped_current / max(maximum - size, 1)
	return
}

@(private = "file")
draw_scrollbar :: proc(ctx: ^Context, field: ^Form) {
	vertical := field.kind == .Vertical_Scrollbar
	size := field.computed_width
	thickness := ctx.scrollbar_height
	if vertical {
		size = field.computed_height
		thickness = ctx.scrollbar_width
	}
	if size < 1 || thickness < 1 {
		return
	}
	value, valid := bound_integer(field)
	if !valid {
		value = 0
	}
	position, thumb := scrollbar_metrics(size, value, int(field.maximum), thickness)
	disabled := .Disabled in field.flags
	if vertical && image_valid(&ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Middle)]) {
		track_top := &ctx.skin[int(Skin_Image.Vertical_Scrollbar_Top)]
		track_middle := &ctx.skin[int(Skin_Image.Vertical_Scrollbar_Middle)]
		track_bottom := &ctx.skin[int(Skin_Image.Vertical_Scrollbar_Bottom)]
		button_top := &ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Top)]
		button_middle := &ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Middle)]
		button_bottom := &ctx.skin[int(Skin_Image.Vertical_Scrollbar_Button_Bottom)]
		x, y := field.computed_x, field.computed_y
		blit_tiled_image(ctx, x + (thickness - track_top.width) / 2, y, track_top.width, track_top.height, track_top, disabled)
		blit_tiled_image(ctx, x + (thickness - track_middle.width) / 2, y + track_top.height, track_middle.width, size - track_top.height - track_bottom.height, track_middle, disabled)
		blit_tiled_image(ctx, x + (thickness - track_bottom.width) / 2, y + size - track_bottom.height, track_bottom.width, track_bottom.height, track_bottom, disabled)
		blit_tiled_image(ctx, x + (thickness - button_top.width) / 2, y + position, button_top.width, button_top.height, button_top, disabled)
		blit_tiled_image(ctx, x + (thickness - button_middle.width) / 2, y + position + button_top.height, button_middle.width, thumb - button_top.height - button_bottom.height, button_middle, disabled)
		blit_tiled_image(ctx, x + (thickness - button_bottom.width) / 2, y + position + thumb - button_bottom.height, button_bottom.width, button_bottom.height, button_bottom, disabled)
		return
	}
	if !vertical && image_valid(&ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Middle)]) {
		track_left := &ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Left)]
		track_middle := &ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Middle)]
		track_right := &ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Right)]
		button_left := &ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Left)]
		button_middle := &ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Middle)]
		button_right := &ctx.skin[int(Skin_Image.Horizontal_Scrollbar_Button_Right)]
		x, y := field.computed_x, field.computed_y
		blit_tiled_image(ctx, x, y + (thickness - track_left.height) / 2, track_left.width, track_left.height, track_left, disabled)
		blit_tiled_image(ctx, x + track_left.width, y + (thickness - track_middle.height) / 2, size - track_left.width - track_right.width, track_middle.height, track_middle, disabled)
		blit_tiled_image(ctx, x + size - track_right.width, y + (thickness - track_right.height) / 2, track_right.width, track_right.height, track_right, disabled)
		blit_tiled_image(ctx, x + position, y + (thickness - button_left.height) / 2, button_left.width, button_left.height, button_left, disabled)
		blit_tiled_image(ctx, x + position + button_left.width, y + (thickness - button_middle.height) / 2, thumb - button_left.width - button_right.width, button_middle.height, button_middle, disabled)
		blit_tiled_image(ctx, x + position + thumb - button_right.width, y + (thickness - button_right.height) / 2, button_right.width, button_right.height, button_right, disabled)
		return
	}
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	track := ctx.theme[int(Theme_Color.Scrollbar_Background)]
	button := ctx.theme[int(Theme_Color.Button_Light_Background)]
	active := ctx.vertical_bar == field || ctx.horizontal_bar == field || .Selected in field.flags
	if active {
		light, dark = dark, light
	}
	if disabled {
		track = ctx.theme[int(Theme_Color.Disabled_Background)]
		light = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		dark = light
		button = light
	}
	x, y := field.computed_x, field.computed_y
	if vertical {
		fill_rectangle(ctx, x, y, thickness, position, track)
		draw_outline_rectangle(ctx, x, y + position, thickness, thumb, light, button, dark)
		fill_rectangle(ctx, x + 1, y + position + 1, thickness - 2, thumb - 2, button)
		fill_rectangle(ctx, x, y + position + thumb, thickness, size - position - thumb, track)
	} else {
		fill_rectangle(ctx, x, y, position, thickness, track)
		draw_outline_rectangle(ctx, x + position, y, thumb, thickness, light, button, dark)
		fill_rectangle(ctx, x + position + 1, y + 1, thumb - 2, thickness - 2, button)
		fill_rectangle(ctx, x + position + thumb, y, size - position - thumb, thickness, track)
	}
}

@(private = "file")
draw_monochrome_radio :: proc(ctx: ^Context, x, y: int, color: u32) {
	base_x, base_y := x - 5, y - 5
	for row in 0 ..= 8 {
		start, end := 0, 8
		if row == 0 || row == 8 {
			start, end = 2, 6
		} else if row == 1 || row == 7 {
			start, end = 1, 7
		}
		for column in start ..= end {
			set_pixel(ctx, base_x + column, base_y + row, color)
		}
	}
}

@(private = "file")
draw_progress_bar :: proc(ctx: ^Context, field: ^Form) -> Error {
	x := field.computed_x
	y := field.computed_y
	width := field.computed_width
	height := field.computed_height
	value, valid := bound_integer(field)
	if !valid {
		value = int(field.minimum)
	}
	minimum := int(field.minimum)
	maximum := int(field.maximum)
	if maximum <= minimum {
		maximum = minimum + 1
	}
	value = clamp(value, minimum, maximum)
	draw_outline_rectangle(
		ctx,
		x,
		y,
		width,
		height,
		ctx.theme[int(Theme_Color.Input_Dark_Border)],
		ctx.theme[int(Theme_Color.Input_Background)],
		ctx.theme[int(Theme_Color.Input_Light_Border)],
	)
	x += 1
	y += 1
	width -= 2
	height -= 2
	filled := width * (value - minimum) / (maximum - minimum)
	progress_background := ctx.theme[int(Theme_Color.Progress_Background)]
	if filled > 1 {
		draw_outline_rectangle(
			ctx,
			x,
			y,
			filled,
			height,
			ctx.theme[int(Theme_Color.Progress_Light)],
			progress_background,
			ctx.theme[int(Theme_Color.Progress_Dark)],
		)
		fill_rectangle(ctx, x + 1, y + 1, filled - 2, height - 2, progress_background)
	} else {
		fill_rectangle(ctx, x, y, filled, height, progress_background)
	}
	fill_rectangle(
		ctx,
		x + filled,
		y,
		width - filled,
		height,
		ctx.theme[int(Theme_Color.Input_Background)],
	)
	permille := (value - minimum) * 1000 / (maximum - minimum)
	text := fmt.tprintf("%d.%d%%", permille / 10, permille % 10)
	text_width, text_height, left, top: int
	if error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
	   error != .None {
		return error
	}
	error := draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		ctx.theme[int(Theme_Color.Input_Foreground)],
		x + (width - text_width) / 2 - left,
		y + (height - text_height) / 2,
		left,
		top,
		ctx.screen.pitch,
		x + 1,
		y + 1,
		min(x + width - 2, ctx.screen.width),
		min(y + height - 2, ctx.screen.height),
	)
	return error
}

@(private = "file")
draw_bound_value :: proc(ctx: ^Context, field: ^Form) -> Error {
	text, error := format_bound_value(field)
	if error != .None {
		return error
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if .Disabled in field.flags {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	text_width, text_height, left, top: int
	if bounds_error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
	   bounds_error != .None {
		return bounds_error
	}
	_, _, _ = text_height, left, top
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		field.computed_x + field.computed_width - text_width - field.left,
		field.computed_y + 2,
		field.left,
		field.top,
		ctx.screen.pitch,
		0,
		0,
		ctx.screen.width,
		ctx.screen.height,
	)
}

@(private = "file")
draw_text_centered :: proc(ctx: ^Context, text: string, field: ^Form, color: u32) -> Error {
	if ctx.font == nil || ctx.font_bounds == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	text_width, text_height, left, top: int
	if error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
	   error != .None {
		return error
	}
	return draw_font(ctx,
		ctx.font,
		text,
		ctx.screen.pixels,
		color,
		field.computed_x + (field.computed_width - text_width) / 2,
		field.computed_y + (field.computed_height - text_height) / 2,
		left,
		top,
		ctx.screen.pitch,
		0,
		0,
		ctx.screen.width,
		ctx.screen.height,
	)
}

@(private = "file")
format_bound_value :: proc(field: ^Form) -> (string, Error) {
	if field.binding.data == nil {
		return "", .Invalid_Input
	}
	if field.kind == .Decimal_Float {
		if field.binding.kind != .Float {
			return "", .Invalid_Input
		}
		return fmt.tprintf("%.4g", ((^f32)(field.binding.data))^), .None
	}
	value, valid := bound_integer(field)
	if !valid {
		return "", .Invalid_Input
	}
	#partial switch field.kind {
	case .Hexadecimal_8, .Hexadecimal_16, .Hexadecimal_32, .Hexadecimal_64:
		return fmt.tprintf("%x", value), .None
	}
	return fmt.tprintf("%d", value), .None
}

@(private = "file")
bound_text_buffer :: proc(field: ^Form) -> (^Text_Buffer, bool) {
	if field.binding.kind != .Text || field.binding.data == nil {
		return nil, false
	}
	return (^Text_Buffer)(field.binding.data), true
}

@(private = "file")
bound_integer :: proc(field: ^Form) -> (int, bool) {
	if field.binding.kind != .Integer || field.binding.data == nil {
		return 0, false
	}
	return ((^int)(field.binding.data))^, true
}

@(private = "file")
draw_checkbox :: proc(ctx: ^Context, x, y: int, checked, disabled: bool) {
	border_dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	background := ctx.theme[int(Theme_Color.Input_Background)]
	border_light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	if disabled {
		border_dark = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		border_light = border_dark
		foreground = border_dark
		background = ctx.theme[int(Theme_Color.Disabled_Background)]
	}
	draw_outline_rectangle(ctx, x - 5, y - 5, 9, 9, border_dark, background, border_light)
	fill_rectangle(ctx, x - 4, y - 4, 7, 7, background)
	if checked || disabled {
		for offset in 0 ..< 5 {
			set_pixel(ctx, x - 3 + offset, y - 3 + offset, foreground)
			set_pixel(ctx, x + 1 - offset, y - 3 + offset, foreground)
		}
	}
}

@(private = "file")
draw_radio :: proc(ctx: ^Context, x, y: int, checked, disabled: bool) {
	border := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	background := ctx.theme[int(Theme_Color.Input_Background)]
	foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	if disabled {
		border = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		light = border
		foreground = border
		background = ctx.theme[int(Theme_Color.Disabled_Background)]
	}
	filled := background
	if checked || disabled {
		filled = foreground
	}
	base_x, base_y := x - 5, y - 5
	for column in 2 ..= 6 {
		set_pixel(ctx, base_x + column, base_y, border)
		set_pixel(ctx, base_x + column, base_y + 8, light)
	}
	set_pixel(ctx, base_x + 1, base_y + 1, border)
	set_pixel(ctx, base_x + 7, base_y + 1, border)
	set_pixel(ctx, base_x + 1, base_y + 7, light)
	set_pixel(ctx, base_x + 7, base_y + 7, light)
	for column in 2 ..= 6 {
		set_pixel(ctx, base_x + column, base_y + 1, background)
		set_pixel(ctx, base_x + column, base_y + 7, background)
	}
	for row in 2 ..= 6 {
		set_pixel(ctx, base_x, base_y + row, border)
		set_pixel(ctx, base_x + 8, base_y + row, light)
		set_pixel(ctx, base_x + 1, base_y + row, background)
		set_pixel(ctx, base_x + 7, base_y + row, background)
		start, end := 2, 6
		if row == 2 || row == 6 {
			set_pixel(ctx, base_x + 2, base_y + row, background)
			set_pixel(ctx, base_x + 6, base_y + row, background)
			start, end = 3, 5
		}
		for column in start ..= end {
			set_pixel(ctx, base_x + column, base_y + row, filled)
		}
	}
}

@(private = "file")
binding_selected :: proc(field: ^Form) -> bool {
	if field.binding.data == nil {
		return false
	}
	#partial switch field.binding.kind {
	case .Boolean:
		return ((^bool)(field.binding.data))^
	case .Integer:
		value := ((^int)(field.binding.data))^
		if field.kind == .Checkbox || field.kind == .Icon_Button {
			mask := field.value
			if mask == 0 {
				mask = 1
			}
			return value & mask != 0
		}
		return value == field.value
	case:
		return false
	}
}

@(private = "file")
update_hover :: proc(ctx: ^Context, form: []Form) {
	ctx.hovered = hovered_form_at(form, ctx.mouse_x, ctx.mouse_y)
	for &field in form {
		if field.kind == .End {
			break
		}
		if field.kind == .Popup && .Hidden not_in field.flags {
			if candidate := hovered_container_at(&field, ctx.mouse_x, ctx.mouse_y);
			   candidate != nil {
				ctx.hovered = candidate
			}
		}
	}
	if ctx.menu != nil && .Hidden not_in ctx.menu.flags {
		if candidate := hovered_container_at(ctx.menu, ctx.mouse_x, ctx.mouse_y);
		   candidate != nil {
			ctx.hovered = candidate
		}
	}
}

@(private = "file")
hovered_form_at :: proc(forms: []Form, x, y: int) -> ^Form {
	candidate: ^Form
	for &field in forms {
		if field.kind == .End {
			break
		}
		if .Hidden in field.flags ||
		   field.kind == .Popup ||
		   field.kind == .Menu ||
		   !point_inside(&field, x, y) {
			continue
		}
		candidate = &field
		if field.kind == .Division {
			if child := hovered_form_at(field.children, x, y); child != nil {
				candidate = child
			}
		}
	}
	return candidate
}

@(private = "file")
hovered_container_at :: proc(container: ^Form, x, y: int) -> ^Form {
	if container == nil || .Hidden in container.flags || !point_inside(container, x, y) {
		return nil
	}
	if container.kind == .Menu {
		for &child in container.children {
			if child.kind == .End {
				break
			}
			if .Hidden not_in child.flags &&
			   y >= child.computed_y && y < child.computed_y + child.computed_height {
				return &child
			}
		}
	} else if child := hovered_form_at(container.children, x, y); child != nil {
		return child
	}
	return container
}

@(private = "file")
consume_event :: proc(event: ^Event) {
	if event != nil {
		event^ = {}
	}
}

@(private = "file")
is_wheel_event :: proc(event: ^Event) -> bool {
	return event != nil && event.kind == .Mouse &&
	       (.Direction_Up in event.buttons || .Direction_Down in event.buttons)
}

@(private = "file")
invoke_custom_control :: proc(ctx: ^Context, field: ^Form, event: ^Event) -> Error {
	if field == nil || field.custom.control == nil {
		return .None
	}
	ctx.popup_x = field.computed_x
	ctx.popup_y = field.computed_y
	ctx.popup_width = field.computed_width
	ctx.popup_height = field.computed_height
	error := field.custom.control(
		ctx,
		field.computed_x,
		field.computed_y,
		field.computed_width,
		field.computed_height,
		field,
		event,
	)
	if error == .None {
		ctx.flags += {.Refresh}
	}
	return error
}

@(private = "file")
close_custom_popup :: proc(ctx: ^Context) {
	if ctx.popup != nil && ctx.popup.kind == .Custom && ctx.popup.custom.finalize != nil {
		ctx.popup.custom.finalize(ctx, ctx.popup)
	}
	ctx.popup = nil
	ctx.flags -= {.Close}
	ctx.flags += {.Refresh}
}

@(private = "file")
process_custom_popup_event :: proc(ctx: ^Context, event: ^Event) -> Error {
	field := ctx.popup
	if field == nil || field.kind != .Custom {
		return .Invalid_Input
	}
	outside := event.kind == .Mouse && .Released not_in event.buttons &&
	           (event.x < ctx.popup_x || event.x >= ctx.popup_x + ctx.popup_width ||
	            event.y < ctx.popup_y || event.y >= ctx.popup_y + ctx.popup_height)
	if .Close in ctx.flags || field.custom.control == nil || outside {
		close_custom_popup(ctx)
		consume_event(event)
		return .None
	}
	error := field.custom.control(
		ctx,
		ctx.popup_x,
		ctx.popup_y,
		ctx.popup_width,
		ctx.popup_height,
		field,
		event,
	)
	if error != .None {
		return error
	}
	if .Close in ctx.flags {
		close_custom_popup(ctx)
	} else {
		ctx.flags += {.Refresh}
	}
	consume_event(event)
	return .None
}

@(private = "file")
process_event :: proc(ctx: ^Context, form: []Form, event: ^Event) -> Error {
	if event.kind == .Mouse ||
	   (event.kind == .Key && (event.x != 0 || event.y != 0)) {
		ctx.mouse_x = event.x
		ctx.mouse_y = event.y
	}
	if ctx.popup != nil {
		if ctx.popup.kind == .Custom {
			return process_custom_popup_event(ctx, event)
		}
		error := Error.None
		if ctx.popup.kind == .Select {
			error = process_select_popup_event(ctx, event)
		} else if ctx.popup.kind == .Color {
			error = process_color_popup_event(ctx, event)
		}
		if error == .None {
			consume_event(event)
		}
		return error
	}
	if event.kind == .Key {
		update_hover(ctx, form)
		if (key_text(&event.key) == "Escape" || key_text(&event.key) == "\e") &&
		   ctx.menu != nil {
			close_menu(ctx)
			consume_event(event)
			return .None
		}
		if ctx.text_field != nil {
			active := ctx.text_field
			error := process_text_key(ctx, event)
			if error == .None && active.kind == .Custom && active.custom.control != nil {
				error = invoke_custom_control(ctx, active, event)
			}
			if error == .None {
				consume_event(event)
			}
			return error
		}
		if ctx.hovered != nil && ctx.hovered.kind == .Custom && .Disabled not_in ctx.hovered.flags {
			return invoke_custom_control(ctx, ctx.hovered, event)
		}
		return .None
	}
	if event.kind != .Mouse {
		update_hover(ctx, form)
		if ctx.hovered != nil && ctx.hovered.kind == .Custom && .Disabled not_in ctx.hovered.flags {
			return invoke_custom_control(ctx, ctx.hovered, event)
		}
		return .None
	}
	if ctx.text_field != nil {
		if .Released not_in event.buttons && .Mouse_Left in event.buttons {
			if point_inside(ctx.text_field, event.x, event.y) {
				move_text_cursor_to_mouse(ctx, ctx.text_field, event.x)
			} else {
				deactivate_text_input(ctx, true)
			}
		}
		ctx.flags += {.Refresh}
		consume_event(event)
		return .None
	}
	if .Released in event.buttons && (ctx.dragged != nil || ctx.resized != nil) {
		ctx.dragged = nil
		ctx.resized = nil
		ctx.flags += {.Refresh}
		consume_event(event)
		return .None
	}
	if ctx.dragged != nil {
		new_x := clamp(event.x - ctx.drag_x, 1, max(ctx.screen.width - ctx.dragged.computed_width - 1, 1))
		new_y := clamp(event.y - ctx.drag_y, 1, max(ctx.screen.height - ctx.dragged.computed_height - 1, 1))
		ctx.dragged.horizontal_alignment = .Left
		ctx.dragged.vertical_alignment = .Top
		ctx.dragged.x = absolute(new_x)
		ctx.dragged.y = absolute(new_y)
		ctx.dragged.computed_x = new_x
		ctx.dragged.computed_y = new_y
		ctx.flags += {.Refresh}
		consume_event(event)
		return .None
	}
	if ctx.resized != nil {
		new_width := event.x - ctx.resized.computed_x + ctx.drag_x
		new_height := event.y - ctx.resized.computed_y + ctx.drag_y
		title_height := 0
		if .Draggable in ctx.resized.flags {
			title_height = 11
			if ctx.resized.label > 0 && ctx.resized.label < len(ctx.texts) {
				if _, text_height, _, _, measure_error := measure_label(ctx, ctx.resized);
				   measure_error == .None {
					title_height = max(title_height, text_height + 2)
				}
			}
		}
		new_width = max(new_width, 8 + 2 * ctx.resized.margin)
		new_height = max(new_height, 8 + title_height + 2 * ctx.resized.margin)
		ctx.resized.horizontal_alignment = .Left
		ctx.resized.vertical_alignment = .Top
		ctx.resized.width = new_width
		ctx.resized.height = new_height
		ctx.resized.computed_width = new_width
		ctx.resized.computed_height = new_height
		ctx.flags += {.Refresh, .Recalculate}
		consume_event(event)
		return .None
	}
	update_hover(ctx, form)
	if ctx.hovered != nil && ctx.hovered.kind == .Custom && .Disabled not_in ctx.hovered.flags &&
	   ctx.hovered.custom.control != nil {
		error := invoke_custom_control(ctx, ctx.hovered, event)
		if error == .None {
			ctx.flags += {.Refresh}
			consume_event(event)
		}
		return error
	}
	inside_overlay := ctx.menu != nil && point_inside(ctx.menu, event.x, event.y)
	if !inside_overlay {
		for &field in form {
			if field.kind == .Popup && .Hidden not_in field.flags && point_inside(&field, event.x, event.y) {
				inside_overlay = true
				break
			}
		}
	}
	if is_wheel_event(event) && ctx.hovered != nil && .Disabled not_in ctx.hovered.flags {
		direction := 1
		if .Direction_Down in event.buttons && .Direction_Up not_in event.buttons &&
		   ctx.hovered.kind != .Select && ctx.hovered.kind != .Option {
			direction = -1
		}
		handled := true
		#partial switch ctx.hovered.kind {
		case .Select, .Option:
			step_choice_input(ctx.hovered, direction)
		case .Integer_8, .Integer_16, .Integer_32, .Integer_64, .Float_Input:
			step_numeric_input(ctx.hovered, direction)
		case:
			handled = false
		}
		if handled {
			ctx.flags += {.Refresh}
			consume_event(event)
			return .None
		}
	}
	if .Mouse_Left in event.buttons {
		for reverse_index in 0 ..< len(form) {
			index := len(form) - 1 - reverse_index
			field := &form[index]
			if field.kind != .Popup || .Hidden in field.flags || !point_inside(field, event.x, event.y) {
				continue
			}
			title_height := 0
			if .Draggable in field.flags {
				title_height = 11
				if field.label > 0 && field.label < len(ctx.texts) {
					if _, text_height, _, _, measure_error := measure_label(ctx, field);
					   measure_error == .None {
						title_height = max(title_height, text_height + 2)
					}
				}
			}
			if title_height > 0 && event.y < field.computed_y + title_height {
				if event.x > field.computed_x + field.computed_width - title_height {
					field.flags += {.Hidden}
				} else {
					ctx.dragged = field
					ctx.drag_x = event.x - field.computed_x
					ctx.drag_y = event.y - field.computed_y
				}
				ctx.flags += {.Refresh}
				consume_event(event)
				return .None
			}
			if .Resizable in field.flags &&
			   event.x > field.computed_x + field.computed_width - 7 &&
			   event.y > field.computed_y + field.computed_height - 7 {
				ctx.resized = field
				ctx.drag_x = field.computed_x + field.computed_width - event.x
				ctx.drag_y = field.computed_y + field.computed_height - event.y
				ctx.flags += {.Refresh}
				consume_event(event)
				return .None
			}
			break
		}
		for reverse_index in 0 ..< len(form) {
			index := len(form) - 1 - reverse_index
			field := &form[index]
			if field.kind == .Popup && .Hidden not_in field.flags && point_inside(field, event.x, event.y) &&
			   begin_container_scrollbar_if_hit(ctx, field, event.x, event.y) {
				consume_event(event)
				return .None
			}
		}
		if ctx.menu != nil && !point_inside(ctx.menu, event.x, event.y) {
			close_menu(ctx)
			consume_event(event)
			return .None
		}
	}
	if event.kind == .Mouse &&
	   (.Direction_Up in event.buttons || .Direction_Down in event.buttons ||
	    .Gamepad_A in event.buttons || .Gamepad_B in event.buttons) {
		for reverse_index in 0 ..< len(form) {
			index := len(form) - 1 - reverse_index
			field := &form[index]
			if field.kind != .Popup || .Hidden in field.flags || !point_inside(field, event.x, event.y) {
				continue
			}
			vertical_step := max(field.computed_height / 10, 4)
			horizontal_step := max(field.computed_width / 10, 4)
			if .Direction_Up in event.buttons {
				field.offset_y -= vertical_step
			} else if .Direction_Down in event.buttons {
				field.offset_y += vertical_step
			} else if .Gamepad_A in event.buttons {
				field.offset_x -= horizontal_step
			} else if .Gamepad_B in event.buttons {
				field.offset_x += horizontal_step
			}
			field.offset_x = clamp(field.offset_x, 0, max(field.minimum_width - field.source_width, 0))
			field.offset_y = clamp(field.offset_y, 0, max(field.minimum_height - field.source_height, 0))
			ctx.flags += {.Refresh, .Recalculate}
			consume_event(event)
			return .None
		}
	}
	had_active_bar := ctx.horizontal_bar != nil || ctx.vertical_bar != nil
	if ctx.horizontal_bar != nil {
		if .Released in event.buttons {
			ctx.horizontal_bar = nil
		} else if ctx.horizontal_bar.kind == .Slider {
			update_slider(ctx.horizontal_bar, event.x)
			ctx.flags += {.Refresh}
		} else {
			update_scrollbar(ctx, event.x)
		}
	}
	if ctx.vertical_bar != nil {
		if .Released in event.buttons {
			ctx.vertical_bar = nil
		} else {
			update_scrollbar(ctx, event.y)
		}
	}
	if had_active_bar {
		ctx.flags += {.Refresh}
		consume_event(event)
		return .None
	}
	if .Mouse_Left in event.buttons {
		if ctx.hovered == nil || .Disabled in ctx.hovered.flags {
			deactivate_text_input(ctx, true)
			if inside_overlay {
				consume_event(event)
			}
			return .None
		}
		if ctx.hovered.kind != .Text_Input && !is_numeric_input_kind(ctx.hovered.kind) {
			deactivate_text_input(ctx, true)
		}
		clicked_menu_item :=
			ctx.menu != nil &&
			ctx.hovered != ctx.menu &&
			form_contains(ctx.menu.children, ctx.hovered)
		handled := true
		#partial switch ctx.hovered.kind {
		case .Toggle:
			toggle_bound_container(ctx, ctx.hovered)
		case .Button, .Toggle_Button:
			ctx.pressed = ctx.hovered
		case .Icon_Button:
			activate_checkbox(ctx.hovered)
		case .Checkbox:
			activate_checkbox(ctx.hovered)
		case .Radio:
			activate_radio(ctx.hovered)
		case .Slider:
			ctx.horizontal_bar = ctx.hovered
			update_slider(ctx.hovered, event.x)
		case .Horizontal_Scrollbar:
			begin_scrollbar(ctx, ctx.hovered, event.x)
		case .Vertical_Scrollbar:
			begin_scrollbar(ctx, ctx.hovered, event.y)
		case .Text_Input:
			activate_text_input(ctx, ctx.hovered)
		case .Select:
			deactivate_text_input(ctx, true)
			ctx.pressed = ctx.hovered
		case .Option:
			deactivate_text_input(ctx, true)
			if event.x < ctx.hovered.computed_x + ctx.hovered.computed_height {
				ctx.pressed = ctx.hovered
				ctx.pressed_part = -1
				step_choice_input(ctx.hovered, -1)
			} else if event.x >=
			   ctx.hovered.computed_x + ctx.hovered.computed_width - ctx.hovered.computed_height {
				ctx.pressed = ctx.hovered
				ctx.pressed_part = 1
				step_choice_input(ctx.hovered, 1)
			}
		case .Image, .Icon:
			activate_image_field(ctx.hovered)
		case .Color:
			open_color_popup(ctx, ctx.hovered)
		case .Integer_8, .Integer_16, .Integer_32, .Integer_64, .Float_Input:
			if event.x < ctx.hovered.computed_x + ctx.hovered.computed_height {
				deactivate_text_input(ctx, true)
				ctx.pressed = ctx.hovered
				ctx.pressed_part = -1
				step_numeric_input(ctx.hovered, -1)
			} else if event.x >=
			   ctx.hovered.computed_x + ctx.hovered.computed_width - ctx.hovered.computed_height {
				deactivate_text_input(ctx, true)
				ctx.pressed = ctx.hovered
				ctx.pressed_part = 1
				step_numeric_input(ctx.hovered, 1)
			} else if error := activate_numeric_input(ctx, ctx.hovered); error != .None {
				return error
			}
		case:
			handled = false
		}
		if clicked_menu_item {
			close_menu(ctx)
		}
		ctx.flags += {.Refresh}
		if handled {
			consume_event(event)
		}
	} else if .Released in event.buttons {
		was_pressed := ctx.pressed != nil
		if ctx.pressed != nil && ctx.pressed == ctx.hovered {
			if ctx.pressed.kind == .Button {
				activate_button(ctx.pressed)
			} else if ctx.pressed.kind == .Toggle_Button {
				toggle_bound_container(ctx, ctx.pressed)
			} else if ctx.pressed.kind == .Select {
				open_select_popup(ctx, ctx.pressed)
			}
		}
		ctx.pressed = nil
		ctx.pressed_part = 0
		ctx.flags += {.Refresh}
		if was_pressed {
			consume_event(event)
		}
	}
	if event.kind == .Mouse && .Mouse_Left in event.buttons && inside_overlay {
		consume_event(event)
	}
	return .None
}

@(private = "file")
open_color_popup :: proc(ctx: ^Context, field: ^Form) {
	value, valid := bound_color(field)
	if ctx == nil || !valid {
		return
	}
	ctx.color = value^
	ctx.color_hue, ctx.color_saturation, ctx.color_value = rgb_to_hsv(ctx.color)
	ctx.color_mode = 0
	set_color_edit(ctx)
	ctx.popup = field
	ctx.popup_x = field.computed_x
	ctx.popup_y = field.computed_y
	ctx.popup_width = 324
	ctx.popup_height = field.computed_height + 272
	if ctx.popup_x + ctx.popup_width + 2 >= ctx.screen.width {
		ctx.popup_x = ctx.screen.width - ctx.popup_width - 2
	}
	if ctx.popup_y + ctx.popup_height + 2 >= ctx.screen.height {
		ctx.popup_y = ctx.screen.height - ctx.popup_height - 2
	}
	if ctx.popup_x < 0 {
		ctx.popup_width += ctx.popup_x
		ctx.popup_x = 0
	}
	if ctx.popup_y < 0 {
		ctx.popup_height += ctx.popup_y
		ctx.popup_y = 0
	}
	ctx.flags += {.Refresh}
}

@(private = "file")
close_color_popup :: proc(ctx: ^Context, commit: bool) {
	if ctx == nil || ctx.popup == nil || ctx.popup.kind != .Color {
		return
	}
	if commit {
		if value, valid := bound_color(ctx.popup); valid {
			index := 0
			for index < len(ctx.color_history) && ctx.color_history[index] != ctx.color {
				index += 1
			}
			if index > 0 {
				limit := min(index, len(ctx.color_history) - 1)
				for reverse in 0 ..< limit {
					position := limit - reverse
					ctx.color_history[position] = ctx.color_history[position - 1]
				}
			}
			ctx.color_history[0] = ctx.color
			value^ = ctx.color
		}
	}
	ctx.popup = nil
	ctx.color_mode = 0
	ctx.flags += {.Refresh}
}

@(private = "file")
process_color_popup_event :: proc(ctx: ^Context, event: ^Event) -> Error {
	field := ctx.popup
	if field == nil || field.kind != .Color || event == nil {
		return .Invalid_Input
	}
	if event.kind == .Key {
		key := key_text(&event.key)
		if key == "Escape" || key == "\e" {
			close_color_popup(ctx, false)
			return .None
		}
		if key == "Enter" || key == "\n" || key == "\r" {
			parse_color_edit(ctx)
			close_color_popup(ctx, true)
			return .None
		}
		if key == "Backspace" || key == "\b" {
			if ctx.color_cursor > 0 {
				ctx.color_cursor -= 1
				ctx.color_edit[ctx.color_cursor] = '0'
				parse_color_edit(ctx)
			}
			ctx.flags += {.Refresh}
			return .None
		}
		for character in key {
			is_hex := (character >= '0' && character <= '9') ||
			          (character >= 'a' && character <= 'f') ||
			          (character >= 'A' && character <= 'F')
			if is_hex {
				if ctx.color_cursor >= len(ctx.color_edit) {
					ctx.color_cursor = 0
				}
				ctx.color_edit[ctx.color_cursor] = u8(character)
				ctx.color_cursor += 1
			}
		}
		parse_color_edit(ctx)
		ctx.flags += {.Refresh}
		return .None
	}
	if event.kind != .Mouse {
		return .None
	}
	inside := event.x >= ctx.popup_x && event.x < ctx.popup_x + ctx.popup_width &&
	          event.y >= ctx.popup_y && event.y < ctx.popup_y + ctx.popup_height
	if .Mouse_Left in event.buttons && !inside {
		close_color_popup(ctx, false)
		return .None
	}
	picker_y := ctx.popup_y + field.computed_height + 8
	picker_x := event.x - ctx.popup_x - 2
	picker_y_offset := event.y - picker_y
	if .Released in event.buttons {
		ctx.color_mode = 0
		return .None
	}
	if .Mouse_Left in event.buttons && picker_y_offset >= 0 && picker_y_offset < 256 {
		switch {
		case picker_x < 16:
			ctx.color_mode = 1
		case picker_x >= 20 && picker_x < 36:
			ctx.color_mode = 2
		case picker_x >= 38 && picker_x < 294:
			ctx.color_mode = 3
		case picker_x >= 296 && picker_x < 312:
			ctx.color_mode = 4
		}
	}
	if ctx.color_mode != 0 {
		saturation := clamp(event.x - ctx.popup_x - 40, 0, 255)
		picker_y_offset = clamp(picker_y_offset, 0, 255)
		switch ctx.color_mode {
		case 1:
			ctx.color = ctx.color_history[picker_y_offset >> 4]
			ctx.color_hue, ctx.color_saturation, ctx.color_value = rgb_to_hsv(ctx.color)
			ctx.color_mode = 0
		case 2:
			ctx.color = ctx.color & 0x00ffffff | u32(255 - picker_y_offset) << 24
		case 3:
			ctx.color_saturation = saturation
			ctx.color_value = 255 - picker_y_offset
			ctx.color = hsv_to_rgb(int(u8(ctx.color >> 24)), ctx.color_hue, ctx.color_saturation, ctx.color_value)
		case 4:
			ctx.color_hue = picker_y_offset
			ctx.color = hsv_to_rgb(int(u8(ctx.color >> 24)), ctx.color_hue, ctx.color_saturation, ctx.color_value)
		case:
		}
		set_color_edit(ctx)
		ctx.flags += {.Refresh}
	}
	return .None
}

@(private = "file")
activate_image_field :: proc(field: ^Form) {
	if field == nil || field.binding.kind != .Integer || field.binding.data == nil {
		return
	}
	(^int)(field.binding.data)^ = field.value
}

@(private = "file")
toggle_bound_container :: proc(ctx: ^Context, trigger: ^Form) {
	if trigger.binding.kind != .Forms || trigger.binding.data == nil {
		return
	}
	target := (^Form)(trigger.binding.data)
	if target.kind != .Popup && target.kind != .Menu && target.kind != .Division {
		return
	}
	if target.kind == .Menu {
		if ctx.menu == target && .Hidden not_in target.flags {
			close_menu(ctx)
			return
		}
		close_menu(ctx)
		target.flags -= {.Hidden}
		ctx.menu = target
		ctx.menu_anchor = trigger
		return
	}
	if .Hidden in target.flags {
		target.flags -= {.Hidden}
	} else {
		target.flags += {.Hidden}
	}
	if target.kind == .Division {
		ctx.flags += {.Recalculate}
	}
}

@(private = "file")
close_menu :: proc(ctx: ^Context) {
	if ctx.menu != nil {
		ctx.menu.flags += {.Hidden}
	}
	ctx.menu = nil
	ctx.menu_anchor = nil
}

@(private = "file")
form_contains :: proc(forms: []Form, target: ^Form) -> bool {
	if target == nil {
		return false
	}
	for &field in forms {
		if field.kind == .End {
			break
		}
		if &field == target {
			return true
		}
		if len(field.children) > 0 && form_contains(field.children, target) {
			return true
		}
	}
	return false
}

@(private = "file")
open_select_popup :: proc(ctx: ^Context, field: ^Form) {
	if field.binding.kind != .Integer || field.binding.data == nil || len(field.options) == 0 {
		return
	}
	field.selected_option = clamp(((^int)(field.binding.data))^, 0, len(field.options) - 1)
	x, y, width, height, _ := select_popup_geometry(ctx, field)
	ctx.popup_x = x
	ctx.popup_y = y
	ctx.popup_width = width
	ctx.popup_height = height
	ctx.popup = field
}

@(private = "file")
process_select_popup_event :: proc(ctx: ^Context, event: ^Event) -> Error {
	field := ctx.popup
	if field == nil || field.kind != .Select {
		ctx.popup = nil
		return .None
	}
	if event.kind == .Key {
		switch key_text(&event.key) {
		case "Up":
			field.selected_option = max(field.selected_option - 1, 0)
		case "Down":
			field.selected_option = min(field.selected_option + 1, len(field.options) - 1)
		case "Enter":
			((^int)(field.binding.data))^ = field.selected_option
			ctx.popup = nil
		case "Escape":
			ctx.popup = nil
		case:
		}
		return .None
	}
	if event.kind != .Mouse || .Mouse_Left not_in event.buttons {
		return .None
	}
	x, y, width, height, row_height := select_popup_geometry(ctx, field)
	if event.x >= x &&
	   event.x < x + width &&
	   event.y >= y + 2 &&
	   event.y < y + height - 1 {
		selected := (event.y - y - 2) / row_height
		field.selected_option = clamp(selected, 0, len(field.options) - 1)
		((^int)(field.binding.data))^ = field.selected_option
	}
	ctx.popup = nil
	return .None
}

@(private = "file")
step_choice_input :: proc(field: ^Form, direction: int) {
	if field.binding.kind != .Integer || field.binding.data == nil || len(field.options) == 0 {
		return
	}
	value := (^int)(field.binding.data)
	value^ += direction
	if value^ < 0 {
		value^ = len(field.options) - 1
	} else if value^ >= len(field.options) {
		value^ = 0
	}
}

@(private = "file")
move_text_cursor_to_mouse :: proc(ctx: ^Context, field: ^Form, mouse_x: int) {
	if ctx == nil || field == nil || ctx.font == nil || ctx.font_bounds == nil {
		return
	}
	buffer, valid := active_text_buffer(ctx, field)
	if !valid {
		return
	}
	target := mouse_x - field.computed_x - 2
	start := clamp(ctx.text_scroll, 0, len(buffer.data))
	cursor := start
	for cursor <= len(buffer.data) {
		width := 0
		height, left, top: int
		text := string(buffer.data[start:cursor])
		if ctx.font_bounds(ctx.font, text, &width, &height, &left, &top) != .None || width > target {
			break
		}
		if cursor == len(buffer.data) {
			break
		}
		cursor = next_codepoint(buffer.data[:], cursor)
	}
	ctx.text_cursor = clamp(cursor, 0, len(buffer.data))
}

@(private = "file")
activate_text_input :: proc(ctx: ^Context, field: ^Form) {
	buffer, valid := bound_text_buffer(field)
	if !valid {
		return
	}
	ctx.text_field = field
	ctx.text_cursor = len(buffer.data)
	ctx.text_scroll = 0
	if ctx.backend.show_keyboard != nil {
		_ = ctx.backend.show_keyboard(ctx.backend.data)
	}
}

@(private = "file")
activate_numeric_input :: proc(ctx: ^Context, field: ^Form) -> Error {
	if ctx.text_field != nil && ctx.text_field != field {
		deactivate_text_input(ctx, true)
	}
	if error := reset_numeric_edit_buffer(ctx, field); error != .None {
		return error
	}
	ctx.text_field = field
	ctx.text_cursor = len(ctx.edit_buffer.data)
	ctx.text_scroll = 0
	if ctx.backend.show_keyboard != nil {
		_ = ctx.backend.show_keyboard(ctx.backend.data)
	}
	return .None
}

@(private = "file")
reset_numeric_edit_buffer :: proc(ctx: ^Context, field: ^Form) -> Error {
	was_active := ctx.text_field == field
	if was_active {
		ctx.text_field = nil
	}
	text, valid := numeric_input_text(ctx, field)
	if was_active {
		ctx.text_field = field
	}
	if !valid {
		return .Invalid_Input
	}
	resize(&ctx.edit_buffer.data, 0)
	if (append(&ctx.edit_buffer.data, text) or_else -1) < 0 {
		return .Out_Of_Memory
	}
	ctx.text_cursor = len(ctx.edit_buffer.data)
	return .None
}

@(private = "file")
active_text_buffer :: proc(ctx: ^Context, field: ^Form) -> (^Text_Buffer, bool) {
	if is_numeric_input_kind(field.kind) {
		return &ctx.edit_buffer, true
	}
	return bound_text_buffer(field)
}

@(private = "file")
is_numeric_input_kind :: proc(kind: Field_Kind) -> bool {
	return(
		kind == .Integer_8 ||
		kind == .Integer_16 ||
		kind == .Integer_32 ||
		kind == .Integer_64 ||
		kind == .Float_Input \
	)
}

@(private = "file")
step_numeric_input :: proc(field: ^Form, direction: int) {
	if field.kind == .Float_Input {
		if field.binding.kind != .Float || field.binding.data == nil {
			return
		}
		increment := field.float_increment
		if increment == 0 {
			increment = 1
		}
		value := (^f32)(field.binding.data)
		value^ += f32(direction) * increment
		if field.float_maximum > field.float_minimum {
			value^ = clamp(value^, field.float_minimum, field.float_maximum)
		}
		return
	}
	value, valid := bound_integer(field)
	if !valid {
		return
	}
	increment := int(field.increment)
	if increment == 0 {
		increment = 1
	}
	value += direction * increment
	if field.maximum > field.minimum {
		value = clamp(value, int(field.minimum), int(field.maximum))
	}
	((^int)(field.binding.data))^ = value
}

@(private = "file")
commit_numeric_input :: proc(field: ^Form, text: string) {
	if field.kind == .Float_Input {
		if field.binding.kind != .Float || field.binding.data == nil {
			return
		}
		if value, ok := strconv.parse_f32(text); ok {
			if field.float_maximum > field.float_minimum {
				value = clamp(value, field.float_minimum, field.float_maximum)
			}
			((^f32)(field.binding.data))^ = value
		}
		return
	}
	if field.binding.kind != .Integer || field.binding.data == nil {
		return
	}
	if value, ok := strconv.parse_int(text, 10); ok {
		if field.maximum > field.minimum {
			value = clamp(value, int(field.minimum), int(field.maximum))
		}
		((^int)(field.binding.data))^ = value
	}
}

@(private = "file")
deactivate_text_input :: proc(ctx: ^Context, commit: bool) {
	if ctx.text_field == nil {
		return
	}
	if commit && is_numeric_input_kind(ctx.text_field.kind) {
		commit_numeric_input(ctx.text_field, text_buffer_string(&ctx.edit_buffer))
	}
	ctx.text_field = nil
	ctx.text_cursor = 0
	ctx.text_scroll = 0
	resize(&ctx.edit_buffer.data, 0)
	if ctx.backend.hide_keyboard != nil {
		_ = ctx.backend.hide_keyboard(ctx.backend.data)
	}
}

@(private = "file")
process_text_key :: proc(ctx: ^Context, event: ^Event) -> Error {
	field := ctx.text_field
	buffer, valid := active_text_buffer(ctx, field)
	if !valid {
		return .Invalid_Input
	}
	text := key_text(&event.key)
	switch text {
	case "Escape":
		deactivate_text_input(ctx, false)
	case "Enter":
		deactivate_text_input(ctx, true)
	case "Home":
		ctx.text_cursor = 0
	case "End":
		ctx.text_cursor = len(buffer.data)
	case "Left":
		ctx.text_cursor = previous_codepoint(buffer.data[:], ctx.text_cursor)
	case "Right":
		ctx.text_cursor = next_codepoint(buffer.data[:], ctx.text_cursor)
	case "Up":
		if is_numeric_input_kind(field.kind) {
			step_numeric_input(field, 1)
			if error := reset_numeric_edit_buffer(ctx, field); error != .None {
				return error
			}
		}
	case "Down":
		if is_numeric_input_kind(field.kind) {
			step_numeric_input(field, -1)
			if error := reset_numeric_edit_buffer(ctx, field); error != .None {
				return error
			}
		}
	case "Backspace":
		if ctx.text_cursor > 0 {
			start := previous_codepoint(buffer.data[:], ctx.text_cursor)
			remove_text_range(buffer, start, ctx.text_cursor)
			ctx.text_cursor = start
		}
	case "Delete":
		if ctx.text_cursor < len(buffer.data) {
			end := next_codepoint(buffer.data[:], ctx.text_cursor)
			remove_text_range(buffer, ctx.text_cursor, end)
		}
	case:
		filter := field.filter
		if is_numeric_input_kind(field.kind) {
			filter = .Integer
			if field.kind == .Float_Input {
				filter = .Decimal
			}
		}
		if len(text) > 0 && text_allowed(filter, buffer.data[:], text) {
			limit := buffer.max_length
			if field.max_length > 0 {
				limit = min(limit, field.max_length)
			}
			if len(buffer.data) + len(text) <= limit {
				old_length := len(buffer.data)
				if (append(&buffer.data, text) or_else -1) < 0 {
					return .Out_Of_Memory
				}
				copy(
					buffer.data[ctx.text_cursor + len(text):],
					buffer.data[ctx.text_cursor:old_length],
				)
				copy(buffer.data[ctx.text_cursor:], transmute([]u8)(text))
				ctx.text_cursor += len(text)
			}
		}
	}
	ctx.flags += {.Refresh}
	return .None
}

@(private = "file")
remove_text_range :: proc(buffer: ^Text_Buffer, start, end: int) {
	copy(buffer.data[start:], buffer.data[end:])
	resize(&buffer.data, len(buffer.data) - (end - start))
}

@(private = "file")
previous_codepoint :: proc(text: []u8, cursor: int) -> int {
	position := clamp(cursor, 0, len(text))
	if position == 0 {
		return 0
	}
	position -= 1
	for position > 0 && text[position] & 0xc0 == 0x80 {
		position -= 1
	}
	return position
}

@(private = "file")
next_codepoint :: proc(text: []u8, cursor: int) -> int {
	position := clamp(cursor, 0, len(text))
	if position >= len(text) {
		return len(text)
	}
	position += 1
	for position < len(text) && text[position] & 0xc0 == 0x80 {
		position += 1
	}
	return position
}

@(private = "file")
text_allowed :: proc(filter: Text_Filter, existing: []u8, text: string) -> bool {
	if len(text) == 0 || text[0] < ' ' {
		return false
	}
	character := text[0]
	switch filter {
	case .Identifier:
		return(
			character >= '0' && character <= '9' ||
			character >= 'a' && character <= 'z' ||
			character >= 'A' && character <= 'Z' ||
			len(existing) > 0 && character == '_' \
		)
	case .Variable:
		return(
			character >= 'a' && character <= 'z' ||
			character >= 'A' && character <= 'Z' ||
			len(existing) > 0 && (character == '_' || character >= '0' && character <= '9') \
		)
	case .Hexadecimal:
		return(
			character >= '0' && character <= '9' ||
			character >= 'a' && character <= 'f' ||
			character >= 'A' && character <= 'F' \
		)
	case .Integer:
		return character >= '0' && character <= '9' || len(existing) == 0 && character == '-'
	case .Decimal:
		return(
			character >= '0' && character <= '9' ||
			len(existing) == 0 && character == '-' ||
			character == '.' && !strings.contains(string(existing), ".") ||
			character == 'e' ||
			character == 'E' ||
			character == '+' \
		)
	case .Expression:
		return(
			character >= '0' && character <= '9' ||
			character >= 'a' && character <= 'z' ||
			character >= 'A' && character <= 'Z' ||
			strings.contains_rune("._()+-*/%@<>=!&|,", rune(character)) \
		)
	case .None, .Password:
		return len(existing) > 0 || character != ' '
	}
	return false
}

@(private = "file")
begin_container_scrollbar_if_hit :: proc(ctx: ^Context, field: ^Form, mouse_x, mouse_y: int) -> bool {
	if field.source_height > 0 &&
	   mouse_x >= field.content_x + field.content_width &&
	   mouse_x < field.content_x + field.content_width + ctx.scrollbar_width &&
	   mouse_y >= field.content_y && mouse_y < field.content_y + field.source_height {
		begin_container_scrollbar(ctx, field, true, mouse_y)
		return true
	}
	if field.source_width > 0 &&
	   mouse_x >= field.content_x && mouse_x < field.content_x + field.source_width &&
	   mouse_y >= field.content_y + field.content_height &&
	   mouse_y < field.content_y + field.content_height + ctx.scrollbar_height {
		begin_container_scrollbar(ctx, field, false, mouse_x)
		return true
	}
	return false
}

@(private = "file")
begin_container_scrollbar :: proc(ctx: ^Context, field: ^Form, vertical: bool, mouse_position: int) {
	size := field.source_width
	maximum := field.minimum_width
	current := field.offset_x
	minimum_thumb := ctx.scrollbar_height
	origin := field.content_x
	if vertical {
		size = field.source_height
		maximum = field.minimum_height
		current = field.offset_y
		minimum_thumb = ctx.scrollbar_width
		origin = field.content_y
		ctx.vertical_bar = field
	} else {
		ctx.horizontal_bar = field
	}
	position, thumb := scrollbar_metrics(size, current, maximum, minimum_thumb)
	if mouse_position >= origin + position && mouse_position < origin + position + thumb {
		ctx.scrollbar_grab = mouse_position - origin - position
	} else {
		ctx.scrollbar_grab = thumb / 2
	}
	ctx.scrollbar_range = maximum - size
	ctx.scrollbar_start = origin
	ctx.scrollbar_end = origin + size - thumb + ctx.scrollbar_grab
	update_scrollbar(ctx, mouse_position)
}

@(private = "file")
begin_scrollbar :: proc(ctx: ^Context, field: ^Form, mouse_position: int) {
	if ctx == nil || field == nil {
		return
	}
	vertical := field.kind == .Vertical_Scrollbar
	size := field.computed_width
	minimum_thumb := ctx.scrollbar_height
	origin := field.computed_x
	if vertical {
		size = field.computed_height
		minimum_thumb = ctx.scrollbar_width
		origin = field.computed_y
		ctx.vertical_bar = field
	} else {
		ctx.horizontal_bar = field
	}
	value, valid := bound_integer(field)
	if !valid {
		value = 0
	}
	position, thumb := scrollbar_metrics(size, value, int(field.maximum), minimum_thumb)
	if mouse_position >= origin + position && mouse_position < origin + position + thumb {
		ctx.scrollbar_grab = mouse_position - origin - position
	} else {
		ctx.scrollbar_grab = thumb / 2
	}
	ctx.scrollbar_range = int(field.maximum) - size
	ctx.scrollbar_start = origin
	ctx.scrollbar_end = origin + size - thumb + ctx.scrollbar_grab
	update_scrollbar(ctx, mouse_position)
}

@(private = "file")
update_scrollbar :: proc(ctx: ^Context, mouse_position: int) {
	field := ctx.horizontal_bar
	if field == nil {
		field = ctx.vertical_bar
	}
	if field == nil || ctx.scrollbar_range <= 0 {
		return
	}
	position := mouse_position - ctx.scrollbar_grab + 1
	position = min(position, ctx.scrollbar_end)
	position = max(position - ctx.scrollbar_start, 0)
	track := max(ctx.scrollbar_end - ctx.scrollbar_start - ctx.scrollbar_grab, 1)
	value := min(position * ctx.scrollbar_range / track, ctx.scrollbar_range)
	if field.kind == .Popup {
		if ctx.horizontal_bar == field {
			field.offset_x = value
		} else {
			field.offset_y = value
		}
		ctx.flags += {.Recalculate}
	} else if field.binding.kind == .Integer && field.binding.data != nil {
		((^int)(field.binding.data))^ = value
	}
	ctx.flags += {.Refresh}
}

@(private = "file")
update_slider :: proc(field: ^Form, mouse_x: int) {
	if field.binding.kind != .Integer || field.binding.data == nil {
		return
	}
	minimum := int(field.minimum)
	maximum := int(field.maximum)
	if maximum <= minimum {
		return
	}
	track_width := max(field.computed_width - 9, 1)
	position := clamp(mouse_x - field.computed_x - 3, 0, track_width)
	value := minimum + position * (maximum - minimum) / track_width
	((^int)(field.binding.data))^ = clamp(value, minimum, maximum)
}

@(private = "file")
activate_button :: proc(field: ^Form) {
	if field.binding.data == nil {
		return
	}
	#partial switch field.binding.kind {
	case .Boolean:
		((^bool)(field.binding.data))^ = true
	case .Integer:
		((^int)(field.binding.data))^ = field.value
	case:
	}
}

@(private = "file")
activate_checkbox :: proc(field: ^Form) {
	if field.binding.data == nil {
		return
	}
	#partial switch field.binding.kind {
	case .Boolean:
		value := (^bool)(field.binding.data)
		value^ = !value^
	case .Integer:
		value := (^int)(field.binding.data)
		mask := field.value
		if mask == 0 {
			mask = 1
		}
		value^ = value^ ~ mask
	case:
	}
}

@(private = "file")
activate_radio :: proc(field: ^Form) {
	if field.binding.kind == .Integer && field.binding.data != nil {
		((^int)(field.binding.data))^ = field.value
	}
}

@(private = "file")
point_inside :: proc(field: ^Form, x, y: int) -> bool {
	return(
		x >= field.computed_x &&
		x < field.computed_x + field.computed_width &&
		y >= field.computed_y &&
		y < field.computed_y + field.computed_height \
	)
}

@(private = "file")
draw_outline_rectangle :: proc(ctx: ^Context, x, y, width, height: int, light, color, dark: u32) {
	if width < 2 ||
	   height < 2 ||
	   x >= ctx.screen.width ||
	   y >= ctx.screen.height ||
	   x + width < 0 ||
	   y + height < 0 {
		return
	}
	top_right := min(x + width - 1, ctx.screen.width - 1)
	for pixel_x in x ..< top_right {
		blend_pixel(ctx, pixel_x, y, light)
	}
	for offset in 0 ..< width - 1 {
		blend_pixel(ctx, x + offset + 1, y + height - 1, dark)
	}
	blend_pixel(ctx, top_right, y, color)
	blend_pixel(ctx, x, y + height - 1, color)
	for offset in 1 ..< height - 1 {
		blend_pixel(ctx, x, y + offset, light)
		blend_pixel(ctx, x + width - 1, y + offset, dark)
	}
}

@(private = "file")
draw_beveled_rectangle :: proc(ctx: ^Context, x, y, width, height: int, light, color, dark: u32) {
	fill_rectangle(ctx, x, y, width, height, color)
	fill_rectangle(ctx, x, y, width, 1, light)
	fill_rectangle(ctx, x, y, 1, height, light)
	fill_rectangle(ctx, x, y + height - 1, width, 1, dark)
	fill_rectangle(ctx, x + width - 1, y, 1, height, dark)
}

@(private = "file")
blend_line_pixel :: proc(ctx: ^Context, x, y: int, color: u32, coverage: int) {
	if coverage <= 0 ||
	   x < ctx.clip_x0 || y < ctx.clip_y0 || x >= ctx.clip_x1 || y >= ctx.clip_y1 ||
	   x < 0 || y < 0 || x >= ctx.screen.width || y >= ctx.screen.height {
		return
	}
	source_alpha := int(u8(color >> 24))
	alpha := clamp(coverage, 0, 255) * source_alpha / 255
	inverse := 255 - alpha
	pixel := y * ctx.screen.pitch + x * 4
	for channel in 0 ..< 4 {
		source := int(u8(color >> u32(channel * 8)))
		destination := int(ctx.screen.pixels[pixel + channel])
		ctx.screen.pixels[pixel + channel] = u8((source * alpha + inverse * destination) >> 8)
	}
}

@(private = "file")
draw_antialiased_line :: proc(ctx: ^Context, start_x, start_y, end_x, end_y: int, color: u32) {
	if u8(color >> 24) == 0 || (start_x == end_x && start_y == end_y) {
		return
	}
	x, y := start_x, start_y
	step_x := -1
	if start_x < end_x {
		step_x = 1
	}
	step_y := -1
	if start_y < end_y {
		step_y = 1
	}
	delta_x := abs(end_x - start_x)
	delta_y := abs(end_y - start_y)
	error_squared := delta_x * delta_x + delta_y * delta_y
	scale := 1
	if error_squared != 0 {
		scale = int(f64(0xffff7f) / math.sqrt(f64(error_squared)))
	}
	delta_x *= scale
	delta_y *= scale
	error := delta_x - delta_y
	for {
		pixel_coverage := 255 - (abs(error - delta_x + delta_y) >> 16)
		blend_line_pixel(ctx, x, y, color, pixel_coverage)
		previous_error := error
		previous_x := x
		if 2 * previous_error >= -delta_x {
			if x == end_x {
				break
			}
			neighbor_y := y + step_y
			if previous_error + delta_y < 0xff0000 {
				blend_line_pixel(ctx, x, neighbor_y, color, 255 - ((previous_error + delta_y) >> 16))
			}
			error -= delta_y
			x += step_x
		}
		if 2 * previous_error <= delta_y {
			if y == end_y {
				break
			}
			neighbor_x := previous_x + step_x
			if delta_x - previous_error < 0xff0000 {
				blend_line_pixel(ctx, neighbor_x, y, color, 255 - ((delta_x - previous_error) >> 16))
			}
			error += delta_x
			y += step_y
		}
	}
}

@(private = "file")
draw_bezier_recursive :: proc(
	ctx: ^Context,
	color: u32,
	x0, y0, x1, y1, x2, y2, x3, y3, level: int,
) {
	if level < 8 && (x0 != x3 || y0 != y3) {
		m0x, m0y := (x1 - x0) / 2 + x0, (y1 - y0) / 2 + y0
		m1x, m1y := (x2 - x1) / 2 + x1, (y2 - y1) / 2 + y1
		m2x, m2y := (x3 - x2) / 2 + x2, (y3 - y2) / 2 + y2
		m3x, m3y := (m1x - m0x) / 2 + m0x, (m1y - m0y) / 2 + m0y
		m4x, m4y := (m2x - m1x) / 2 + m1x, (m2y - m1y) / 2 + m1y
		m5x, m5y := (m4x - m3x) / 2 + m3x, (m4y - m3y) / 2 + m3y
		draw_bezier_recursive(ctx, color, x0, y0, m0x, m0y, m3x, m3y, m5x, m5y, level + 1)
		draw_bezier_recursive(ctx, color, m5x, m5y, m4x, m4y, m2x, m2y, x3, y3, level + 1)
	}
	if level > 0 {
		draw_antialiased_line(ctx, ctx.curve_x >> 8, ctx.curve_y >> 8, x3 >> 8, y3 >> 8, color)
		ctx.curve_x, ctx.curve_y = x3, y3
	}
}

@(private = "file")
draw_cubic_bezier :: proc(
	ctx: ^Context,
	x0, y0, x1, y1, control_x0, control_y0, control_x1, control_y1: int,
	color: u32,
) {
	if u8(color >> 24) == 0 {
		return
	}
	ctx.curve_x, ctx.curve_y = x0 << 8, y0 << 8
	draw_bezier_recursive(
		ctx,
		color,
		x0 << 8,
		y0 << 8,
		control_x0 << 8,
		control_y0 << 8,
		control_x1 << 8,
		control_y1 << 8,
		x1 << 8,
		y1 << 8,
		0,
	)
}

@(private = "file")
draw_line_field :: proc(ctx: ^Context, field: ^Form) {
	color := u32(field.value)
	#partial switch field.kind {
	case .Lines:
		for index := 0; index + 3 < len(field.points); index += 2 {
			if field.points[index + 2] == 0 && field.points[index + 3] == 0 {
				break
			}
			draw_antialiased_line(
				ctx,
				int(field.points[index]),
				int(field.points[index + 1]),
				int(field.points[index + 2]),
				int(field.points[index + 3]),
				color,
			)
		}
	case .Vertical_Connector, .Horizontal_Connector:
		if len(field.points) < 4 {
			return
		}
		x0, y0 := int(field.points[0]), int(field.points[1])
		x1, y1 := int(field.points[2]), int(field.points[3])
		if x0 > x1 {
			x0, x1 = x1, x0
		}
		if y0 > y1 {
			y0, y1 = y1, y0
		}
		if field.kind == .Horizontal_Connector {
			draw_cubic_bezier(ctx, x0, y0, x1, y1, x1, y0, x0, y1, color)
		} else {
			draw_cubic_bezier(ctx, x0, y0, x1, y1, x0, y1, x1, y0, color)
		}
	case .Curve:
		if len(field.points) < 8 {
			return
		}
		draw_cubic_bezier(
			ctx,
			int(field.points[0]),
			int(field.points[1]),
			int(field.points[2]),
			int(field.points[3]),
			int(field.points[4]),
			int(field.points[5]),
			int(field.points[6]),
			int(field.points[7]),
			color,
		)
	}
}

@(private = "file")
draw_font :: proc(
	ctx: ^Context,
	font: rawptr,
	text: string,
	destination: []u8,
	color: u32,
	x, y, left, top, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) -> Error {
	if ctx == nil || ctx.font_draw == nil {
		return .Invalid_Input
	}
	return ctx.font_draw(
		font,
		text,
		destination,
		color,
		x,
		y,
		left,
		top,
		pitch,
		max(crop_x0, ctx.clip_x0),
		max(crop_y0, ctx.clip_y0),
		min(crop_x1, ctx.clip_x1),
		min(crop_y1, ctx.clip_y1),
	)
}

@(private = "file")
set_pixel :: proc(ctx: ^Context, x, y: int, color: u32) {
	if x < ctx.clip_x0 || y < ctx.clip_y0 || x >= ctx.clip_x1 || y >= ctx.clip_y1 ||
	   x < 0 || y < 0 || x >= ctx.screen.width || y >= ctx.screen.height {
		return
	}
	pixel := y * ctx.screen.pitch + x * 4
	ctx.screen.pixels[pixel + 0] = u8(color)
	ctx.screen.pixels[pixel + 1] = u8(color >> 8)
	ctx.screen.pixels[pixel + 2] = u8(color >> 16)
	ctx.screen.pixels[pixel + 3] = u8(color >> 24)
}

@(private = "file")
blend_pixel :: proc(ctx: ^Context, x, y: int, color: u32) {
	alpha := u32(u8(color >> 24))
	if alpha == 0 ||
	   x < ctx.clip_x0 || y < ctx.clip_y0 || x >= ctx.clip_x1 || y >= ctx.clip_y1 ||
	   x < 0 || y < 0 || x >= ctx.screen.width || y >= ctx.screen.height {
		return
	}
	inverse := 255 - alpha
	pixel := y * ctx.screen.pitch + x * 4
	for channel in 0 ..< 4 {
		source := u32(u8(color >> u32(channel * 8)))
		destination := u32(ctx.screen.pixels[pixel + channel])
		ctx.screen.pixels[pixel + channel] = u8((source * alpha + inverse * destination) >> 8)
	}
}

@(private = "file")
fill_rectangle :: proc(ctx: ^Context, x, y, width, height: int, color: u32) {
	x0 := clamp(x, ctx.clip_x0, ctx.clip_x1)
	y0 := clamp(y, ctx.clip_y0, ctx.clip_y1)
	x1 := clamp(x + width, ctx.clip_x0, ctx.clip_x1)
	y1 := clamp(y + height, ctx.clip_y0, ctx.clip_y1)
	for pixel_y in y0 ..< y1 {
		for pixel_x in x0 ..< x1 {
			blend_pixel(ctx, pixel_x, pixel_y, color)
		}
	}
}
