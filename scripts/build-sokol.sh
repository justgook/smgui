#!/usr/bin/env bash
set -euo pipefail

root=${1:-vendor/sokol-odin/sokol}
os=$(uname -s)
machine=$(uname -m)

case "$os/$machine" in
  Darwin/arm64) platform=macos; arch=arm64; backend=metal ;;
  Darwin/x86_64) platform=macos; arch=x64; backend=metal ;;
  Linux/x86_64|Linux/aarch64) platform=linux; arch=x64; backend=gl ;;
  *) echo "sokol-odin does not provide native libraries for $os/$machine" >&2; exit 2 ;;
esac

compile_source() {
  local source=$1 mode=$2 object=$3 optimization=-O2
  [[ $mode == debug ]] && optimization=-g
  local release_define=()
  [[ $mode == release ]] && release_define=(-DNDEBUG)
  if [[ $platform == macos ]]; then
    MACOSX_DEPLOYMENT_TARGET=10.13 clang -c "$optimization" \
      -Wno-unguarded-availability-new -x objective-c -arch "$machine" \
      "${release_define[@]}" -DIMPL -DSOKOL_METAL \
      "$root/c/$source.c" -o "$object"
  else
    cc -c "$optimization" "${release_define[@]}" -DIMPL -DSOKOL_GLCORE \
      "$root/c/$source.c" -o "$object"
  fi
}

build_one() {
  local source=$1 package=$2 mode=$3 output object extra_object=""
  output="$root/$package/${source}_${platform}_${arch}_${backend}_${mode}.a"
  object=$(mktemp "${TMPDIR:-/tmp}/${source}.XXXXXX.o")
  compile_source "$source" "$mode" "$object"

  # sokol_framebuffer calls sokol_gfx. Keeping a gfx object after the
  # framebuffer object in this archive also makes static linking work when a
  # test only retains event-translation code and the linker's archive order
  # would otherwise leave those symbols unresolved.
  if [[ $source == sokol_framebuffer ]]; then
    extra_object=$(mktemp "${TMPDIR:-/tmp}/sokol_gfx.XXXXXX.o")
    compile_source sokol_gfx "$mode" "$extra_object"
    ar rcs "$output" "$object" "$extra_object"
  else
    ar rcs "$output" "$object"
  fi
  rm -f "$object" ${extra_object:+"$extra_object"}
}

for mode in release debug; do
  build_one sokol_log log "$mode"
  build_one sokol_gfx gfx "$mode"
  build_one sokol_app app "$mode"
  build_one sokol_glue glue "$mode"
  build_one sokol_framebuffer framebuffer "$mode"
done
