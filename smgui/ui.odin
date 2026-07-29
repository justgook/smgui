package smgui

/*
Port of: reference-c/ui.h

Purpose:
  Backend-independent state-mode GUI types, layout, rendering, and event logic.

Status:
  [x] Idiomatic Odin public interface declared
  [x] Typed errors, slices, enums, and bit sets declared
  [x] Backend adapter seam declared
  [ ] Drawing primitives implemented
  [ ] Layout implemented
  [ ] Event processing implemented
  [ ] Built-in widgets implemented

Definition of done:
  - `make check` passes
  - Every public operation has behavioral parity coverage
  - Deterministic framebuffer fixtures match reference-c
  - No operation reports success before doing its documented work
*/

Error :: enum {
	None,
	Invalid_Input,
	Backend_Failure,
	Out_Of_Memory,
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

Event :: struct {
	kind:      Event_Kind,
	buttons:   Input_Buttons,
	x:         int,
	y:         int,
	right_x:   int,
	right_y:   int,
	key:       string,
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

@(require_results, tag = "reference:ui_fonthook")
set_font_hooks :: proc(ctx: ^Context, bounds: Font_Bounds_Proc, draw: Font_Draw_Proc) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_font")
set_font :: proc(ctx: ^Context, font: rawptr) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_swcursor")
set_software_cursor :: proc(ctx: ^Context, cursor: ^Image) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_hwcursor")
use_hardware_cursor :: proc(ctx: ^Context) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_theme")
set_theme :: proc(ctx: ^Context, theme: []u32) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_skin")
set_skin :: proc(ctx: ^Context, skin: []Image) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_pngskin")
set_png_skin :: proc(ctx: ^Context, png: []u8) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_refresh")
refresh :: proc(ctx: ^Context) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_settxt")
set_texts :: proc(ctx: ^Context, texts: []string) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_getclipboard")
clipboard_text :: proc(ctx: ^Context) -> (string, Error) {
	return "", .Not_Implemented
}

@(require_results, tag = "reference:ui_setclipboard")
set_clipboard_text :: proc(ctx: ^Context, text: string) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_getmouse")
mouse_position :: proc(ctx: ^Context) -> (x, y: int, error: Error) {
	return 0, 0, .Not_Implemented
}

@(require_results, tag = "reference:ui_init")
init :: proc(
	ctx: ^Context,
	backend: Backend,
	texts: []string,
	width, height: int,
	icon: ^Image = nil,
) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_fullscreen")
toggle_fullscreen :: proc(ctx: ^Context) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:ui_getwindow")
native_window :: proc(ctx: ^Context) -> (rawptr, Error) {
	return nil, .Not_Implemented
}

Poll_State :: enum {
	Running,
	Closed,
}

@(require_results, tag = "reference:ui_event")
poll_event :: proc(ctx: ^Context, form: []Form) -> (Event, Poll_State, Error) {
	return {}, .Running, .Not_Implemented
}

@(require_results, tag = "reference:ui_free")
deinit :: proc(ctx: ^Context) -> Error {
	return .Not_Implemented
}

// Adapter-facing operations. These form the seam between the core module and
// platform adapters; they are not intended for application-level UI code.
@(require_results, tag = "reference:_ui_evtslot")
push_event :: proc(ctx: ^Context, event: Event) -> Error {
	return .Not_Implemented
}

@(require_results, tag = "reference:_ui_resize")
resize :: proc(ctx: ^Context, width, height: int) -> Error {
	return .Not_Implemented
}
