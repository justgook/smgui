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
  [x] Labels, buttons, checkboxes, and radio buttons render
  [x] Buttons, checkboxes, radio buttons, and sliders mutate bound state
  [x] Integer/float displays, sliders, and progress bars render
  [x] UTF-8 text input, cursor editing, and input filters implemented
  [ ] Remaining drawing primitives implemented
  [x] Relative flow layout and division containers implemented
  [ ] Popup/menu layout, scrolling, and advanced alignment implemented
  [ ] Remaining widget interaction and event processing implemented
  [ ] Remaining built-in widgets implemented

Definition of done:
  - `make check` passes
  - Every public operation has behavioral parity coverage
  - Deterministic framebuffer fixtures match reference-c
  - No operation reports success before doing its documented work
*/

import "core:fmt"
import "core:strings"

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
	margin:               int,
	pitch:                int,
	left, top:            int,
	description:          int,
	computed_x:           int,
	computed_y:           int,
	computed_width:       int,
	computed_height:      int,
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
	theme:          [THEME_COLOR_COUNT]u32,
	texts:          []string,
	font:           rawptr,
	font_bounds:    Font_Bounds_Proc,
	font_draw:      Font_Draw_Proc,
	form:           []Form,
	menu:           ^Form,
	hovered:        ^Form,
	dragged:        ^Form,
	resized:        ^Form,
	pressed:        ^Form,
	vertical_bar:   ^Form,
	horizontal_bar: ^Form,
	text_field:     ^Form,
	text_cursor:    int,
	popup:          ^Form,
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

percent :: proc(value: int, offset: int = 0) -> Position {
	return {mode = .Percent, value = i32(value), offset = i32(offset)}
}

bind :: proc {
	bind_boolean,
	bind_integer,
	bind_float,
	bind_text,
}

bind_boolean :: proc(value: ^bool) -> Binding {
	return {kind = .Boolean, data = value}
}

bind_integer :: proc(value: ^int) -> Binding {
	return {kind = .Integer, data = value}
}

bind_float :: proc(value: ^f32) -> Binding {
	return {kind = .Float, data = value}
}

