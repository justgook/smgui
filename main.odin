package main

/*
Purpose:
  Native smoke-test entry point for the Odin rewrite.

Status:
  [x] Root executable compiles
  [ ] Select a backend adapter
  [ ] Render the first parity fixture

Definition of done:
  - Builds through `make build`
  - Exercises the same basic form as reference-c/examples/helloworld.c
*/

import "core:fmt"
import smgui "smgui"

main :: proc() {
	fmt.printf(
		"SMGUI Odin rewrite: interface scaffold ready (%d theme colors)\n",
		smgui.THEME_COLOR_COUNT,
	)
}
