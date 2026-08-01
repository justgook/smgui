package smgui_sokol

/*
Sokol adapter for SMGUI.

sokol_app owns the native event loop, so this adapter is started with run()
instead of calling smgui.init() directly. run() initializes SMGUI from Sokol's
init callback, translates Sokol events, and presents the software framebuffer
with sokol_framebuffer.
*/

import smgui ".."
import "base:runtime"
import "core:c"
import "core:strings"
import "core:unicode/utf8"
import sapp "../../vendor/sokol-odin/sokol/app"
import sfb "../../vendor/sokol-odin/sokol/framebuffer"
import sg "../../vendor/sokol-odin/sokol/gfx"
import sglue "../../vendor/sokol-odin/sokol/glue"
import slog "../../vendor/sokol-odin/sokol/log"

Init_Proc :: #type proc(ctx: ^smgui.Context, user_data: rawptr) -> smgui.Error
Frame_Proc :: #type proc(
	ctx: ^smgui.Context,
	event: smgui.Event,
	user_data: rawptr,
) -> smgui.Error

Config :: struct {
	ctx:              ^smgui.Context,
	texts:            []string,
	forms:            []smgui.Form,
	width:            int,
	height:           int,
	icon:             ^smgui.Image,
	user_data:        rawptr,
	init:             Init_Proc,
	frame:            Frame_Proc,
	high_dpi:         bool,
	fullscreen:       bool,
	disable_vsync:    bool,
	clipboard_size:   int,
	max_dropped_files: int,
	clear_color:       [4]f32,
}

State :: struct {
	config:            Config,
	ctx:               ^smgui.Context,
	framebuffer:       sfb.Framebuffer,
	presentation_pixels: []u8,
	buttons:           smgui.Input_Buttons,
	pending_mouse_move: smgui.Event,
	has_mouse_move:    bool,
	error:             smgui.Error,
	smgui_initialized: bool,
	gfx_initialized:   bool,
	framebuffer_ready: bool,
	native_cursor_bound: bool,
}

// create is exposed for embedding in an already-running sokol_app. Most callers
// should use run(), which guarantees the required Sokol lifecycle ordering.
create :: proc(state: ^State) -> smgui.Backend {
	return {
		data = state,
		init = backend_init,
		deinit = backend_deinit,
		poll = backend_poll,
		redraw = backend_redraw,
		focus = backend_focus,
		fullscreen = backend_fullscreen,
		set_title = backend_set_title,
		set_clipboard = backend_set_clipboard,
		get_clipboard = backend_get_clipboard,
		hide_cursor = backend_hide_cursor,
		show_cursor = backend_show_cursor,
		hide_keyboard = backend_hide_keyboard,
		show_keyboard = backend_show_keyboard,
		native_window = backend_native_window,
	}
}

// run blocks until the Sokol application exits. Config slices and user_data
// must remain valid for the duration of the call.
run :: proc(config: Config) -> smgui.Error {
	if config.ctx == nil || len(config.texts) == 0 || config.width < 1 || config.height < 1 {
		return .Invalid_Input
	}
	state := State{config = config, ctx = config.ctx}
	title := strings.clone_to_cstring(config.texts[0]) or_else nil
	if title == nil {
		return .Out_Of_Memory
	}
	defer delete(title)

	desc := sapp.Desc {
		user_data = &state,
		init_userdata_cb = app_init,
		frame_userdata_cb = app_frame,
		cleanup_userdata_cb = app_cleanup,
		event_userdata_cb = app_event,
		width = c.int(config.width),
		height = c.int(config.height),
		sample_count = 1,
		window_title = title,
		high_dpi = config.high_dpi,
		fullscreen = config.fullscreen,
		disable_vsync = config.disable_vsync,
		enable_clipboard = true,
		clipboard_size = c.int(max(config.clipboard_size, 8192)),
		enable_dragndrop = true,
		max_dropped_files = c.int(max(config.max_dropped_files, 16)),
		max_dropped_file_path_length = 4096,
		icon = {sokol_default = config.icon == nil},
		logger = {func = slog.func},
	}
	if config.icon != nil && len(config.icon.pixels) > 0 {
		desc.icon.images[0] = {
			width = c.int(config.icon.width),
			height = c.int(config.icon.height),
			pixels = {ptr = raw_data(config.icon.pixels), size = c.size_t(len(config.icon.pixels))},
		}
	}
	sapp.run(desc)
	return state.error
}

