#ifndef SMGUI_TEST_UI_IMAGE_BACKEND_H
#define SMGUI_TEST_UI_IMAGE_BACKEND_H

/*
 * Test-only reference-C backend that writes the first rendered software
 * framebuffer to PNG and then closes the event loop.
 */

#define UI_BACKEND 1
#include <ui.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image_write.h>

typedef struct ui_backend_s {
    ui_t *ctx;
    const char *output_path;
    int finished;
    int succeeded;
} ui_backend_t;

static const char *ui_image_backend_output_path;

static void ui_image_backend_set_output(const char *output_path)
{
    ui_image_backend_output_path = output_path;
}

static int ui_image_backend_succeeded(ui_t *ctx)
{
    ui_backend_t *backend = ctx ? (ui_backend_t *)ctx->bck : NULL;
    return backend && backend->finished && backend->succeeded;
}

int ui_backend_fullscreen(ui_backend_t *backend)
{
    return backend ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_focus(ui_backend_t *backend)
{
    return backend ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_settitle(ui_backend_t *backend, char *title)
{
    return backend && title ? UI_OK : UI_ERR_BADINP;
}

char *ui_backend_getclipboard(ui_backend_t *backend)
{
    return backend ? "" : NULL;
}

int ui_backend_setclipboard(ui_backend_t *backend, char *text)
{
    return backend && text ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_hidecursor(ui_backend_t *backend)
{
    return backend ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_showcursor(ui_backend_t *backend)
{
    return backend ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_hideosk(ui_backend_t *backend)
{
    return backend ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_showosk(ui_backend_t *backend)
{
    return backend ? UI_OK : UI_ERR_BADINP;
}

int ui_backend_init(ui_t *ctx, char *title, int width, int height, ui_image_t *icon)
{
    ui_backend_t *backend;
    (void)title;
    (void)icon;
    if (!ctx || !ui_image_backend_output_path || width < 1 || height < 1) return UI_ERR_BADINP;
    backend = (ui_backend_t *)calloc(1, sizeof(ui_backend_t));
    if (!backend) return UI_ERR_NOMEM;
    backend->ctx = ctx;
    backend->output_path = ui_image_backend_output_path;
    ctx->bck = backend;
    return UI_OK;
}

void *ui_backend_getwindow(ui_backend_t *backend)
{
    (void)backend;
    return NULL;
}

int ui_backend_event(ui_backend_t *backend)
{
    return !backend || backend->finished;
}

int ui_backend_redraw(ui_backend_t *backend)
{
    ui_image_t *screen;
    if (!backend || !backend->ctx || !backend->output_path) return UI_ERR_BADINP;
    screen = &backend->ctx->screen;
    backend->succeeded = stbi_write_png(
        backend->output_path,
        screen->w,
        screen->h,
        4,
        screen->buf,
        screen->p
    );
    backend->finished = 1;
    return backend->succeeded ? UI_OK : UI_ERR_BACKEND;
}

int ui_backend_free(ui_backend_t *backend)
{
    if (!backend) return UI_ERR_BADINP;
    free(backend);
    return UI_OK;
}

/* Re-enter ui.h with types already declared and our backend functions visible. */
#undef UI_H
#define UI_IMPLEMENTATION
#include <ui.h>

#endif
