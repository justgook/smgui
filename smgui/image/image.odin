package smgui_image

/*
Test-oriented image adapter.

It writes the first rendered SMGUI software framebuffer to PNG through the
Odin-distributed stb_image_write binding, then closes on the next poll.
*/

import smgui ".."
import "core:c"
import "core:strings"
import stbi "vendor:stb/image"

State :: struct {
	ctx:         ^smgui.Context,
	output_path: string,
	c_path:      cstring,
	finished:                bool,
	succeeded:               bool,
	redraws_before_capture:  int,
}

create :: proc(state: ^State, output_path: string, redraws_before_capture: int = 0) -> smgui.Backend {
	if state != nil {
		state^ = {
			output_path = output_path,
			redraws_before_capture = max(redraws_before_capture, 0),
		}
	}
	return {
		data   = state,
		init   = backend_init,
		deinit = backend_deinit,
		poll   = backend_poll,
		redraw = backend_redraw,
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
	if len(state.output_path) == 0 {
		return .Invalid_Input
	}
	_ = title
	_ = icon
	state.c_path = strings.clone_to_cstring(state.output_path) or_else nil
	if state.c_path == nil {
		return .Out_Of_Memory
	}
	state.ctx = ctx
	return .None
}

@(private = "file")
backend_deinit :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	state := (^State)(data)
	if state.c_path != nil {
		delete(state.c_path)
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
	return state.finished, .None
}

@(private = "file")
backend_redraw :: proc(data: rawptr) -> smgui.Error {
	if data == nil {
		return .Invalid_Input
	}
	state := (^State)(data)
	if state.ctx == nil || state.c_path == nil || len(state.ctx.screen.pixels) == 0 {
		return .Backend_Failure
	}
	if state.redraws_before_capture > 0 {
		state.redraws_before_capture -= 1
		return .None
	}
	screen := &state.ctx.screen
	result := stbi.write_png(
		state.c_path,
		c.int(screen.width),
		c.int(screen.height),
		4,
		raw_data(screen.pixels),
		c.int(screen.pitch),
	)
	state.succeeded = result != 0
	state.finished = true
	if !state.succeeded {
		return .Backend_Failure
	}
	return .None
}
