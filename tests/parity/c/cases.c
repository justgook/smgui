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
    enum { WINDOW_TITLE, LABEL_TEXT, BUTTON_TEXT, BUTTON_SHORT_TEXT, CHECKBOX_TEXT };
    char *texts[] = { "Parity fixture", "Label", "Button", "Btn", "Check" };
    int checked = 0;
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
    } else {
        fprintf(stderr, "unknown parity case: %s\n", argv[1]);
        return 2;
    }

    ui_image_backend_set_output(argv[2]);
    if (!strcmp(argv[1], "button-hover")) {
        ui_image_backend_set_mouse_event(10, 10, 0);
    } else if (!strcmp(argv[1], "button-pressed")) {
        ui_image_backend_set_mouse_event(10, 10, UI_BTN_L);
    }
    result = ui_init(&context, (int)(sizeof(texts) / sizeof(texts[0])), texts, width, height, NULL);
    if (result != UI_OK) {
        fprintf(stderr, "ui_init failed: %d\n", result);
        return 1;
    }
    if (!strcmp(argv[1], "button-normal") || !strcmp(argv[1], "button-explicit-size") ||
        !strcmp(argv[1], "checkbox-normal")) {
        context.mousex = -1;
        context.mousey = -1;
    }
    while (ui_event(&context, forms)) { }
    if (!ui_image_backend_succeeded(&context)) {
        fprintf(stderr, "failed to write %s\n", argv[2]);
        ui_free(&context);
        return 1;
    }
    ui_free(&context);
    return 0;
}
