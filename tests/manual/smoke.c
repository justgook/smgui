/*
 * Paired screen1 parity fixture for examples/smoke/main.odin.
 *
 * This form tree is derived from reference-c/docs/screen1.png. Keep its
 * strings, initial state, dimensions, and forms aligned with the Odin
 * counterpart. The pinned reference remains untouched.
 */

#include <stdint.h>
#include <stdio.h>

#ifdef SMOKE_IMAGE_BACKEND
#include "ui_image_backend.h"
#else
#define UI_IMPLEMENTATION
#include <ui.h>
#endif

static int smoke_custom_bounds(
    ui_t *ctx, int x, int y, int width, int height, ui_form_t *form,
    int *desired_width, int *desired_height)
{
    (void)ctx; (void)x; (void)y; (void)width; (void)height; (void)form;
    *desired_width = 30;
    *desired_height = 16;
    return UI_OK;
}

static int smoke_custom_view(
    ui_t *ctx, int x, int y, int width, int height, ui_form_t *form)
{
    (void)form;
    _ui_frect(ctx, x, y, width, height, 0xff406080);
    return UI_OK;
}

int main(int argc, char **argv)
{
    enum {
        WINDOW_TITLE,
        FILE_MENU,
        LANGUAGE_MENU,
        POPUP_MENU,
        ITEM_1,
        ITEM_2,
        LABELS,
        INPUTS,
        ACTIVE,
        INACTIVE,
        BUTTONS,
        PRESS_ME,
        ONE,
        TWO,
        THREE,
        MULTILINE
    };
    char *texts[] = {
        "Widget parity smoke",
        "File",
        "Language",
        "Popups",
        "Item1",
        "Item2",
        "Labels",
        "Inputs",
        "Active",
        "Inactive",
        "Buttons",
        "Press Me",
        "one",
        "two",
        "three",
        "First line\nSecond line",
    };
    char *options[] = { texts[ONE], texts[TWO], texts[THREE] };

    int menu_option = 0;
    int button_option = 0;
    int icon_button_option = 1;
    int checkbox_option = 0;
    int radio_option = 0;
    int integer_value = 26;
    int8_t decimal_8_value = -8;
    int16_t decimal_16_value = -16;
    int64_t decimal_64_value = -64;
    uint8_t hex_8_value = 0x08;
    uint16_t hex_16_value = 0x16;
    uint64_t hex_64_value = 0x64;
    int8_t integer_8_value = 8;
    int16_t integer_16_value = 16;
    int64_t integer_64_value = 64;
    int option_value = 0;
    int64_t progress_value = 42;
    int horizontal_scroll = 40;
    int vertical_scroll = 80;
    uint32_t color_value = 0xffd06020;
    float float_value = 3.141f;
    char text_value[64] = "Overflowing text field sample";
    uint8_t image_pixels[] = {
        0x20, 0x60, 0xd0, 0xff, 0xd0, 0x80, 0x20, 0xff,
        0x40, 0xc0, 0x60, 0xff, 0xd0, 0x30, 0x80, 0xff,
    };
    ui_image_t sample_image = { .w = 2, .h = 2, .p = 8, .buf = image_pixels };
    ui_form_t toggle_panel_children[] = {
        { .type = UI_IMAGE, .w = 24, .h = 12, .icon = &sample_image },
        { .type = UI_END }
    };

    ui_form_t popup_children[] = {
        { .type = UI_BUTTON, .flags = UI_NOBR, .ptr = &button_option, .value = 1, .label = PRESS_ME },
        { .type = UI_BUTTON, .flags = UI_DISABLED, .ptr = &button_option, .value = 2, .label = PRESS_ME },
        { .type = UI_END }
    };
    ui_form_t file_menu[] = {
        { .type = UI_RADIO, .flags = UI_NOBULLET, .ptr = &menu_option, .value = 1, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_NOBULLET, .ptr = &menu_option, .value = 2, .label = ITEM_2 },
        { .type = UI_END }
    };
    ui_form_t language_menu[] = {
        { .type = UI_RADIO, .flags = UI_NOBULLET, .ptr = &menu_option, .value = 3, .label = ONE },
        { .type = UI_RADIO, .flags = UI_NOBULLET, .ptr = &menu_option, .value = 4, .label = TWO },
        { .type = UI_END }
    };
    ui_form_t popup_menu[] = {
        { .type = UI_TOGGLE, .flags = UI_NOBULLET, .value = 0, .label = ITEM_1 },
        { .type = UI_END }
    };
    ui_form_t label_fields[] = {
        { .type = UI_LABEL, .flags = UI_NOBR, .label = ITEM_1 },
        { .type = UI_DEC8, .flags = UI_NOBR, .w = 28, .ptr = &decimal_8_value },
        { .type = UI_DEC16, .flags = UI_NOBR, .w = 28, .ptr = &decimal_16_value },
        { .type = UI_DEC32, .flags = UI_NOBR, .w = 28, .ptr = &integer_value },
        { .type = UI_DEC64, .flags = UI_NOBR, .w = 28, .ptr = &decimal_64_value },
        { .type = UI_HEX8, .flags = UI_NOBR, .w = 28, .ptr = &hex_8_value },
        { .type = UI_HEX16, .flags = UI_NOBR, .w = 28, .ptr = &hex_16_value },
        { .type = UI_HEX32, .flags = UI_NOBR, .w = 36, .ptr = &integer_value },
        { .type = UI_HEX64, .flags = UI_NOBR, .w = 36, .ptr = &hex_64_value },
        { .type = UI_PBAR, .flags = UI_NOBR, .x = 10, .w = 100, .ptr = &progress_value, .max = 100 },
        { .type = UI_DEC_FLOAT, .w = 80, .ptr = &float_value },
        { .type = UI_MLINE, .label = MULTILINE },
        { .type = UI_STATUS, .w = 160, .ptr = "Ready" },
        { .type = UI_IMAGE, .flags = UI_NOBR, .w = 32, .h = 16, .icon = &sample_image },
        { .type = UI_ICON, .w = 32, .h = 24, .icon = &sample_image },
        { .type = UI_COLOR, .w = 100, .ptr = &color_value },
        { .type = UI_BTNTGL, .flags = UI_NOBR, .label = PRESS_ME, .icon = &sample_image },
        { .type = UI_DIV, .flags = UI_HIDDEN, .ptr = &toggle_panel_children },
        { .type = UI_BTNICN, .w = 24, .h = 16, .ptr = &icon_button_option, .icon = &sample_image },
        { .type = UI_END }
    };
    ui_form_t active_inputs[] = {
        { .type = UI_TEXT, .flags = UI_NOBR, .w = 130, .ptr = &text_value, .max = sizeof(text_value) },
        { .type = UI_SELECT, .flags = UI_NOBR, .x = 10, .m = 17, .w = 80, .ptr = &option_value, .optc = 3, .optv = options },
        /* Wheel events over option and numeric inputs exercise control-first routing. */
        { .type = UI_OPTION, .flags = UI_NOBR, .x = 10, .m = 17, .w = 90, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_INT8, .flags = UI_NOBR, .x = 10, .m = 17, .w = 54, .ptr = &integer_8_value, .min = 1, .max = 32 },
        { .type = UI_INT16, .flags = UI_NOBR, .w = 54, .ptr = &integer_16_value, .min = 1, .max = 32 },
        { .type = UI_INT32, .flags = UI_NOBR, .w = 54, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_INT64, .flags = UI_NOBR, .w = 54, .ptr = &integer_64_value, .min = 1, .max = 100 },
        { .type = UI_FLOAT, .flags = UI_NOBR, .x = 10, .m = 17, .w = 100, .ptr = &float_value, .fmin = 1, .fmax = 32, .finc = 0.25f },
        { .type = UI_SLIDER, .x = 10, .w = 60, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_END }
    };
    ui_form_t inactive_inputs[] = {
        { .type = UI_TEXT, .flags = UI_DISABLED | UI_NOBR, .w = 130, .ptr = &text_value, .max = sizeof(text_value) },
        { .type = UI_SELECT, .flags = UI_DISABLED | UI_NOBR, .x = 10, .m = 17, .w = 80, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_OPTION, .flags = UI_DISABLED | UI_NOBR, .x = 10, .m = 17, .w = 90, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_INT8, .flags = UI_DISABLED | UI_NOBR, .x = 10, .m = 17, .w = 54, .ptr = &integer_8_value, .min = 1, .max = 32 },
        { .type = UI_INT16, .flags = UI_DISABLED | UI_NOBR, .w = 54, .ptr = &integer_16_value, .min = 1, .max = 32 },
        { .type = UI_INT32, .flags = UI_DISABLED | UI_NOBR, .w = 54, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_INT64, .flags = UI_DISABLED | UI_NOBR, .w = 54, .ptr = &integer_64_value, .min = 1, .max = 100 },
        { .type = UI_FLOAT, .flags = UI_DISABLED | UI_NOBR, .x = 10, .m = 17, .w = 100, .ptr = &float_value, .fmin = 1, .fmax = 32, .finc = 0.25f },
        { .type = UI_SLIDER, .flags = UI_DISABLED, .x = 10, .w = 60, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_END }
    };
    ui_form_t input_fields[] = {
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = ACTIVE },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &active_inputs },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = INACTIVE },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &inactive_inputs },
        { .type = UI_END }
    };
    ui_form_t active_buttons[] = {
        { .type = UI_CHECK, .flags = UI_NOBR, .ptr = &checkbox_option, .value = 1, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_NOBR, .x = 10, .ptr = &radio_option, .value = 0, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_NOBR, .ptr = &radio_option, .value = 1, .label = ITEM_2 },
        { .type = UI_BUTTON, .x = 10, .m = -1, .ptr = &button_option, .value = 1, .label = ITEM_1 },
        { .type = UI_END }
    };
    ui_form_t inactive_buttons[] = {
        { .type = UI_CHECK, .flags = UI_DISABLED | UI_NOBR, .ptr = &checkbox_option, .value = 1, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_DISABLED | UI_NOBR, .x = 10, .ptr = &radio_option, .value = 0, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_DISABLED | UI_NOBR, .ptr = &radio_option, .value = 1, .label = ITEM_2 },
        { .type = UI_BUTTON, .flags = UI_DISABLED, .x = 10, .m = -1, .ptr = &button_option, .value = 1, .label = ITEM_1 },
        { .type = UI_END }
    };
    ui_form_t button_fields[] = {
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = ACTIVE },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &active_buttons },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = INACTIVE },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &inactive_buttons },
        { .type = UI_END }
    };
    int16_t line_points[] = { 300, 350, 340, 350, 340, 380, 0, 0 };
    int16_t vertical_connector[] = { 350, 350, 390, 390 };
    int16_t horizontal_connector[] = { 400, 350, 440, 390 };
    int16_t curve_points[] = { 300, 410, 440, 430, 340, 450, 400, 390 };
    uint8_t cursor_pixels[] = {
        0xff, 0xff, 0xff, 0xff, 0x20, 0x20, 0x20, 0xff, 0xff, 0xff, 0xff, 0xff,
        0x20, 0x20, 0x20, 0xff, 0xff, 0xff, 0xff, 0xff, 0x20, 0x20, 0x20, 0xff,
        0xff, 0xff, 0xff, 0xff, 0x20, 0x20, 0x20, 0xff, 0xff, 0xff, 0xff, 0xff
    };
    ui_image_t software_cursor = { .w = 3, .h = 3, .p = 12, .buf = cursor_pixels };
    label_fields[16].ptr = &label_fields[17];

    ui_form_t forms[] = {
        { .type = UI_POPUP, .flags = UI_SCROLL | UI_DRAGGABLE | UI_RESIZABLE, .x = UI_ABS(455), .y = UI_ABS(315), .w = 110, .h = 90, .m = 10, .p = 10, .ptr = &popup_children },
        { .type = UI_TOGGLE, .flags = UI_NOBULLET | UI_NOBR, .x = 10, .m = 8, .label = FILE_MENU },
        { .type = UI_MENU, .m = 4, .ptr = &file_menu },
        { .type = UI_TOGGLE, .flags = UI_NOBULLET | UI_NOBR, .x = 10, .m = 8, .label = LANGUAGE_MENU },
        { .type = UI_MENU, .m = 4, .ptr = &language_menu },
        { .type = UI_TOGGLE, .flags = UI_NOBULLET | UI_FORCEBR, .x = 10, .m = 8, .label = POPUP_MENU },
        { .type = UI_MENU, .m = 4, .ptr = &popup_menu },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = LABELS },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &label_fields },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = INPUTS },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &input_fields },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = BUTTONS },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &button_fields },
        { .type = UI_LINES, .ptr = &line_points, .value = 0xff80c0ff },
        { .type = UI_VCONNECT, .ptr = &vertical_connector, .value = 0xff80ff80 },
        { .type = UI_HCONNECT, .ptr = &horizontal_connector, .value = 0xffffc080 },
        { .type = UI_CURVE, .ptr = &curve_points, .value = 0xffff80c0 },
        { .type = UI_HSCRBAR, .x = UI_ABS(300), .y = UI_ABS(300), .w = 120, .max = 300, .ptr = &horizontal_scroll },
        { .type = UI_VSCRBAR, .x = UI_ABS(430), .y = UI_ABS(200), .h = 100, .max = 300, .ptr = &vertical_scroll },
        { .type = UI_BUTTON, .align = UI_RIGHT, .w = 60, .label = ITEM_1 },
        { .type = UI_BUTTON, .align = UI_RIGHT, .w = 60, .label = ITEM_2 },
        { .type = UI_CUSTOM, .x = UI_ABS(460), .y = UI_ABS(400), .bbox = &smoke_custom_bounds, .view = &smoke_custom_view },
        { .type = UI_END }
    };

    ui_t context;
#ifdef SMOKE_IMAGE_BACKEND
    if (argc != 2) {
        fprintf(stderr, "usage: %s OUTPUT.png\n", argv[0]);
        return 2;
    }
    ui_image_backend_set_output(argv[1]);
#else
    (void)argc;
    (void)argv;
#endif
    ui_init(&context, (int)(sizeof(texts) / sizeof(texts[0])), texts, 640, 480, NULL);
    context.skin[UI_CURSOR] = software_cursor;
    ui_swcursor(&context, &software_cursor);
    while (ui_event(&context, forms)) {
        if (button_option) {
            printf("button option %d selected\n", button_option);
            button_option = 0;
            ui_refresh(&context);
        }
    }
#ifdef SMOKE_IMAGE_BACKEND
    if (!ui_image_backend_succeeded(&context)) {
        fprintf(stderr, "failed to write %s\n", argv[1]);
        ui_free(&context);
        return 1;
    }
#endif
    ui_free(&context);
    return 0;
}
