/* Small deterministic reference-C framebuffer parity fixtures. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ui_image_backend.h"

static int parse_dimension(const char *text, int minimum, int maximum, int *value)
{
    char *end;
    long parsed = strtol(text, &end, 10);
    if (!text[0] || *end || parsed < minimum || parsed > maximum) return 0;
    *value = (int)parsed;
    return 1;
}

int main(int argc, char **argv)
{
    enum { WINDOW_TITLE, LABEL_TEXT, BUTTON_TEXT, BUTTON_SHORT_TEXT, CHECKBOX_TEXT, RADIO_TEXT };
    char *texts[] = { "Parity fixture", "Label", "Button", "Btn", "Check", "Radio" };
    int checked = 0;
    int radio_value = 0;
    int selected_radio_value = 1;
    int pressed_radio_value = 0;
    int slider_value = 0;
    int slider_midpoint_value = 50;
    int slider_maximum_value = 100;
    int slider_interaction_value = 0;
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
    int checked_value = 1;
    int pressed_value = 0;
    ui_form_t empty[] = {
        { .type = UI_END }
    };
    ui_form_t label_normal[] = {
        { .type = UI_LABEL, .label = LABEL_TEXT },
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
    }
    result = ui_init(&context, (int)(sizeof(texts) / sizeof(texts[0])), texts, width, height, NULL);
    if (result != UI_OK) {
        fprintf(stderr, "ui_init failed: %d\n", result);
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
    if (!ui_image_backend_succeeded(&context)) {
        fprintf(stderr, "failed to write %s\n", argv[2]);
        ui_free(&context);
        return 1;
    }
    ui_free(&context);
    return 0;
}