@(private = "file")
app_init :: proc "c" (data: rawptr) {
	context = runtime.default_context()
	state := (^State)(data)
	width, height := int(sapp.width()), int(sapp.height())
	if width < 1 || height < 1 {
		state.error = .Backend_Failure
		sapp.request_quit()
		return
	}
	state.error = smgui.init(
		state.config.ctx,
		create(state),
		state.config.texts,
		width,
		height,
		state.config.icon,
	)
	if state.error != .None {
		sapp.request_quit()
		return
	}
	state.smgui_initialized = true
	if state.config.init != nil {
		state.error = state.config.init(state.ctx, state.config.user_data)
		if state.error != .None {
			sapp.request_quit()
		}
	}
}

@(private = "file")
app_frame :: proc "c" (data: rawptr) {
	context = runtime.default_context()
	state := (^State)(data)
	if state.error != .None || !state.smgui_initialized {
		return
	}
	event, poll_state, error := smgui.poll_event(state.ctx, state.config.forms)
	if error != .None {
		state.error = error
		sapp.request_quit()
		return
	}
	if poll_state == .Closed {
		sapp.request_quit()
		return
	}
	if state.config.frame != nil {
		state.error = state.config.frame(state.ctx, event, state.config.user_data)
		if state.error != .None {
			sapp.request_quit()
		}
	}
}

@(private = "file")
app_cleanup :: proc "c" (data: rawptr) {
	context = runtime.default_context()
	state := (^State)(data)
	if state.smgui_initialized {
		if error := smgui.deinit(state.ctx); state.error == .None && error != .None {
			state.error = error
		}
		state.smgui_initialized = false
	} else {
		_ = backend_deinit(state)
	}
}

app_event :: proc "c" (source: ^sapp.Event, data: rawptr) {
	context = runtime.default_context()
	state := (^State)(data)
	if source == nil || state.ctx == nil || state.error != .None {
		return
	}

	state.ctx.mouse_x = int(source.mouse_x)
	state.ctx.mouse_y = int(source.mouse_y)
	state.buttons = buttons_from_modifiers(source.modifiers)
	event: smgui.Event
	#partial switch source.type {
	case .MOUSE_DOWN, .MOUSE_UP:
		button, ok := mouse_button(source.mouse_button)
		if !ok {
			return
		}
		if source.type == .MOUSE_DOWN {
			state.buttons += {button}
		} else {
			state.buttons -= {button}
		}
		event = {kind = .Mouse, buttons = state.buttons, x = state.ctx.mouse_x, y = state.ctx.mouse_y}
		if source.type == .MOUSE_UP {
			event.buttons += {.Released}
		}
	case .MOUSE_MOVE:
		state.pending_mouse_move = {
			kind = .Mouse,
			buttons = state.buttons,
			x = state.ctx.mouse_x,
			y = state.ctx.mouse_y,
		}
		state.has_mouse_move = true
		return
	case .MOUSE_SCROLL:
		event = {kind = .Mouse, buttons = state.buttons, x = state.ctx.mouse_x, y = state.ctx.mouse_y}
		if source.scroll_y > 0 {event.buttons += {.Direction_Up}}
		if source.scroll_y < 0 {event.buttons += {.Direction_Down}}
		if source.scroll_x > 0 {event.buttons += {.Gamepad_A}}
		if source.scroll_x < 0 {event.buttons += {.Gamepad_B}}
	case .KEY_DOWN:
		text := special_key_text(source.key_code)
		if len(text) == 0 {
			return
		}
		event = {kind = .Key, buttons = state.buttons, key = smgui.key_input(text)}
	case .CHAR:
		if source.char_code < 32 {
			return
		}
		bytes, length := utf8.encode_rune(rune(source.char_code))
		event = {kind = .Key, buttons = state.buttons, key = smgui.key_input(string(bytes[:length]))}
	case .RESIZED:
		width, height := int(source.framebuffer_width), int(source.framebuffer_height)
		if width < 1 || height < 1 {
			return
		}
		state.error = smgui.resize_framebuffer(state.ctx, width, height)
		if state.error != .None {
			sapp.request_quit()
			return
		}
		if state.framebuffer_ready {
			sfb.resize(state.framebuffer, {
				width = c.int(width),
				height = c.int(height),
				prescale = 1,
				cliprect = {width = c.int(width), height = c.int(height)},
			})
		}
		event = {kind = .Resize, x = width, y = height}
	case .QUIT_REQUESTED:
		return
	case .FILES_DROPPED:
		for index in 0 ..< int(sapp.get_num_dropped_files()) {
			path := sapp.get_dropped_file_path(index)
			if path != nil {
				if error := smgui.push_event(state.ctx, {
					kind = .Drop,
					buttons = state.buttons,
					x = state.ctx.mouse_x,
					y = state.ctx.mouse_y,
					file_name = string(path),
				}); error != .None {
					state.error = error
					sapp.request_quit()
					return
				}
			}
		}
		return
	case:
		return
	}
	if error := smgui.push_event(state.ctx, event); error != .None {
		state.error = error
		sapp.request_quit()
	}
}

