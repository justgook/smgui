package raylib

/*
Reference: new adapter

Purpose:
  Present the SMGUI software framebuffer and translate events through
  vendor:raylib.

Status:
  [x] Package scaffolded
  [x] Window and framebuffer presentation implemented
  [x] Close, mouse-button, and mouse-motion events implemented
  [x] Clipboard, cursor, title, and fullscreen hooks implemented
  [ ] Keyboard, wheel, drop-file, gamepad, and resize events implemented
  [ ] Parity fixtures passing

Definition of done:
  - `make check` passes
  - Every supported raylib event has an SMGUI translation test
  - Framebuffer presentation does not alter pixel values
*/

import smgui ".."
import "core:strings"
import rl "vendor:raylib/v6"

State :: struct {
	ctx:          ^smgui.Context,
	texture:      rl.Texture2D,
	buttons:      smgui.Input_Buttons,
	last_mouse_x: int,
	last_mouse_y: int,
	initialized:  bool,
}

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
		hide_keyboard = backend_no_operation,
		show_keyboard = backend_no_operation,
		native_window = backend_native_window,
	}
}

@(private = "file")
backend_init :: proc(
	data: rawptr,
	ctx: ^smgui.Context,
	title: string,
	width, height: int,
	icon: ^smgui.Image,
) -> smgui.Error {
	if data == nil || ctx == nil || width < 1 || height < 1 {
		return .Invalid_Input
	}
	state := (^State)(data)
	_ = icon
	title_c := strings.clone_to_cstring(title, context.temp_allocator) or_else nil
	if title_c == nil {
		return .Out_Of_Memory
	}
	rl.InitWindow(i32(width), i32(height), title_c)
	if !rl.IsWindowReady() {
		return .Backend_Failure
	}
	rl.SetTargetFPS(60)
	image := rl.Image {
		data    = raw_data(ctx.screen.pixels),
		width   = i32(width),
		height  = i32(height),
		mipmaps = 1,
		format  = .UNCOMPRESSED_R8G8B8A8,
	}
	state.ctx = ctx
	state.last_mouse_x = int(rl.GetMouseX())
	state.last_mouse_y = int(rl.GetMouseY())
	state.texture = rl.LoadTextureFromImage(image)
	state.initialized = true
	return .None
}

@(private = "file")
backend_deinit :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	state := (^State)(data)
	if state.initialized {
		rl.UnloadTexture(state.texture)
		rl.CloseWindow()
	}
	state^ = {}
	return .None
}

@(private = "file")
backend_poll :: proc(data: rawptr) -> (closed: bool, error: smgui.Error) {
	if data == nil {
		return true, .Invalid_Input
	}
	state := (^State)(data)
	if !state.initialized || state.ctx == nil {
		return true, .Backend_Failure
	}
	if rl.WindowShouldClose() {
		return true, .None
	}

	mouse_x := int(rl.GetMouseX())
	mouse_y := int(rl.GetMouseY())
	mouse_moved := mouse_x != state.last_mouse_x || mouse_y != state.last_mouse_y
	state.ctx.mouse_x = mouse_x
	state.ctx.mouse_y = mouse_y
	if error = translate_mouse_button(state, .LEFT, .Mouse_Left); error != .None {
		return false, error
	}
	if error = translate_mouse_button(state, .MIDDLE, .Mouse_Middle); error != .None {
		return false, error
	}
	if error = translate_mouse_button(state, .RIGHT, .Mouse_Right); error != .None {
		return false, error
	}
	if mouse_moved {
		state.last_mouse_x = mouse_x
		state.last_mouse_y = mouse_y
		if error = smgui.push_event(
			state.ctx,
			{kind = .Mouse, buttons = state.buttons, x = mouse_x, y = mouse_y},
		); error != .None {
			return false, error
		}
	}
	return false, .None
}

@(private = "file")
translate_mouse_button :: proc(
	state: ^State,
	raylib_button: rl.MouseButton,
	smgui_button: smgui.Input_Button,
) -> smgui.Error {
	pressed := rl.IsMouseButtonPressed(raylib_button)
	released := rl.IsMouseButtonReleased(raylib_button)
	if !pressed && !released {
		return .None
	}
	if pressed {
		state.buttons += {smgui_button}
	} else {
		state.buttons -= {smgui_button}
	}
	buttons := state.buttons
	if released {
		buttons += {.Released}
	}
	return smgui.push_event(
		state.ctx,
		{kind = .Mouse, buttons = buttons, x = state.ctx.mouse_x, y = state.ctx.mouse_y},
	)
}

@(private = "file")
backend_redraw :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	state := (^State)(data)
	if !state.initialized || state.ctx == nil || len(state.ctx.screen.pixels) == 0 {
		return .Backend_Failure
	}
	rl.UpdateTexture(state.texture, raw_data(state.ctx.screen.pixels))
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.DrawTexture(state.texture, 0, 0, rl.WHITE)
	rl.EndDrawing()
	return .None
}

@(private = "file")
backend_focus :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	return .None
}

@(private = "file")
backend_fullscreen :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	rl.ToggleFullscreen()
	return .None
}

@(private = "file")
backend_set_title :: proc(data: rawptr, title: string) -> smgui.Error {
	if data == nil || len(title) == 0 {
		return .Invalid_Input
	}
	title_c := strings.clone_to_cstring(title, context.temp_allocator) or_else nil
	if title_c == nil {
		return .Out_Of_Memory
	}
	rl.SetWindowTitle(title_c)
	return .None
}

@(private = "file")
backend_set_clipboard :: proc(data: rawptr, text: string) -> smgui.Error {
	if data == nil || len(text) == 0 {
		return .Invalid_Input
	}
	text_c := strings.clone_to_cstring(text, context.temp_allocator) or_else nil
	if text_c == nil {
		return .Out_Of_Memory
	}
	rl.SetClipboardText(text_c)
	return .None
}

@(private = "file")
backend_get_clipboard :: proc(data: rawptr) -> (string, smgui.Error) {
	if data == nil {
		return "", .Invalid_Input
	}
	text := rl.GetClipboardText()
	if text == nil {
		return "", .None
	}
	return string(text), .None
}

@(private = "file")
backend_hide_cursor :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	rl.HideCursor()
	return .None
}

@(private = "file")
backend_show_cursor :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	rl.EnableCursor()
	return .None
}

@(private = "file")
backend_no_operation :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	return .None
}

@(private = "file")
backend_native_window :: proc(data: rawptr) -> rawptr {
	if data == nil {
		return nil
	}
	return rl.GetWindowHandle()
}