bind_text :: proc(value: ^Text_Buffer) -> Binding {
	return {kind = .Text, data = value}
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
	if ctx == nil || cursor == nil {
		return .Invalid_Input
	}
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_hwcursor")
use_hardware_cursor :: proc(ctx: ^Context) -> Error {
	if ctx == nil || ctx.backend.show_cursor == nil {
		return .Invalid_Input
	}
	return ctx.backend.show_cursor(ctx.backend.data)
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
	return refresh(ctx)
}

@(require_results, tag = "reference:ui_pngskin")
set_png_skin :: proc(ctx: ^Context, png: []u8) -> Error {
	if ctx == nil || len(png) == 0 {
		return .Invalid_Input
	}
	return .Not_Implemented
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
	ctx.backend = backend
	ctx.texts = texts
	ctx.theme = DEFAULT_THEME
	ctx.flags = {.Refresh, .Recalculate}

	if error := ctx.backend.init(ctx.backend.data, ctx, texts[0], width, height, icon);
	   error != .None {
		delete(ctx.screen.pixels)
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
	backend_error := Error.None
	if ctx.backend.deinit != nil {
		backend_error = ctx.backend.deinit(ctx.backend.data)
	}
	if ctx.screen.pixels != nil {
		delete(ctx.screen.pixels)
	}
	ctx^ = {}
	return backend_error
}

@(require_results)
render :: proc(ctx: ^Context, form: []Form) -> Error {
	if ctx == nil || len(ctx.screen.pixels) == 0 {
		return .Invalid_Input
	}
	fill_rectangle(
		ctx,
		0,
		0,
		ctx.screen.width,
		ctx.screen.height,
		ctx.theme[int(Theme_Color.Background)],
	)
	if _, _, error := layout_forms(ctx, form, 0, 0, ctx.screen.width, ctx.screen.height, 8);
	   error != .None {
		return error
	}
	if error := draw_forms(ctx, form); error != .None {
		return error
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
		return extent - int(position.value)
	case .Relative, .Absolute:
		return int(position.value) + int(position.offset)
	}
	return int(position.value)
}

@(private = "file")
layout_forms :: proc(
	ctx: ^Context,
	forms: []Form,
	x, y, width, height, gap: int,
) -> (
	used_width, used_height: int,
	error: Error,
) {
	cursor_x := x
	cursor_y := y
	row_height := 0
	content_right := x
	content_bottom := y

	for &field in forms {
		if field.kind == .End {
			break
		}
		if .Hidden in field.flags {
			continue
		}
		field_width, field_height, measure_error := measure_form(ctx, &field, width, height)
		if measure_error != .None {
			return 0, 0, measure_error
		}
		is_flow := field.x.mode == .Relative && field.y.mode == .Relative
		field_x, field_y: int
		if is_flow {
			field_x = cursor_x + int(field.x.value) + int(field.x.offset)
			field_y = cursor_y + int(field.y.value) + int(field.y.offset)
			if cursor_x > x && field_x + field_width > x + width {
				cursor_x = x
				cursor_y += row_height + gap
				row_height = 0
				field_x = cursor_x + int(field.x.value) + int(field.x.offset)
				field_y = cursor_y + int(field.y.value) + int(field.y.offset)
			}
		} else {
			field_x = x + resolve_position(field.x, width)
			field_y = y + resolve_position(field.y, height)
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

		field.computed_x = field_x
		field.computed_y = field_y
		field.computed_width = field_width
		field.computed_height = field_height

		if field.kind == .Division {
			inner_margin := max(field.margin, 1)
			inner_x := field_x + inner_margin
			inner_y := field_y + inner_margin
			inner_width := max(field_width - inner_margin * 2, 0)
			inner_height := max(field_height - inner_margin * 2, 0)
			if _, _, child_error := layout_forms(
				ctx,
				field.children,
				inner_x,
				inner_y,
				inner_width,
				inner_height,
				gap,
			); child_error != .None {
				return 0, 0, child_error
			}
		}

		content_right = max(content_right, field_x + field_width)
		content_bottom = max(content_bottom, field_y + field_height)
		if is_flow {
			row_height = max(row_height, field_height + int(field.y.value) + int(field.y.offset))
			if .No_Break in field.flags && .Force_Break not_in field.flags {
				cursor_x = field_x + field_width + gap
			} else {
				cursor_x = x
				cursor_y += row_height + gap
				row_height = 0
			}
		}
	}
	return content_right - x, content_bottom - y, .None
}

@(private = "file")
measure_form :: proc(
	ctx: ^Context,
	field: ^Form,
	available_width, available_height: int,
) -> (
	int,
	int,
	Error,
) {
	width := field.width
	height := field.height
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
			height = text_height
		}
	case .Button:
		text_width, text_height, _, _, error := measure_label(ctx, field)
		if error != .None {
			return 0, 0, error
		}
		if width < 1 {
			width = text_width + 20
		}
		if height < 1 {
			height = text_height + 10
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
		}
	case .Text_Input:
		if field.binding.kind != .Text ||
		   field.binding.data == nil ||
		   ctx.font == nil ||
		   ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
		text_width, text_height, left, top: int
		if bounds_error := ctx.font_bounds(ctx.font, "Ag", &text_width, &text_height, &left, &top);
		   bounds_error != .None {
			return 0, 0, bounds_error
		}
		field.left = left
		field.top = top
		if width < 1 {
			width = min(max(available_width, 120), 240)
		}
		if height < 1 {
			height = text_height + 8
		}
	case .Slider, .Progress_Bar:
		if width < 1 {
			width = min(max(available_width, 100), 180)
		}
		if height < 1 {
			height = 20
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
		text, format_error := format_bound_value(field)
		if format_error != .None || ctx.font == nil || ctx.font_bounds == nil {
			return 0, 0, .Invalid_Input
		}
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
			height = text_height
		}
	case .Division:
		if width < 1 {
			width = available_width
		}
		if height < 1 {
			height = available_height
		}
	}
	return max(width, 0), max(height, 0), .None
}

@(private = "file")
measure_label :: proc(
	ctx: ^Context,
	field: ^Form,
) -> (
	width, height, left, top: int,
	error: Error,
) {
	if field.label < 0 ||
	   field.label >= len(ctx.texts) ||
	   ctx.font == nil ||
	   ctx.font_bounds == nil {
		return 0, 0, 0, 0, .Invalid_Input
	}
	error = ctx.font_bounds(ctx.font, ctx.texts[field.label], &width, &height, &left, &top)
	return
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
			draw_beveled_rectangle(
				ctx,
				field.computed_x,
				field.computed_y,
				field.computed_width,
				field.computed_height,
				ctx.theme[int(Theme_Color.Input_Light_Border)],
				ctx.theme[int(Theme_Color.Input_Background)],
				ctx.theme[int(Theme_Color.Input_Dark_Border)],
			)
			if error := draw_forms(ctx, field.children); error != .None {
				return error
			}
		case .Label:
			if error := draw_label(ctx, &field); error != .None {
				return error
			}
		case .Button:
			if error := draw_button(ctx, &field); error != .None {
				return error
			}
		case .Checkbox, .Radio:
			if error := draw_choice(ctx, &field); error != .None {
				return error
			}
		case .Text_Input:
			if error := draw_text_input(ctx, &field); error != .None {
				return error
			}
		case .Slider:
			draw_slider(ctx, &field)
		case .Progress_Bar:
			if error := draw_progress_bar(ctx, &field); error != .None {
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
draw_label :: proc(ctx: ^Context, field: ^Form) -> Error {
	if field.label < 0 ||
	   field.label >= len(ctx.texts) ||
	   ctx.font == nil ||
	   ctx.font_bounds == nil ||
	   ctx.font_draw == nil {
		return .Invalid_Input
	}
	text := ctx.texts[field.label]
	_, _, left, top, error := measure_label(ctx, field)
	if error != .None {
		return error
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if .Disabled in field.flags {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	return ctx.font_draw(
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		field.computed_x,
		field.computed_y,
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
draw_button :: proc(ctx: ^Context, field: ^Form) -> Error {
	if field.label < 0 ||
	   field.label >= len(ctx.texts) ||
	   ctx.font == nil ||
	   ctx.font_bounds == nil ||
	   ctx.font_draw == nil {
		return .Invalid_Input
	}
	text := ctx.texts[field.label]
	text_width, text_height, left, top: int
	if error := ctx.font_bounds(ctx.font, text, &text_width, &text_height, &left, &top);
	   error != .None {
		return error
	}
	width := field.computed_width
	height := field.computed_height
	x := field.computed_x
	y := field.computed_y
	disabled := .Disabled in field.flags
	pressed := ctx.pressed == field
	foreground := ctx.theme[int(Theme_Color.Button_Foreground)]
	light := ctx.theme[int(Theme_Color.Button_Light_Inner_Border)]
	background := ctx.theme[int(Theme_Color.Button_Light_Background)]
	dark := ctx.theme[int(Theme_Color.Button_Dark_Inner_Border)]
	if disabled {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		background = ctx.theme[int(Theme_Color.Disabled_Background)]
	} else if pressed {
		light, dark = dark, light
		background = ctx.theme[int(Theme_Color.Button_Dark_Background)]
	} else if ctx.hovered == field {
		light = ctx.theme[int(Theme_Color.Button_Selected_Border)]
	}
	draw_beveled_rectangle(ctx, x, y, width, height, light, background, dark)
	text_offset := 0
	if pressed {
		text_offset = 1
	}
	return ctx.font_draw(
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		x + (width - text_width) / 2 + text_offset,
		y + (height - text_height) / 2 + text_offset,
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
	center_x := x + height / 2
	center_y := y + height / 2
	if field.kind == .Checkbox {
		draw_checkbox(ctx, center_x, center_y, selected, disabled)
	} else {
		draw_radio(ctx, center_x, center_y, selected, disabled)
	}
	foreground := ctx.theme[int(Theme_Color.Foreground)]
	if disabled {
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
	}
	return ctx.font_draw(
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		x + height,
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
	background := ctx.theme[int(Theme_Color.Input_Background)]
	foreground := ctx.theme[int(Theme_Color.Input_Foreground)]
	dark := ctx.theme[int(Theme_Color.Input_Dark_Border)]
	light := ctx.theme[int(Theme_Color.Input_Light_Border)]
	if disabled {
		background = ctx.theme[int(Theme_Color.Disabled_Background)]
		foreground = ctx.theme[int(Theme_Color.Disabled_Foreground)]
		dark = foreground
		light = foreground
	}
	draw_beveled_rectangle(
		ctx,
		field.computed_x,
		field.computed_y,
		field.computed_width,
		field.computed_height,
		dark,
		background,
		light,
	)
	text := text_buffer_string(buffer)
	text_height := max(field.computed_height - 8, 1)
	if error := ctx.font_draw(
		ctx.font,
		text,
		ctx.screen.pixels,
		foreground,
		field.computed_x + 4,
		field.computed_y + (field.computed_height - text_height) / 2,
		field.left,
		field.top,
		ctx.screen.pitch,
		field.computed_x + 2,
		field.computed_y + 1,
		field.computed_x + field.computed_width - 2,
		field.computed_y + field.computed_height - 1,
	); error != .None {
		return error
	}
	if ctx.text_field == field && !disabled {
		cursor := clamp(ctx.text_cursor, 0, len(text))
		cursor_width, cursor_height, left, top: int
		if error := ctx.font_bounds(
			ctx.font,
			text[:cursor],
			&cursor_width,
			&cursor_height,
			&left,
			&top,
		); error != .None {
			return error
		}
		cursor_x := field.computed_x + 4 + cursor_width
		fill_rectangle(
			ctx,
			cursor_x,
			field.computed_y + 3,
			1,
			field.computed_height - 6,
			ctx.theme[int(Theme_Color.Input_Cursor)],
		)
	}
	return .None
}

@(private = "file")
draw_slider :: proc(ctx: ^Context, field: ^Form) {
	x := field.computed_x
	y := field.computed_y
	width := field.computed_width
	height := field.computed_height
	disabled := .Disabled in field.flags
	track_color := ctx.theme[int(Theme_Color.Scrollbar_Background)]
	if disabled {
		track_color = ctx.theme[int(Theme_Color.Disabled_Background)]
	}
	track_y := y + height / 2 - 2
	draw_beveled_rectangle(
		ctx,
		x + 4,
		track_y,
		max(width - 8, 1),
		5,
		ctx.theme[int(Theme_Color.Input_Dark_Border)],
		track_color,
		ctx.theme[int(Theme_Color.Input_Light_Border)],
	)
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
	knob_x := x + 5 + (width - 11) * (value - minimum) / (maximum - minimum)
	draw_radio(ctx, knob_x, y + height / 2, true, disabled)
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
	filled := (width - 2) * (value - minimum) / (maximum - minimum)
	draw_beveled_rectangle(
		ctx,
		x,
		y,
		width,
		height,
		ctx.theme[int(Theme_Color.Progress_Light)],
		ctx.theme[int(Theme_Color.Progress_Background)],
		ctx.theme[int(Theme_Color.Progress_Dark)],
	)
	fill_rectangle(
		ctx,
		x + 1,
		y + 1,
		filled,
		max(height - 2, 0),
		ctx.theme[int(Theme_Color.Progress_Light)],
	)
	percentage := (value - minimum) * 100 / (maximum - minimum)
	text := fmt.tprintf("%d%%", percentage)
	return draw_text_centered(ctx, text, field, ctx.theme[int(Theme_Color.Input_Foreground)])
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
	return draw_text_centered(ctx, text, field, foreground)
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
	return ctx.font_draw(
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
		return fmt.tprintf("%.3f", ((^f32)(field.binding.data))^), .None
	}
	value, valid := bound_integer(field)
	if !valid {
		return "", .Invalid_Input
	}
	#partial switch field.kind {
	case .Hexadecimal_8:
		return fmt.tprintf("%02X", value), .None
	case .Hexadecimal_16:
		return fmt.tprintf("%04X", value), .None
	case .Hexadecimal_32:
		return fmt.tprintf("%08X", value), .None
	case .Hexadecimal_64:
		return fmt.tprintf("%016X", value), .None
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
	draw_beveled_rectangle(ctx, x - 5, y - 5, 9, 9, border_dark, background, border_light)
	if checked {
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
	for row in -4 ..= 4 {
		span := 4
		if abs(row) == 4 {
			span = 2
		} else if abs(row) == 3 {
			span = 3
		}
		for column in -span ..= span {
			color := background
			if abs(column) == span {
				color = border
			} else if row == 4 {
				color = light
			}
			if checked && abs(row) <= 2 && abs(column) <= 2 {
				color = foreground
			}
			set_pixel(ctx, x + column, y + row, color)
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
		if field.kind == .Checkbox {
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
}

@(private = "file")
hovered_form_at :: proc(forms: []Form, x, y: int) -> ^Form {
	candidate: ^Form
	for &field in forms {
		if field.kind == .End {
			break
		}
		if .Hidden in field.flags || !point_inside(&field, x, y) {
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
process_event :: proc(ctx: ^Context, form: []Form, event: ^Event) -> Error {
	if event.kind == .Key {
		if ctx.text_field != nil {
			return process_text_key(ctx, event)
		}
		return .None
	}
	if event.kind != .Mouse {
		return .None
	}
	update_hover(ctx, form)
	if ctx.horizontal_bar != nil {
		if .Released in event.buttons {
			ctx.horizontal_bar = nil
		} else {
			update_slider(ctx.horizontal_bar, event.x)
			ctx.flags += {.Refresh}
		}
	}
	if .Mouse_Left in event.buttons {
		if ctx.hovered == nil || .Disabled in ctx.hovered.flags {
			deactivate_text_input(ctx)
			return .None
		}
		if ctx.hovered.kind != .Text_Input {
			deactivate_text_input(ctx)
		}
		#partial switch ctx.hovered.kind {
		case .Button:
			ctx.pressed = ctx.hovered
		case .Checkbox:
			activate_checkbox(ctx.hovered)
		case .Radio:
			activate_radio(ctx.hovered)
		case .Slider:
			ctx.horizontal_bar = ctx.hovered
			update_slider(ctx.hovered, event.x)
		case .Text_Input:
			activate_text_input(ctx, ctx.hovered)
		case:
		}
		ctx.flags += {.Refresh}
	} else if .Released in event.buttons {
		if ctx.pressed != nil && ctx.pressed == ctx.hovered && ctx.pressed.kind == .Button {
			activate_button(ctx.pressed)
		}
		ctx.pressed = nil
		ctx.flags += {.Refresh}
	}
	return .None
}

@(private = "file")
activate_text_input :: proc(ctx: ^Context, field: ^Form) {
	buffer, valid := bound_text_buffer(field)
	if !valid {
		return
	}
	ctx.text_field = field
	ctx.text_cursor = len(buffer.data)
	if ctx.backend.show_keyboard != nil {
		_ = ctx.backend.show_keyboard(ctx.backend.data)
	}
}

@(private = "file")
deactivate_text_input :: proc(ctx: ^Context) {
	if ctx.text_field == nil {
		return
	}
	ctx.text_field = nil
	ctx.text_cursor = 0
	if ctx.backend.hide_keyboard != nil {
		_ = ctx.backend.hide_keyboard(ctx.backend.data)
	}
}

@(private = "file")
process_text_key :: proc(ctx: ^Context, event: ^Event) -> Error {
	field := ctx.text_field
	buffer, valid := bound_text_buffer(field)
	if !valid {
		return .Invalid_Input
	}
	text := key_text(&event.key)
	switch text {
	case "Escape", "Enter":
		deactivate_text_input(ctx)
	case "Home":
		ctx.text_cursor = 0
	case "End":
		ctx.text_cursor = len(buffer.data)
	case "Left":
		ctx.text_cursor = previous_codepoint(buffer.data[:], ctx.text_cursor)
	case "Right":
		ctx.text_cursor = next_codepoint(buffer.data[:], ctx.text_cursor)
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
		if len(text) > 0 && text_allowed(field.filter, buffer.data[:], text) {
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
update_slider :: proc(field: ^Form, mouse_x: int) {
	if field.binding.kind != .Integer || field.binding.data == nil {
		return
	}
	minimum := int(field.minimum)
	maximum := int(field.maximum)
	if maximum <= minimum {
		return
	}
	track_width := max(field.computed_width - 10, 1)
	position := clamp(mouse_x - field.computed_x - 5, 0, track_width)
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
draw_beveled_rectangle :: proc(ctx: ^Context, x, y, width, height: int, light, color, dark: u32) {
	fill_rectangle(ctx, x, y, width, height, color)
	fill_rectangle(ctx, x, y, width, 1, light)
	fill_rectangle(ctx, x, y, 1, height, light)
	fill_rectangle(ctx, x, y + height - 1, width, 1, dark)
	fill_rectangle(ctx, x + width - 1, y, 1, height, dark)
}

@(private = "file")
set_pixel :: proc(ctx: ^Context, x, y: int, color: u32) {
	if x < 0 || y < 0 || x >= ctx.screen.width || y >= ctx.screen.height {
		return
	}
	pixel := y * ctx.screen.pitch + x * 4
	ctx.screen.pixels[pixel + 0] = u8(color)
	ctx.screen.pixels[pixel + 1] = u8(color >> 8)
	ctx.screen.pixels[pixel + 2] = u8(color >> 16)
	ctx.screen.pixels[pixel + 3] = u8(color >> 24)
}

@(private = "file")
fill_rectangle :: proc(ctx: ^Context, x, y, width, height: int, color: u32) {
	x0 := clamp(x, 0, ctx.screen.width)
	y0 := clamp(y, 0, ctx.screen.height)
	x1 := clamp(x + width, 0, ctx.screen.width)
	y1 := clamp(y + height, 0, ctx.screen.height)
	for pixel_y in y0 ..< y1 {
		for pixel_x in x0 ..< x1 {
			pixel := pixel_y * ctx.screen.pitch + pixel_x * 4
			ctx.screen.pixels[pixel + 0] = u8(color)
			ctx.screen.pixels[pixel + 1] = u8(color >> 8)
			ctx.screen.pixels[pixel + 2] = u8(color >> 16)
			ctx.screen.pixels[pixel + 3] = u8(color >> 24)
		}
	}
}