@(private = "file")
backend_init :: proc(data: rawptr, ctx: ^smgui.Context, title: string, width, height: int, icon: ^smgui.Image) -> smgui.Error {
	if data == nil || ctx == nil || width < 1 || height < 1 || !sapp.isvalid() {
		return .Invalid_Input
	}
	_ = title
	_ = icon
	state := (^State)(data)
	state.ctx = ctx
	sg.setup({environment = sglue.environment(), logger = {func = slog.func}})
	if !sg.isvalid() {
		return .Backend_Failure
	}
	state.gfx_initialized = true
	sfb.setup({logger = {func = slog.func}})
	state.framebuffer = sfb.make_framebuffer({
		width = c.int(width),
		height = c.int(height),
		prescale = 1,
		format = .RGBA8,
		cliprect = {width = c.int(width), height = c.int(height)},
	})
	if sfb.query_framebuffer_state(state.framebuffer) != .VALID {
		sfb.shutdown()
		sg.shutdown()
		state.gfx_initialized = false
		return .Backend_Failure
	}
	state.framebuffer_ready = true
	return .None
}

@(private = "file")
backend_deinit :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	state := (^State)(data)
	if state.native_cursor_bound {
		sapp.set_mouse_cursor(.DEFAULT)
		sapp.unbind_mouse_cursor_image(.CUSTOM_0)
		state.native_cursor_bound = false
	}
	if state.framebuffer_ready {
		sfb.destroy_framebuffer(state.framebuffer)
		sfb.shutdown()
		state.framebuffer_ready = false
	}
	if state.gfx_initialized {
		sg.shutdown()
		state.gfx_initialized = false
	}
	if state.presentation_pixels != nil {
		delete(state.presentation_pixels)
		state.presentation_pixels = nil
	}
	state.ctx = nil
	return .None
}

@(private = "file")
backend_poll :: proc(data: rawptr) -> (bool, smgui.Error) {
	if data == nil {return true, .Invalid_Input}
	state := (^State)(data)
	if state.error != .None {
		return false, state.error
	}
	if state.has_mouse_move {
		if error := smgui.push_event(state.ctx, state.pending_mouse_move); error != .None {
			state.error = error
			return false, error
		}
		state.has_mouse_move = false
	}
	return false, .None
}

