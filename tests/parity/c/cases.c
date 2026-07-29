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
    } else {
        fprintf(stderr, "unknown parity case: %s\n", argv[1]);
        return 2;
    }

    ui_image_backend_set_output(argv[2]);
    if (!strcmp(argv[1], "button-hover") || !strcmp(argv[1], "checkbox-hover") ||
        !strcmp(argv[1], "radio-hover")) {
        ui_image_backend_set_mouse_event(10, 10, 0);
    } else if (!strcmp(argv[1], "button-pressed") || !strcmp(argv[1], "checkbox-pressed") ||
        !strcmp(argv[1], "radio-pressed")) {
        ui_image_backend_set_mouse_event(10, 10, UI_BTN_L);
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
         !strcmp(argv[1], "slider-maximum"))) {
        context.mousex = -1;
        context.mousey = -1;
    }
    while (ui_event(&context, forms)) { }
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
    if (!ui_image_backend_succeeded(&context)) {
        fprintf(stderr, "failed to write %s\n", argv[2]);
        ui_free(&context);
        return 1;
    }
    ui_free(&context);
    return 0;
}
