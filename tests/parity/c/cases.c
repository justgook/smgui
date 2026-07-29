/* Small deterministic reference-C framebuffer parity fixtures. */

#include <stdio.h>
#include <string.h>

#include "ui_image_backend.h"

int main(int argc, char **argv)
{
    char *texts[] = { "Parity fixture" };
    ui_form_t empty[] = {
        { .type = UI_END }
    };
    ui_form_t *forms;
    ui_t context;
    int result;

    if (argc != 3) {
        fprintf(stderr, "usage: %s CASE OUTPUT.png\n", argv[0]);
        return 2;
    }
    if (!strcmp(argv[1], "empty")) {
        forms = empty;
    } else {
        fprintf(stderr, "unknown parity case: %s\n", argv[1]);
        return 2;
    }

    ui_image_backend_set_output(argv[2]);
    result = ui_init(&context, 1, texts, 64, 48, NULL);
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
