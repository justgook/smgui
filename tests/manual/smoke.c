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
        THREE
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
    };
    char *options[] = { texts[ONE], texts[TWO], texts[THREE] };

    int menu_option = 0;
    int button_option = 0;
    int checkbox_option = 0;
    int radio_option = 0;
    int integer_value = 26;
    int option_value = 0;
    int64_t progress_value = 42;
    float float_value = 3.141f;
    char text_value[64] = { 0 };

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
        { .type = UI_DEC32, .flags = UI_NOBR, .w = 28, .ptr = &integer_value },
        { .type = UI_HEX32, .flags = UI_NOBR, .w = 36, .ptr = &integer_value },
        { .type = UI_PBAR, .flags = UI_NOBR, .w = 100, .ptr = &progress_value, .max = 100 },
        { .type = UI_DEC_FLOAT, .w = 80, .ptr = &float_value },
        { .type = UI_END }
    };
    ui_form_t active_inputs[] = {
        { .type = UI_TEXT, .flags = UI_NOBR, .w = 130, .ptr = &text_value, .max = sizeof(text_value) },
        { .type = UI_SELECT, .flags = UI_NOBR, .w = 80, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_OPTION, .flags = UI_NOBR, .w = 90, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_INT32, .flags = UI_NOBR, .w = 72, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_FLOAT, .flags = UI_NOBR, .w = 100, .ptr = &float_value, .fmin = 1, .fmax = 32, .finc = 0.25f },
        { .type = UI_SLIDER, .w = 60, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_END }
    };
    ui_form_t inactive_inputs[] = {
        { .type = UI_TEXT, .flags = UI_DISABLED | UI_NOBR, .w = 130, .ptr = &text_value, .max = sizeof(text_value) },
        { .type = UI_SELECT, .flags = UI_DISABLED | UI_NOBR, .w = 80, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_OPTION, .flags = UI_DISABLED | UI_NOBR, .w = 90, .ptr = &option_value, .optc = 3, .optv = options },
        { .type = UI_INT32, .flags = UI_DISABLED | UI_NOBR, .w = 72, .ptr = &integer_value, .min = 1, .max = 32 },
        { .type = UI_FLOAT, .flags = UI_DISABLED | UI_NOBR, .w = 100, .ptr = &float_value, .fmin = 1, .fmax = 32, .finc = 0.25f },
        { .type = UI_SLIDER, .flags = UI_DISABLED, .w = 60, .ptr = &integer_value, .min = 1, .max = 32 },
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
        { .type = UI_RADIO, .flags = UI_NOBR, .ptr = &radio_option, .value = 0, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_NOBR, .ptr = &radio_option, .value = 1, .label = ITEM_2 },
        { .type = UI_BUTTON, .ptr = &button_option, .value = 1, .label = ITEM_1 },
        { .type = UI_END }
    };
    ui_form_t inactive_buttons[] = {
        { .type = UI_CHECK, .flags = UI_DISABLED | UI_NOBR, .ptr = &checkbox_option, .value = 1, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_DISABLED | UI_NOBR, .ptr = &radio_option, .value = 0, .label = ITEM_1 },
        { .type = UI_RADIO, .flags = UI_DISABLED | UI_NOBR, .ptr = &radio_option, .value = 1, .label = ITEM_2 },
        { .type = UI_BUTTON, .flags = UI_DISABLED, .ptr = &button_option, .value = 1, .label = ITEM_1 },
        { .type = UI_END }
    };
    ui_form_t button_fields[] = {
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = ACTIVE },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &active_buttons },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = INACTIVE },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &inactive_buttons },
        { .type = UI_END }
    };
    ui_form_t forms[] = {
        { .type = UI_POPUP, .flags = UI_DRAGGABLE | UI_RESIZABLE, .x = UI_ABS(455), .y = UI_ABS(315), .w = 110, .h = 90, .m = 8, .ptr = &popup_children },
        { .type = UI_TOGGLE, .flags = UI_NOBULLET | UI_NOBR, .label = FILE_MENU },
        { .type = UI_MENU, .m = 4, .ptr = &file_menu },
        { .type = UI_TOGGLE, .flags = UI_NOBULLET | UI_NOBR, .label = LANGUAGE_MENU },
        { .type = UI_MENU, .m = 4, .ptr = &language_menu },
        { .type = UI_TOGGLE, .flags = UI_NOBULLET | UI_FORCEBR, .label = POPUP_MENU },
        { .type = UI_MENU, .m = 4, .ptr = &popup_menu },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = LABELS },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &label_fields },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = INPUTS },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &input_fields },
        { .type = UI_TOGGLE, .flags = UI_FORCEBR, .label = BUTTONS },
        { .type = UI_DIV, .flags = UI_FORCEBR, .w = UI_PERCENT(100), .m = 4, .ptr = &button_fields },
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
