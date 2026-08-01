/* Small deterministic reference-C framebuffer parity fixtures. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STB_IMAGE_IMPLEMENTATION
#define STBI_NO_STDIO
#define STBI_NO_LINEAR
#define STBI_ONLY_PNG
#include <stb_image.h>

#include "ui_image_backend.h"

static int parse_dimension(const char *text, int minimum, int maximum, int *value)
{
    char *end;
    long parsed = strtol(text, &end, 10);
    if (!text[0] || *end || parsed < minimum || parsed > maximum) return 0;
    *value = (int)parsed;
    return 1;
}

static int apply_environment_skin(ui_t *context)
{
    const char *path = getenv("SMGUI_PARITY_SKIN");
    unsigned char *png;
    FILE *file;
    long size;
    int result;
    if (!path || !path[0]) return UI_OK;
    file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "unable to open SMGUI_PARITY_SKIN %s\n", path);
        return UI_ERR_BADINP;
    }
    if (fseek(file, 0, SEEK_END) || (size = ftell(file)) < 1 || fseek(file, 0, SEEK_SET)) {
        fclose(file);
        fprintf(stderr, "unable to size SMGUI_PARITY_SKIN %s\n", path);
        return UI_ERR_BADINP;
    }
    png = (unsigned char *)malloc((size_t)size);
    if (!png || fread(png, 1, (size_t)size, file) != (size_t)size) {
        fclose(file);
        free(png);
        fprintf(stderr, "unable to read SMGUI_PARITY_SKIN %s\n", path);
        return UI_ERR_BADINP;
    }
    fclose(file);
    result = ui_pngskin(context, png, (int)size);
    free(png);
    if (result != UI_OK) {
        fprintf(stderr, "unable to decode SMGUI_PARITY_SKIN %s: %d\n", path, result);
        return result;
    }
    /* Cursor parity is independent from widget-skin parity. */
    return ui_hwcursor(context);
}

