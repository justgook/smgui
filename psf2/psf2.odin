package psf2

/*
Reference: reference-c/mods/ui_psf2.h

Purpose:
  Render deterministic PC Screen Font 2 glyphs.

Status:
  [x] Package scaffolded
  [x] Built-in ASCII font embedded
  [x] Font measurement implemented
  [x] Font drawing implemented
  [ ] General PSF2 Unicode tables implemented
  [ ] Parity fixtures passing

Definition of done:
  - `make check` passes
  - Built-in ASCII rendering matches reference-c pixel-for-pixel
  - UTF-8 codepoints use PSF2 Unicode tables when present
*/

import smgui "../smgui"

DEFAULT_FONT_DATA :: #load("default.psf")
PSF2_MAGIC :: u32(0x864a_b572)

Font :: struct {
	data:            []u8,
	header_size:     int,
	flags:           u32,
	glyph_count:     int,
	bytes_per_glyph: int,
	height:          int,
	width:           int,
}

@(require_results)
default_font :: proc() -> (Font, smgui.Error) {
	return parse(DEFAULT_FONT_DATA)
}

@(require_results)
parse :: proc(data: []u8) -> (Font, smgui.Error) {
	if len(data) < 32 || read_u32(data, 0) != PSF2_MAGIC {
		return {}, .Invalid_Input
	}

	font := Font {
		data            = data,
		header_size     = int(read_u32(data, 8)),
		flags           = read_u32(data, 12),
		glyph_count     = int(read_u32(data, 16)),
		bytes_per_glyph = int(read_u32(data, 20)),
		height          = int(read_u32(data, 24)),
		width           = int(read_u32(data, 28)),
	}
	glyph_bytes := font.glyph_count * font.bytes_per_glyph
	if font.header_size < 32 || glyph_bytes < 0 || font.header_size + glyph_bytes > len(data) {
		return {}, .Invalid_Input
	}
	return font, .None
}

@(require_results)
configure :: proc(ctx: ^smgui.Context, font: ^Font) -> smgui.Error {
	if error := smgui.set_font_hooks(ctx, bounds, draw); error != .None {
		return error
	}
	return smgui.set_font(ctx, font)
}

@(private = "file")
read_u32 :: proc(data: []u8, offset: int) -> u32 {
	return(
		u32(data[offset]) |
		u32(data[offset + 1]) << 8 |
		u32(data[offset + 2]) << 16 |
		u32(data[offset + 3]) << 24 \
	)
}

@(private = "file")
bounds :: proc(
	font_data: rawptr,
	text: string,
	width: ^int,
	height: ^int,
	left: ^int,
	top: ^int,
) -> smgui.Error {
	if font_data == nil || width == nil || height == nil {
		return .Invalid_Input
	}
	font := (^Font)(font_data)
	line_width := 0
	width^ = 0
	height^ = font.height
	if left != nil {
		left^ = 0
	}
	if top != nil {
		top^ = 0
	}

	for character in text {
		switch character {
		case '\r':
			line_width = 0
		case '\n':
			line_width = 0
			height^ += font.height
		case:
			line_width += font.width + 1
			width^ = max(width^, line_width)
		}
	}
	return .None
}

@(private = "file")
draw :: proc(
	font_data: rawptr,
	text: string,
	destination: []u8,
	color: u32,
	x, y, left, top, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) -> smgui.Error {
	if font_data == nil || len(destination) == 0 || pitch < 4 || crop_x1 < 1 || crop_y1 < 1 {
		return .Invalid_Input
	}
	font := (^Font)(font_data)
	origin_x := x
	cursor_x := x
	cursor_y := y
	_ = left
	_ = top

	for character in text {
		switch character {
		case '\r':
			cursor_x = origin_x
		case '\n':
			cursor_x = origin_x
			cursor_y += font.height
		case:
			codepoint := int(character)
			if codepoint <= 0 || codepoint >= font.glyph_count {
				codepoint = 0
			}
			draw_glyph(
				font,
				codepoint,
				destination,
				color,
				cursor_x,
				cursor_y,
				pitch,
				crop_x0,
				crop_y0,
				crop_x1,
				crop_y1,
			)
			cursor_x += font.width + 1
		}
	}
	return .None
}

@(private = "file")
draw_glyph :: proc(
	font: ^Font,
	codepoint: int,
	destination: []u8,
	color: u32,
	x, y, pitch: int,
	crop_x0, crop_y0, crop_x1, crop_y1: int,
) {
	// Match the reference PSF2 hook: a glyph beginning outside the crop is
	// discarded rather than partially rendered from its left or top edge.
	if x < crop_x0 || y < crop_y0 || x >= crop_x1 || y >= crop_y1 {
		return
	}
	bytes_per_line := (font.width + 7) / 8
	glyph_offset := font.header_size + codepoint * font.bytes_per_glyph

	for glyph_y in 0 ..< font.height {
		destination_y := y + glyph_y
		if destination_y < crop_y0 || destination_y >= crop_y1 {
			continue
		}
		for glyph_x in 0 ..< font.width {
			destination_x := x + glyph_x
			if destination_x < crop_x0 || destination_x >= crop_x1 {
				continue
			}
			byte_index := glyph_offset + glyph_y * bytes_per_line + glyph_x / 8
			mask := u8(0x80 >> u8(glyph_x % 8))
			if u8(font.data[byte_index]) & mask == 0 {
				continue
			}
			pixel := destination_y * pitch + destination_x * 4
			if pixel < 0 || pixel + 3 >= len(destination) {
				continue
			}
			destination[pixel + 0] = u8(color)
			destination[pixel + 1] = u8(color >> 8)
			destination[pixel + 2] = u8(color >> 16)
			destination[pixel + 3] = u8(color >> 24)
		}
	}
}
