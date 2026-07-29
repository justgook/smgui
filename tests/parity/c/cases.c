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
    char *texts[] = { "Parity fixture" };
    ui_form_t empty[] = {
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
    } else {
        fprintf(stderr, "unknown parity case: %s\n", argv[1]);
        return 2;
    }

    ui_image_backend_set_output(argv[2]);
    result = ui_init(&context, 1, texts, width, height, NULL);
    if (result != UI_OK) {
        fprintf(stderr, "ui_init failed: %d\n", result);
        return 1;
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