@(private = "file")
backend_redraw :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	state := (^State)(data)
	if !state.framebuffer_ready || state.ctx == nil || len(state.ctx.screen.pixels) == 0 {
		return .Backend_Failure
	}
	screen := &state.ctx.screen
	clear := resolved_clear_color(state.config.clear_color)
	if len(state.presentation_pixels) != len(screen.pixels) {
		if state.presentation_pixels != nil {
			delete(state.presentation_pixels)
		}
		state.presentation_pixels = make([]u8, len(screen.pixels)) or_else nil
		if state.presentation_pixels == nil {
			return .Out_Of_Memory
		}
	}
	composite_over_clear(state.presentation_pixels, screen.pixels, clear)
	sfb.update(state.framebuffer, {
		pixels = {
			ptr = raw_data(state.presentation_pixels),
			size = c.size_t(len(state.presentation_pixels)),
		},
	})
	pass_action := sg.Pass_Action{}
	pass_action.colors[0] = {
		load_action = .CLEAR,
		clear_value = {clear[0], clear[1], clear[2], clear[3]},
	}
	sg.begin_pass({action = pass_action, swapchain = sglue.swapchain()})
	sfb.render(state.framebuffer)
	sg.end_pass()
	sg.commit()
	return .None
}

resolved_clear_color :: proc(color: [4]f32) -> [4]f32 {
	if color[0] == 0 && color[1] == 0 && color[2] == 0 && color[3] == 0 {
		return {0, 0, 0, 1}
	}
	return color
}

composite_over_clear :: proc(destination, source: []u8, clear: [4]f32) {
	background := [4]u32 {
		u32(clamp(clear[0], 0, 1) * 255 + 0.5),
		u32(clamp(clear[1], 0, 1) * 255 + 0.5),
		u32(clamp(clear[2], 0, 1) * 255 + 0.5),
		u32(clamp(clear[3], 0, 1) * 255 + 0.5),
	}
	for pixel := 0; pixel + 3 < min(len(destination), len(source)); pixel += 4 {
		alpha := u32(source[pixel + 3])
		inverse := 255 - alpha
		for channel in 0 ..< 3 {
			value := u32(source[pixel + channel]) * alpha + background[channel] * inverse
			destination[pixel + channel] = u8((value + 127) / 255)
		}
		output_alpha := alpha * 255 + background[3] * inverse
		destination[pixel + 3] = u8((output_alpha + 127) / 255)
	}
}

@(private = "file")
backend_focus :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	return .Not_Implemented
}

@(private = "file")
backend_fullscreen :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	sapp.toggle_fullscreen()
	return .None
}

@(private = "file")
backend_set_title :: proc(data: rawptr, title: string) -> smgui.Error {
	if data == nil || len(title) == 0 {return .Invalid_Input}
	value := strings.clone_to_cstring(title, context.temp_allocator) or_else nil
	if value == nil {return .Out_Of_Memory}
	sapp.set_window_title(value)
	return .None
}

@(private = "file")
backend_set_clipboard :: proc(data: rawptr, text: string) -> smgui.Error {
	if data == nil || len(text) == 0 {return .Invalid_Input}
	value := strings.clone_to_cstring(text, context.temp_allocator) or_else nil
	if value == nil {return .Out_Of_Memory}
	sapp.set_clipboard_string(value)
	return .None
}

@(private = "file")
backend_get_clipboard :: proc(data: rawptr) -> (string, smgui.Error) {
	if data == nil {return "", .Invalid_Input}
	value := sapp.get_clipboard_string()
	if value == nil {return "", .None}
	return string(value), .None
}