int main(int argc, char **argv)
{
    enum { WINDOW_TITLE, LABEL_TEXT, BUTTON_TEXT, BUTTON_SHORT_TEXT, CHECKBOX_TEXT, RADIO_TEXT, POPUP_TEXT, MENU_TEXT, MENU_ITEM_TEXT, MULTILINE_TEXT, LAYOUT_TEXT };
    char *texts[] = { "Parity fixture", "Label", "Button", "Btn", "Check", "Radio", "Panel", "Menu", "Open", "Alpha\nBeta", "X" };
    int checked = 0;
    int radio_value = 0;
    int selected_radio_value = 1;
    int pressed_radio_value = 0;
    int slider_value = 0;
    int slider_midpoint_value = 50;
    int slider_maximum_value = 100;
    int slider_interaction_value = 0;
    int vertical_scrollbar_value = 50;
    int horizontal_scrollbar_value = 50;
    int64_t progress_value = 0;
    int64_t progress_midpoint_value = 50;
    int64_t decimal_value = 42;
    int64_t decimal_negative_value = -42;
    uint64_t hexadecimal_value = 0x2a;
    uint64_t hexadecimal_zero_value = 0;
    float float_value = 12.345f;
    float float_magnitude_value = 123456.0f;
    char text_input_value[16] = "Hello";
    char text_input_empty_value[16] = "";
    char text_input_edit_value[16] = "Hello";
    char text_input_overflow_value[32] = "ABCDEFGHIJKLMNO";
    int64_t numeric_input_value = 42;
    int64_t numeric_input_decrement_value = 42;
    int64_t numeric_input_increment_value = 42;
    int select_value = 0;
    int select_choice_value = -1;
    char *select_options[] = { "Alpha", "Beta" };
    int option_value = 0;
    int option_decrement_value = 0;
    int option_increment_value = 1;
    char *option_options[] = { "One", "Two" };
    int64_t progress_maximum_value = 100;
    int menu_choice_value = 0;
    int checked_value = 1;
    int pressed_value = 0;
    ui_form_t empty[] = {
        { .type = UI_END }
    };
    ui_form_t label_normal[] = {
        { .type = UI_LABEL, .label = LABEL_TEXT },
        { .type = UI_END }
    };
    ui_form_t multiline_normal[] = {
        { .type = UI_MLINE, .label = MULTILINE_TEXT },
        { .type = UI_END }
    };
    ui_form_t status_normal[] = {
        { .type = UI_STATUS, .w = 52, .ptr = "Ready" },
        { .type = UI_END }
    };
    ui_form_t button_normal[] = {
        { .type = UI_BUTTON, .label = BUTTON_TEXT },
        { .type = UI_END }
    };
    ui_form_t button_explicit_size[] = {
        { .type = UI_BUTTON, .label = BUTTON_SHORT_TEXT, .w = 58, .h = 28 },
        { .type = UI_END }
    };
    ui_form_t button_hover[] = {
        { .type = UI_BUTTON, .label = BUTTON_TEXT },
        { .type = UI_END }
    };
    ui_form_t button_pressed[] = {
        { .type = UI_BUTTON, .label = BUTTON_TEXT },
        { .type = UI_END }
    };
    ui_form_t button_disabled[] = {
        { .type = UI_BUTTON, .flags = UI_DISABLED, .label = BUTTON_TEXT },
        { .type = UI_END }
    };
    ui_form_t checkbox_normal[] = {
        { .type = UI_CHECK, .label = CHECKBOX_TEXT, .ptr = &checked },
        { .type = UI_END }
    };
    ui_form_t checkbox_checked[] = {
        { .type = UI_CHECK, .label = CHECKBOX_TEXT, .ptr = &checked_value },
        { .type = UI_END }
    };
    ui_form_t checkbox_hover[] = {
        { .type = UI_CHECK, .label = CHECKBOX_TEXT, .ptr = &checked },
        { .type = UI_END }
    };
    ui_form_t checkbox_pressed[] = {
        { .type = UI_CHECK, .label = CHECKBOX_TEXT, .ptr = &pressed_value },
        { .type = UI_END }
    };
    ui_form_t checkbox_disabled[] = {
        { .type = UI_CHECK, .flags = UI_DISABLED, .label = CHECKBOX_TEXT, .ptr = &checked },
        { .type = UI_END }
    };
    ui_form_t radio_normal[] = {
        { .type = UI_RADIO, .label = RADIO_TEXT, .ptr = &radio_value, .value = 1 },
        { .type = UI_END }
    };
    ui_form_t radio_selected[] = {
        { .type = UI_RADIO, .label = RADIO_TEXT, .ptr = &selected_radio_value, .value = 1 },
        { .type = UI_END }
    };
    ui_form_t radio_hover[] = {
        { .type = UI_RADIO, .label = RADIO_TEXT, .ptr = &radio_value, .value = 1 },
        { .type = UI_END }
    };
    ui_form_t radio_pressed[] = {
        { .type = UI_RADIO, .label = RADIO_TEXT, .ptr = &pressed_radio_value, .value = 1 },
        { .type = UI_END }
    };
    ui_form_t radio_disabled[] = {
        { .type = UI_RADIO, .flags = UI_DISABLED, .label = RADIO_TEXT, .ptr = &radio_value, .value = 1 },
        { .type = UI_END }
    };
    ui_form_t slider_minimum[] = {
        { .type = UI_SLIDER, .w = 58, .h = 20, .ptr = &slider_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t slider_midpoint[] = {
        { .type = UI_SLIDER, .w = 58, .h = 20, .ptr = &slider_midpoint_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t slider_maximum[] = {
        { .type = UI_SLIDER, .w = 58, .h = 20, .ptr = &slider_maximum_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t slider_interaction[] = {
        { .type = UI_SLIDER, .w = 58, .h = 20, .ptr = &slider_interaction_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t slider_disabled[] = {
        { .type = UI_SLIDER, .flags = UI_DISABLED, .w = 58, .h = 20, .ptr = &slider_midpoint_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t vertical_scrollbar_normal[] = {
        { .type = UI_VSCRBAR, .h = 40, .ptr = &vertical_scrollbar_value, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t horizontal_scrollbar_normal[] = {
        { .type = UI_HSCRBAR, .w = 58, .ptr = &horizontal_scrollbar_value, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t progress_minimum[] = {
        { .type = UI_PBAR, .w = 58, .h = 20, .ptr = &progress_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t progress_midpoint[] = {
        { .type = UI_PBAR, .w = 58, .h = 20, .ptr = &progress_midpoint_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t progress_maximum[] = {
        { .type = UI_PBAR, .w = 58, .h = 20, .ptr = &progress_maximum_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t progress_disabled[] = {
        { .type = UI_PBAR, .flags = UI_DISABLED, .w = 58, .h = 20, .ptr = &progress_midpoint_value, .min = 0, .max = 100 },
        { .type = UI_END }
    };
    ui_form_t decimal_normal[] = {
        { .type = UI_DEC64, .ptr = &decimal_value },
        { .type = UI_END }
    };
    ui_form_t decimal_negative[] = {
        { .type = UI_DEC64, .ptr = &decimal_negative_value },
        { .type = UI_END }
    };
    ui_form_t decimal_explicit_size[] = {
        { .type = UI_DEC64, .w = 58, .h = 28, .ptr = &decimal_value },
        { .type = UI_END }
    };
    ui_form_t decimal_disabled[] = {
        { .type = UI_DEC64, .flags = UI_DISABLED, .ptr = &decimal_value },
        { .type = UI_END }
    };
    ui_form_t hex_normal[] = {
        { .type = UI_HEX64, .ptr = &hexadecimal_value },
        { .type = UI_END }
    };
    ui_form_t hex_zero[] = {
        { .type = UI_HEX64, .ptr = &hexadecimal_zero_value },
        { .type = UI_END }
    };
    ui_form_t hex_explicit_size[] = {
        { .type = UI_HEX64, .w = 58, .h = 28, .ptr = &hexadecimal_value },
        { .type = UI_END }
    };
    ui_form_t hex_disabled[] = {
        { .type = UI_HEX64, .flags = UI_DISABLED, .ptr = &hexadecimal_value },
        { .type = UI_END }
    };
    ui_form_t float_normal[] = {
        { .type = UI_DEC_FLOAT, .ptr = &float_value },
        { .type = UI_END }
    };
    ui_form_t float_magnitude[] = {
        { .type = UI_DEC_FLOAT, .ptr = &float_magnitude_value },
        { .type = UI_END }
    };
    ui_form_t float_explicit_size[] = {
        { .type = UI_DEC_FLOAT, .w = 76, .h = 28, .ptr = &float_magnitude_value },
        { .type = UI_END }
    };
    ui_form_t float_disabled[] = {
        { .type = UI_DEC_FLOAT, .flags = UI_DISABLED, .ptr = &float_value },
        { .type = UI_END }
    };
    ui_form_t text_input_normal[] = {
        { .type = UI_TXTINP, .ptr = text_input_value, .max = sizeof(text_input_value) },
        { .type = UI_END }
    };
    ui_form_t text_input_empty[] = {
        { .type = UI_TXTINP, .ptr = text_input_empty_value, .max = sizeof(text_input_empty_value) },
        { .type = UI_END }
    };
    ui_form_t text_input_explicit_size[] = {
        { .type = UI_TXTINP, .w = 76, .h = 28, .ptr = text_input_value, .max = sizeof(text_input_value) },
        { .type = UI_END }
    };
    ui_form_t text_input_edit[] = {
        { .type = UI_TXTINP, .w = 76, .h = 28, .ptr = text_input_edit_value, .max = sizeof(text_input_edit_value) },
        { .type = UI_END }
    };
    ui_form_t text_input_overflow_edit[] = {
        { .type = UI_TXTINP, .w = 58, .h = 28, .ptr = text_input_overflow_value, .max = sizeof(text_input_overflow_value) },
        { .type = UI_END }
    };
    ui_form_t text_input_disabled[] = {
        { .type = UI_TXTINP, .flags = UI_DISABLED, .ptr = text_input_value, .max = sizeof(text_input_value) },
        { .type = UI_END }
    };
    ui_form_t numeric_input_normal[] = {
        { .type = UI_INT64, .ptr = &numeric_input_value, .min = 0, .max = 100, .inc = 5 }, { .type = UI_END }
    };
    ui_form_t numeric_input_explicit_size[] = {
        { .type = UI_INT64, .w = 90, .h = 28, .ptr = &numeric_input_value, .min = 0, .max = 100, .inc = 5 }, { .type = UI_END }
    };
    ui_form_t numeric_input_decrement[] = {
        { .type = UI_INT64, .ptr = &numeric_input_decrement_value, .min = 0, .max = 100, .inc = 5 }, { .type = UI_END }
    };
    ui_form_t numeric_input_increment[] = {
        { .type = UI_INT64, .ptr = &numeric_input_increment_value, .min = 0, .max = 100, .inc = 5 }, { .type = UI_END }
    };
    ui_form_t numeric_input_disabled[] = {
        { .type = UI_INT64, .flags = UI_DISABLED, .ptr = &numeric_input_value, .min = 0, .max = 100, .inc = 5 }, { .type = UI_END }
    };
    ui_form_t select_normal[] = {
        { .type = UI_SELECT, .ptr = &select_value, .optc = 2, .optv = select_options }, { .type = UI_END }
    };
    ui_form_t select_explicit_size[] = {
        { .type = UI_SELECT, .w = 76, .h = 28, .ptr = &select_value, .optc = 2, .optv = select_options }, { .type = UI_END }
    };
    ui_form_t select_pressed[] = {
        { .type = UI_SELECT, .ptr = &select_value, .optc = 2, .optv = select_options }, { .type = UI_END }
    };
    ui_form_t select_open[] = {
        { .type = UI_SELECT, .y = 10, .ptr = &select_value, .optc = 2, .optv = select_options }, { .type = UI_END }
    };
    ui_form_t select_choice[] = {
        { .type = UI_SELECT, .y = 10, .ptr = &select_choice_value, .optc = 2, .optv = select_options }, { .type = UI_END }
    };
    ui_form_t select_disabled[] = {
        { .type = UI_SELECT, .flags = UI_DISABLED, .ptr = &select_value, .optc = 2, .optv = select_options }, { .type = UI_END }
    };
    ui_form_t option_normal[] = {
        { .type = UI_OPTION, .ptr = &option_value, .optc = 2, .optv = option_options }, { .type = UI_END }
    };
    ui_form_t option_explicit_size[] = {
        { .type = UI_OPTION, .w = 90, .h = 28, .ptr = &option_value, .optc = 2, .optv = option_options }, { .type = UI_END }
    };
    ui_form_t option_decrement[] = {
        { .type = UI_OPTION, .ptr = &option_decrement_value, .optc = 2, .optv = option_options }, { .type = UI_END }
    };
    ui_form_t option_increment[] = {
        { .type = UI_OPTION, .ptr = &option_increment_value, .optc = 2, .optv = option_options }, { .type = UI_END }
    };
    ui_form_t option_disabled[] = {
        { .type = UI_OPTION, .flags = UI_DISABLED, .ptr = &option_value, .optc = 2, .optv = option_options }, { .type = UI_END }
    };
    ui_form_t division_label_children[] = {
        { .type = UI_LABEL, .label = LABEL_TEXT }, { .type = UI_END }
    };
    ui_form_t division_intrinsic[] = {
        { .type = UI_DIV, .x = UI_ABS(5), .y = UI_ABS(5), .m = 4, .ptr = division_label_children }, { .type = UI_END }
    };
    ui_form_t division_percentage[] = {
        { .type = UI_DIV, .w = UI_PERCENT(100), .m = 4, .ptr = division_label_children }, { .type = UI_END }
    };
    ui_form_t layout_alignment[] = {
        { .type = UI_LABEL, .x = UI_ABS(20), .y = UI_ABS(14), .w = 10, .h = 20, .align = UI_CENTER | UI_MIDDLE, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .x = UI_ABS(52), .y = UI_ABS(36), .w = 10, .h = 20, .align = UI_RIGHT | UI_BOTTOM, .label = LAYOUT_TEXT },
        { .type = UI_END }
    };
    ui_form_t layout_from_end[] = {
        { .type = UI_LABEL, .x = UI_ABS_RIGHT(8), .y = UI_ABS_BOTTOM(8), .w = 10, .h = 20, .align = UI_RIGHT | UI_BOTTOM, .label = LAYOUT_TEXT },
        { .type = UI_END }
    };
    ui_form_t layout_percent[] = {
        { .type = UI_LABEL, .x = UI_PERPLUS(50, 3), .y = UI_PERPLUS(50, 2), .w = 10, .h = 20, .align = UI_CENTER | UI_MIDDLE, .label = LAYOUT_TEXT },
        { .type = UI_END }
    };
    ui_form_t layout_right_flow_children[] = {
        { .type = UI_LABEL, .align = UI_RIGHT, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .align = UI_RIGHT, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .align = UI_RIGHT, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_END }
    };
    ui_form_t layout_right_flow[] = {
        { .type = UI_DIV, .x = UI_ABS(5), .y = UI_ABS(5), .w = 40, .h = 50, .m = 3, .p = 4, .ptr = layout_right_flow_children },
        { .type = UI_END }
    };
    ui_form_t layout_flow_children[] = {
        { .type = UI_LABEL, .flags = UI_NOBR, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .flags = UI_FORCEBR, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_END }
    };
    ui_form_t layout_flow[] = {
        { .type = UI_DIV, .x = UI_ABS(5), .y = UI_ABS(5), .w = 40, .h = 50, .m = 3, .p = 4, .ptr = layout_flow_children },
        { .type = UI_END }
    };
    ui_form_t layout_hidden_flow[] = {
        { .type = UI_LABEL, .flags = UI_NOBR, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .flags = UI_HIDDEN, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .flags = UI_FORCEBR, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_LABEL, .flags = UI_FORCEBR, .w = 10, .h = 20, .label = LAYOUT_TEXT },
        { .type = UI_END }
    };
    ui_form_t popup_empty_children[] = { { .type = UI_END } };
    ui_form_t popup_content_children[] = {
        { .type = UI_LABEL, .label = LABEL_TEXT }, { .type = UI_END }
    };
    ui_form_t popup_normal[] = {
        { .type = UI_POPUP, .x = UI_ABS(5), .y = UI_ABS(5), .w = 50, .h = 35, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_intrinsic[] = {
        { .type = UI_POPUP, .x = UI_ABS(5), .y = UI_ABS(5), .ptr = popup_content_children }, { .type = UI_END }
    };
    ui_form_t popup_no_border[] = {
        { .type = UI_POPUP, .flags = UI_NOBORDER, .x = UI_ABS(5), .y = UI_ABS(5), .w = 50, .h = 35, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_no_shadow[] = {
        { .type = UI_POPUP, .flags = UI_NOSHADOW, .x = UI_ABS(5), .y = UI_ABS(5), .w = 50, .h = 35, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_title[] = {
        { .type = UI_POPUP, .x = UI_ABS(5), .y = UI_ABS(5), .w = 55, .h = 40, .label = POPUP_TEXT, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_draggable[] = {
        { .type = UI_POPUP, .flags = UI_DRAGGABLE, .x = UI_ABS(5), .y = UI_ABS(5), .w = 55, .h = 40, .label = POPUP_TEXT, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_chrome[] = {
        { .type = UI_POPUP, .flags = UI_DRAGGABLE | UI_RESIZABLE, .x = UI_ABS(5), .y = UI_ABS(5), .w = 55, .h = 40, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_resizable[] = {
        { .type = UI_POPUP, .flags = UI_RESIZABLE, .x = UI_ABS(5), .y = UI_ABS(5), .w = 50, .h = 35, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_hidden[] = {
        { .type = UI_POPUP, .flags = UI_HIDDEN, .x = UI_ABS(5), .y = UI_ABS(5), .w = 50, .h = 35, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_close[] = {
        { .type = UI_POPUP, .flags = UI_DRAGGABLE, .x = UI_ABS(5), .y = UI_ABS(5), .w = 55, .h = 40, .label = POPUP_TEXT, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_drag[] = {
        { .type = UI_POPUP, .flags = UI_DRAGGABLE, .x = UI_ABS(5), .y = UI_ABS(5), .w = 55, .h = 40, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t popup_resize[] = {
        { .type = UI_POPUP, .flags = UI_RESIZABLE, .x = UI_ABS(5), .y = UI_ABS(5), .w = 55, .h = 40, .ptr = popup_empty_children }, { .type = UI_END }
    };
    ui_form_t menu_label_children[] = {
        { .type = UI_LABEL, .label = MENU_ITEM_TEXT }, { .type = UI_END }
    };
    ui_form_t menu_disabled_children[] = {
        { .type = UI_LABEL, .flags = UI_DISABLED, .label = MENU_ITEM_TEXT }, { .type = UI_END }
    };
    ui_form_t menu_choice_children[] = {
        { .type = UI_RADIO, .label = MENU_ITEM_TEXT, .ptr = &menu_choice_value, .value = 1 }, { .type = UI_END }
    };
    ui_form_t menu_closed[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_button_closed[] = {
        { .type = UI_TOGGLE, .flags = UI_NOBULLET, .m = 4, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_button_open[] = {
        { .type = UI_TOGGLE, .flags = UI_NOBULLET, .m = 4, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_open[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_intrinsic[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_anchored[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_hover[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_disabled[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_disabled_children },
        { .type = UI_END }
    };
    ui_form_t menu_choice[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_choice_children },
        { .type = UI_END }
    };
    ui_form_t menu_outside_close[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t menu_escape_close[] = {
        { .type = UI_TOGGLE, .label = MENU_TEXT },
        { .type = UI_MENU, .x = UI_ABS(5), .y = UI_ABS(22), .w = 50, .h = 24, .ptr = menu_label_children },
        { .type = UI_END }
    };
    ui_form_t *forms;
    ui_t context;
    int result;
    int width;
    int height;

    if (argc != 5) {
        fprintf(stderr, "usage: %s CASE OUTPUT.png WIDTH HEIGHT\n", argv[0]);
        return 2;
    }
    if (!parse_dimension(argv[3], 1, 4096, &width) ||
        !parse_dimension(argv[4], 1, 4096, &height)) {
        fprintf(stderr, "invalid framebuffer dimensions: %sx%s\n", argv[3], argv[4]);
        return 2;
    }
    if (!strcmp(argv[1], "empty")) {
        forms = empty;
    } else if (!strcmp(argv[1], "label-normal")) {
        forms = label_normal;
    } else if (!strcmp(argv[1], "multiline-normal")) {
        forms = multiline_normal;
    } else if (!strcmp(argv[1], "status-normal")) {
        forms = status_normal;
    } else if (!strcmp(argv[1], "button-normal")) {
        forms = button_normal;
    } else if (!strcmp(argv[1], "button-explicit-size")) {
        forms = button_explicit_size;
    } else if (!strcmp(argv[1], "button-hover")) {
        forms = button_hover;
    } else if (!strcmp(argv[1], "button-pressed")) {
        forms = button_pressed;
    } else if (!strcmp(argv[1], "button-disabled")) {
        forms = button_disabled;
    } else if (!strcmp(argv[1], "checkbox-normal")) {
        forms = checkbox_normal;
    } else if (!strcmp(argv[1], "checkbox-checked")) {
        forms = checkbox_checked;
    } else if (!strcmp(argv[1], "checkbox-hover")) {
        forms = checkbox_hover;
    } else if (!strcmp(argv[1], "checkbox-pressed")) {
        forms = checkbox_pressed;
    } else if (!strcmp(argv[1], "checkbox-disabled")) {
        forms = checkbox_disabled;
    } else if (!strcmp(argv[1], "radio-normal")) {
        forms = radio_normal;
    } else if (!strcmp(argv[1], "radio-selected")) {
        forms = radio_selected;
    } else if (!strcmp(argv[1], "radio-hover")) {
        forms = radio_hover;
    } else if (!strcmp(argv[1], "radio-pressed")) {
        forms = radio_pressed;
    } else if (!strcmp(argv[1], "radio-disabled")) {
        forms = radio_disabled;
    } else if (!strcmp(argv[1], "slider-minimum")) {
        forms = slider_minimum;
    } else if (!strcmp(argv[1], "slider-midpoint")) {
        forms = slider_midpoint;
    } else if (!strcmp(argv[1], "slider-maximum")) {
        forms = slider_maximum;
    } else if (!strcmp(argv[1], "slider-interaction")) {
        forms = slider_interaction;
    } else if (!strcmp(argv[1], "slider-disabled")) {
        forms = slider_disabled;
    } else if (!strcmp(argv[1], "vertical-scrollbar-normal")) {
        forms = vertical_scrollbar_normal;
    } else if (!strcmp(argv[1], "horizontal-scrollbar-normal")) {
        forms = horizontal_scrollbar_normal;
    } else if (!strcmp(argv[1], "progress-minimum")) {
        forms = progress_minimum;
    } else if (!strcmp(argv[1], "progress-midpoint")) {
        forms = progress_midpoint;
    } else if (!strcmp(argv[1], "progress-maximum")) {
        forms = progress_maximum;
    } else if (!strcmp(argv[1], "progress-disabled")) {
        forms = progress_disabled;
    } else if (!strcmp(argv[1], "decimal-normal")) {
        forms = decimal_normal;
    } else if (!strcmp(argv[1], "decimal-negative")) {
        forms = decimal_negative;
    } else if (!strcmp(argv[1], "decimal-explicit-size")) {
        forms = decimal_explicit_size;
    } else if (!strcmp(argv[1], "decimal-disabled")) {
        forms = decimal_disabled;
    } else if (!strcmp(argv[1], "hex-normal")) {
        forms = hex_normal;
    } else if (!strcmp(argv[1], "hex-zero")) {
        forms = hex_zero;
    } else if (!strcmp(argv[1], "hex-explicit-size")) {
        forms = hex_explicit_size;
    } else if (!strcmp(argv[1], "hex-disabled")) {
        forms = hex_disabled;
    } else if (!strcmp(argv[1], "float-normal")) {
        forms = float_normal;
    } else if (!strcmp(argv[1], "float-magnitude")) {
        forms = float_magnitude;
    } else if (!strcmp(argv[1], "float-explicit-size")) {
        forms = float_explicit_size;
    } else if (!strcmp(argv[1], "float-disabled")) {
        forms = float_disabled;
    } else if (!strcmp(argv[1], "text-input-normal")) {
        forms = text_input_normal;
    } else if (!strcmp(argv[1], "text-input-empty")) {
        forms = text_input_empty;
    } else if (!strcmp(argv[1], "text-input-explicit-size")) {
        forms = text_input_explicit_size;
    } else if (!strcmp(argv[1], "text-input-edit")) {
        forms = text_input_edit;
    } else if (!strcmp(argv[1], "text-input-overflow-edit")) {
        forms = text_input_overflow_edit;
    } else if (!strcmp(argv[1], "text-input-disabled")) {
        forms = text_input_disabled;
    } else if (!strcmp(argv[1], "numeric-input-normal")) {
        forms = numeric_input_normal;
    } else if (!strcmp(argv[1], "numeric-input-explicit-size")) {
        forms = numeric_input_explicit_size;
    } else if (!strcmp(argv[1], "numeric-input-decrement")) {
        forms = numeric_input_decrement;
    } else if (!strcmp(argv[1], "numeric-input-increment")) {
        forms = numeric_input_increment;
    } else if (!strcmp(argv[1], "numeric-input-disabled")) {
        forms = numeric_input_disabled;
    } else if (!strcmp(argv[1], "select-normal")) {
        forms = select_normal;
    } else if (!strcmp(argv[1], "select-explicit-size")) {
        forms = select_explicit_size;
    } else if (!strcmp(argv[1], "select-pressed")) {
        forms = select_pressed;
    } else if (!strcmp(argv[1], "select-open")) {
        forms = select_open;
    } else if (!strcmp(argv[1], "select-choice")) {
        forms = select_choice;
    } else if (!strcmp(argv[1], "select-disabled")) {
        forms = select_disabled;
    } else if (!strcmp(argv[1], "option-normal")) {
        forms = option_normal;
    } else if (!strcmp(argv[1], "option-explicit-size")) {
        forms = option_explicit_size;
    } else if (!strcmp(argv[1], "option-decrement")) {
        forms = option_decrement;
    } else if (!strcmp(argv[1], "option-increment")) {
        forms = option_increment;
    } else if (!strcmp(argv[1], "option-disabled")) {
        forms = option_disabled;
    } else if (!strcmp(argv[1], "division-intrinsic")) {
        forms = division_intrinsic;
    } else if (!strcmp(argv[1], "division-percentage")) {
        forms = division_percentage;
    } else if (!strcmp(argv[1], "layout-alignment")) {
        forms = layout_alignment;
    } else if (!strcmp(argv[1], "layout-from-end")) {
        forms = layout_from_end;
    } else if (!strcmp(argv[1], "layout-percent")) {
        forms = layout_percent;
    } else if (!strcmp(argv[1], "layout-right-flow")) {
        forms = layout_right_flow;
    } else if (!strcmp(argv[1], "layout-flow")) {
        forms = layout_flow;
    } else if (!strcmp(argv[1], "layout-hidden-flow")) {
        forms = layout_hidden_flow;
    } else if (!strcmp(argv[1], "popup-normal")) {
        forms = popup_normal;
    } else if (!strcmp(argv[1], "popup-intrinsic")) {
        forms = popup_intrinsic;
    } else if (!strcmp(argv[1], "popup-no-border")) {
        forms = popup_no_border;
    } else if (!strcmp(argv[1], "popup-no-shadow")) {
        forms = popup_no_shadow;
    } else if (!strcmp(argv[1], "popup-title")) {
        forms = popup_title;
    } else if (!strcmp(argv[1], "popup-draggable")) {
        forms = popup_draggable;
    } else if (!strcmp(argv[1], "popup-chrome")) {
        forms = popup_chrome;
    } else if (!strcmp(argv[1], "popup-resizable")) {
        forms = popup_resizable;
    } else if (!strcmp(argv[1], "popup-hidden")) {
        forms = popup_hidden;
    } else if (!strcmp(argv[1], "popup-close")) {
        forms = popup_close;
    } else if (!strcmp(argv[1], "popup-drag")) {
        forms = popup_drag;
    } else if (!strcmp(argv[1], "popup-resize")) {
        forms = popup_resize;
    } else if (!strcmp(argv[1], "menu-closed")) {
        forms = menu_closed;
    } else if (!strcmp(argv[1], "menu-button-closed")) {
        forms = menu_button_closed;
    } else if (!strcmp(argv[1], "menu-button-open")) {
        forms = menu_button_open;
    } else if (!strcmp(argv[1], "menu-open")) {
        forms = menu_open;
    } else if (!strcmp(argv[1], "menu-intrinsic")) {
        forms = menu_intrinsic;
    } else if (!strcmp(argv[1], "menu-anchored")) {
        forms = menu_anchored;
    } else if (!strcmp(argv[1], "menu-hover")) {
        forms = menu_hover;
    } else if (!strcmp(argv[1], "menu-disabled")) {
        forms = menu_disabled;
    } else if (!strcmp(argv[1], "menu-choice")) {
        forms = menu_choice;
    } else if (!strcmp(argv[1], "menu-outside-close")) {
        forms = menu_outside_close;
    } else if (!strcmp(argv[1], "menu-escape-close")) {
        forms = menu_escape_close;
    } else {
        fprintf(stderr, "unknown parity case: %s\n", argv[1]);
        return 2;
    }

    ui_image_backend_set_output(argv[2]);
    if (!strcmp(argv[1], "button-hover") || !strcmp(argv[1], "checkbox-hover") ||
        !strcmp(argv[1], "radio-hover")) {
        ui_image_backend_set_mouse_event(10, 10, 0);
    } else if (!strcmp(argv[1], "slider-interaction")) {
        ui_image_backend_set_mouse_event(29, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "button-pressed") || !strcmp(argv[1], "checkbox-pressed") ||
        !strcmp(argv[1], "radio-pressed")) {
        ui_image_backend_set_mouse_event(10, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "text-input-edit")) {
        ui_image_backend_set_text_edit_events(60, 10, "!");
    } else if (!strcmp(argv[1], "text-input-overflow-edit")) {
        ui_image_backend_set_mouse_event(50, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "numeric-input-decrement")) {
        ui_image_backend_set_mouse_event(10, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "numeric-input-increment")) {
        ui_image_backend_set_mouse_event(61, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "select-pressed")) {
        ui_image_backend_set_select_pressed_events(10, 10);
    } else if (!strcmp(argv[1], "select-open")) {
        ui_image_backend_set_select_open_events(10, 15);
    } else if (!strcmp(argv[1], "select-choice")) {
        ui_image_backend_set_select_choice_events(10, 15);
    } else if (!strcmp(argv[1], "option-decrement")) {
        ui_image_backend_set_mouse_event(10, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "option-increment")) {
        ui_image_backend_set_mouse_event(55, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "popup-close")) {
        ui_image_backend_set_two_mouse_events(50, 10, 0, 50, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "popup-drag")) {
        ui_image_backend_set_popup_motion_events(10, 10, 25, 20);
    } else if (!strcmp(argv[1], "popup-resize")) {
        ui_image_backend_set_popup_motion_events(57, 42, 47, 32);
    } else if (!strcmp(argv[1], "menu-open") || !strcmp(argv[1], "menu-button-open") ||
               !strcmp(argv[1], "menu-intrinsic") || !strcmp(argv[1], "menu-anchored")) {
        ui_image_backend_set_two_mouse_events(10, 10, 0, 10, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "menu-hover") || !strcmp(argv[1], "menu-disabled")) {
        ui_image_backend_set_menu_item_events(10, 10, 0, 10, 10, UI_BTN_L, 10, 30, UI_BTN_RELEASE);
    } else if (!strcmp(argv[1], "menu-choice")) {
        ui_image_backend_set_menu_item_events(10, 10, 0, 10, 10, UI_BTN_L, 10, 30, UI_BTN_L | UI_BTN_RELEASE);
    } else if (!strcmp(argv[1], "menu-outside-close")) {
        ui_image_backend_set_menu_item_events(10, 10, 0, 10, 10, UI_BTN_L, 60, 10, UI_BTN_L);
    } else if (!strcmp(argv[1], "menu-escape-close")) {
        ui_image_backend_set_mouse_then_key_events(10, 10, UI_BTN_L, '\x1b');
    }
    if (!strncmp(argv[1], "menu-", 5) && strcmp(argv[1], "menu-closed")) {
        ui_image_backend_set_event_gap(1);
    }
    result = ui_init(&context, (int)(sizeof(texts) / sizeof(texts[0])), texts, width, height, NULL);
    if (result != UI_OK) {
        fprintf(stderr, "ui_init failed: %d\n", result);
        return 1;
    }
    result = apply_environment_skin(&context);
    if (result != UI_OK) {
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "button-normal") || !strcmp(argv[1], "button-explicit-size") ||
        (!strcmp(argv[1], "checkbox-normal") || !strcmp(argv[1], "checkbox-checked")) ||
        (!strcmp(argv[1], "radio-normal") || !strcmp(argv[1], "radio-selected")) ||
        (!strcmp(argv[1], "slider-minimum") || !strcmp(argv[1], "slider-midpoint") ||
         !strcmp(argv[1], "slider-maximum")) ||
        !strcmp(argv[1], "select-normal") || !strcmp(argv[1], "select-explicit-size") ||
        !strcmp(argv[1], "option-normal") || !strcmp(argv[1], "option-explicit-size")) {
        context.mousex = -1;
        context.mousey = -1;
    }
    while (ui_event(&context, forms)) { }
    if (!strcmp(argv[1], "division-intrinsic") &&
        (division_intrinsic[0].ew != 57 || division_intrinsic[0].eh != 32)) {
        fprintf(stderr, "intrinsic division measured %dx%d instead of 57x32\n",
            division_intrinsic[0].ew, division_intrinsic[0].eh);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "division-percentage") &&
        (division_percentage[0].ew != (width < 57 ? 57 : width) || division_percentage[0].eh != 32)) {
        fprintf(stderr, "percentage division measured %dx%d instead of %dx32\n",
            division_percentage[0].ew, division_percentage[0].eh, width < 57 ? 57 : width);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "slider-interaction") && slider_interaction_value != 53) {
        fprintf(stderr, "slider interaction produced %d instead of 53\n", slider_interaction_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "radio-pressed") && pressed_radio_value != 1) {
        fprintf(stderr, "radio press did not update its bound value\n");
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "checkbox-pressed") && pressed_value != 1) {
        fprintf(stderr, "checkbox press did not update its bound value\n");
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "text-input-edit") && strcmp(text_input_edit_value, "Hello!")) {
        fprintf(stderr, "text input edit produced %s instead of Hello!\n", text_input_edit_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "numeric-input-decrement") && numeric_input_decrement_value != 37) {
        fprintf(stderr, "numeric decrement produced %lld instead of 37\n", (long long)numeric_input_decrement_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "numeric-input-increment") && numeric_input_increment_value != 47) {
        fprintf(stderr, "numeric increment produced %lld instead of 47\n", (long long)numeric_input_increment_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "select-choice") && select_choice_value != 0) {
        fprintf(stderr, "select choice produced %d instead of 0\n", select_choice_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "option-decrement") && option_decrement_value != 1) {
        fprintf(stderr, "option decrement produced %d instead of 1\n", option_decrement_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "option-increment") && option_increment_value != 0) {
        fprintf(stderr, "option increment produced %d instead of 0\n", option_increment_value);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "popup-close") && !(popup_close[0].flags & UI_HIDDEN)) {
        fprintf(stderr, "popup close did not hide the popup\n");
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "popup-drag") &&
        (popup_drag[0].ex != (width < 76 ? width - 56 : 20) ||
         popup_drag[0].ey != (height < 56 ? height - 41 : 15))) {
        fprintf(stderr, "popup drag moved to %d,%d instead of %d,%d\n",
            popup_drag[0].ex, popup_drag[0].ey,
            width < 76 ? width - 56 : 20, height < 56 ? height - 41 : 15);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "popup-resize") && (popup_resize[0].ew != 45 || popup_resize[0].eh != 30)) {
        fprintf(stderr, "popup resize produced %dx%d instead of 45x30\n", popup_resize[0].ew, popup_resize[0].eh);
        ui_free(&context);
        return 1;
    }
    if (!strcmp(argv[1], "menu-choice") && menu_choice_value != 1) {
        fprintf(stderr, "menu choice did not mutate its bound value\n");
        ui_free(&context);
        return 1;
    }
    if (!ui_image_backend_succeeded(&context)) {
        fprintf(stderr, "failed to write %s\n", argv[2]);
        ui_free(&context);
        return 1;
    }
    ui_free(&context);
    return 0;
}