@(private = "file")
backend_hide_cursor :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	state := (^State)(data)
	if state.ctx == nil {
		return .Backend_Failure
	}
	cursor := &state.ctx.software_cursor
	if cursor.width < 2 || cursor.height < 2 || cursor.pitch < cursor.width * 4 ||
	   len(cursor.pixels) < (cursor.height - 1) * cursor.pitch + cursor.width * 4 {
		// Sokol custom cursor hotspots require dimensions greater than one.
		sapp.show_mouse(false)
		return .None
	}
	pixels := make([]u8, cursor.width * cursor.height * 4) or_else nil
	if pixels == nil {
		return .Out_Of_Memory
	}
	defer delete(pixels)
	for row in 0 ..< cursor.height {
		source_start := row * cursor.pitch
		destination_start := row * cursor.width * 4
		copy(
			pixels[destination_start:destination_start + cursor.width * 4],
			cursor.pixels[source_start:source_start + cursor.width * 4],
		)
	}
	if state.native_cursor_bound {
		sapp.set_mouse_cursor(.DEFAULT)
		sapp.unbind_mouse_cursor_image(.CUSTOM_0)
	}
	sapp.bind_mouse_cursor_image(.CUSTOM_0, {
		width = c.int(cursor.width),
		height = c.int(cursor.height),
		cursor_hotspot_x = 0,
		cursor_hotspot_y = 0,
		pixels = {ptr = raw_data(pixels), size = c.size_t(len(pixels))},
	})
	sapp.set_mouse_cursor(.CUSTOM_0)
	sapp.show_mouse(true)
	state.native_cursor_bound = true
	// Prevent the core renderer from also drawing the promoted cursor.
	state.ctx.software_cursor = {}
	return .None
}

@(private = "file")
backend_show_cursor :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	state := (^State)(data)
	if state.native_cursor_bound {
		sapp.set_mouse_cursor(.DEFAULT)
		sapp.unbind_mouse_cursor_image(.CUSTOM_0)
		state.native_cursor_bound = false
	}
	sapp.show_mouse(true)
	return .None
}

@(private = "file")
backend_hide_keyboard :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	sapp.show_keyboard(false)
	return .None
}

@(private = "file")
backend_show_keyboard :: proc(data: rawptr) -> smgui.Error {
	if data == nil {return .Invalid_Input}
	sapp.show_keyboard(true)
	return .None
}

@(private = "file")
backend_native_window :: proc(data: rawptr) -> rawptr {
	if data == nil {return nil}
	when ODIN_OS == .Darwin {return sapp.macos_get_window()}
	else when ODIN_OS == .Windows {return sapp.win32_get_hwnd()}
	else when ODIN_OS == .Linux {return sapp.x11_get_window()}
	else {return nil}
}

buttons_from_modifiers :: proc(modifiers: u32) -> smgui.Input_Buttons {
	buttons: smgui.Input_Buttons
	if modifiers & sapp.MODIFIER_SHIFT != 0 {buttons += {.Shift}}
	if modifiers & sapp.MODIFIER_CTRL != 0 {buttons += {.Control}}
	if modifiers & sapp.MODIFIER_ALT != 0 {buttons += {.Alt}}
	if modifiers & sapp.MODIFIER_SUPER != 0 {buttons += {.Gui}}
	if modifiers & sapp.MODIFIER_LMB != 0 {buttons += {.Mouse_Left}}
	if modifiers & sapp.MODIFIER_MMB != 0 {buttons += {.Mouse_Middle}}
	if modifiers & sapp.MODIFIER_RMB != 0 {buttons += {.Mouse_Right}}
	return buttons
}

mouse_button :: proc(button: sapp.Mousebutton) -> (smgui.Input_Button, bool) {
	#partial switch button {
	case .LEFT: return .Mouse_Left, true
	case .MIDDLE: return .Mouse_Middle, true
	case .RIGHT: return .Mouse_Right, true
	case: return {}, false
	}
}

special_key_text :: proc(key: sapp.Keycode) -> string {
	#partial switch key {
	case .ESCAPE: return "Escape"
	case .ENTER, .KP_ENTER: return "Enter"
	case .TAB: return "Tab"
	case .BACKSPACE: return "Backspace"
	case .DELETE: return "Delete"
	case .LEFT: return "Left"
	case .RIGHT: return "Right"
	case .UP: return "Up"
	case .DOWN: return "Down"
	case .HOME: return "Home"
	case .END: return "End"
	case .PAGE_UP: return "PgUp"
	case .PAGE_DOWN: return "PgDown"
	case .INSERT: return "Insert"
	}
	return ""
}
