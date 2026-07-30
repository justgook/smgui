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
    int scripted_event_index;
} ui_backend_t;

static const char *ui_image_backend_output_path;
static ui_event_t ui_image_backend_scripted_events[6];
static int ui_image_backend_scripted_event_count;
static int ui_image_backend_scripted_event_gap;
static int ui_image_backend_scripted_event_wait;

static void ui_image_backend_set_event_gap(int gap)
{
    ui_image_backend_scripted_event_gap = gap;
    ui_image_backend_scripted_event_wait = 0;
}

static void ui_image_backend_set_output(const char *output_path)
{
    ui_image_backend_output_path = output_path;
}

static void ui_image_backend_set_mouse_event(int x, int y, int buttons)
{
    ui_event_t *event = &ui_image_backend_scripted_events[0];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    event->type = UI_EVT_MOUSE;
    event->btn = buttons;
    event->x = x;
    event->y = y;
    ui_image_backend_scripted_event_count = 1;
}

static void ui_image_backend_set_two_mouse_events(
    int first_x, int first_y, int first_buttons,
    int second_x, int second_y, int second_buttons)
{
    ui_event_t *first = &ui_image_backend_scripted_events[0];
    ui_event_t *second = &ui_image_backend_scripted_events[1];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    first->type = UI_EVT_MOUSE;
    first->btn = first_buttons;
    first->x = first_x;
    first->y = first_y;
    second->type = UI_EVT_MOUSE;
    second->btn = second_buttons;
    second->x = second_x;
    second->y = second_y;
    ui_image_backend_scripted_event_count = 2;
}

static void ui_image_backend_set_menu_item_events(
    int first_x, int first_y, int first_buttons,
    int second_x, int second_y, int second_buttons,
    int third_x, int third_y, int third_buttons)
{
    ui_event_t *first = &ui_image_backend_scripted_events[0];
    ui_event_t *second = &ui_image_backend_scripted_events[1];
    ui_event_t *idle = &ui_image_backend_scripted_events[2];
    ui_event_t *third = &ui_image_backend_scripted_events[3];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    first->type = second->type = third->type = UI_EVT_MOUSE;
    first->btn = first_buttons;
    first->x = first_x;
    first->y = first_y;
    second->btn = second_buttons;
    second->x = second_x;
    second->y = second_y;
    idle->type = UI_EVT_KEY;
    idle->key[0] = 'x';
    idle->x = third_x;
    idle->y = third_y;
    third->btn = third_buttons;
    third->x = third_x;
    third->y = third_y;
    ui_image_backend_scripted_event_count = 4;
}

static void ui_image_backend_set_mouse_then_key_events(int x, int y, int buttons, char key_value)
{
    ui_event_t *warmup = &ui_image_backend_scripted_events[0];
    ui_event_t *mouse = &ui_image_backend_scripted_events[1];
    ui_event_t *idle = &ui_image_backend_scripted_events[2];
    ui_event_t *key = &ui_image_backend_scripted_events[3];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    warmup->type = UI_EVT_MOUSE;
    warmup->x = x;
    warmup->y = y;
    mouse->type = UI_EVT_MOUSE;
    mouse->btn = buttons;
    mouse->x = x;
    mouse->y = y;
    idle->type = UI_EVT_KEY;
    idle->key[0] = 'x';
    key->type = UI_EVT_KEY;
    key->key[0] = key_value;
    ui_image_backend_scripted_event_count = 4;
}

static void ui_image_backend_set_select_pressed_events(int x, int y)
{
    ui_event_t *hover = &ui_image_backend_scripted_events[0];
    ui_event_t *press = &ui_image_backend_scripted_events[1];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    hover->type = UI_EVT_MOUSE;
    hover->x = x;
    hover->y = y;
    press->type = UI_EVT_MOUSE;
    press->btn = UI_BTN_L;
    press->x = x;
    press->y = y;
    ui_image_backend_scripted_event_count = 2;
}

static void ui_image_backend_set_select_choice_events(int x, int y)
{
    ui_event_t *hover = &ui_image_backend_scripted_events[0];
    ui_event_t *press = &ui_image_backend_scripted_events[1];
    ui_event_t *release = &ui_image_backend_scripted_events[2];
    ui_event_t *commit = &ui_image_backend_scripted_events[3];
    ui_event_t *commit_again = &ui_image_backend_scripted_events[4];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    hover->type = UI_EVT_MOUSE;
    hover->x = x;
    hover->y = y;
    press->type = UI_EVT_MOUSE;
    press->btn = UI_BTN_L;
    press->x = x;
    press->y = y;
    release->type = UI_EVT_MOUSE;
    release->btn = UI_BTN_RELEASE;
    release->x = x;
    release->y = y;
    commit->type = UI_EVT_KEY;
    commit->key[0] = '\n';
    commit_again->type = UI_EVT_KEY;
    commit_again->key[0] = '\n';
    ui_image_backend_scripted_event_count = 5;
}

static void ui_image_backend_set_select_open_events(int x, int y)
{
    ui_event_t *hover = &ui_image_backend_scripted_events[0];
    ui_event_t *press = &ui_image_backend_scripted_events[1];
    ui_event_t *release = &ui_image_backend_scripted_events[2];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    hover->type = UI_EVT_MOUSE;
    hover->x = x;
    hover->y = y;
    press->type = UI_EVT_MOUSE;
    press->btn = UI_BTN_L;
    press->x = x;
    press->y = y;
    release->type = UI_EVT_MOUSE;
    release->btn = UI_BTN_RELEASE;
    release->x = x;
    release->y = y;
    ui_image_backend_scripted_event_count = 3;
}

static void ui_image_backend_set_text_edit_events(int x, int y, const char *text)
{
    ui_event_t *mouse = &ui_image_backend_scripted_events[0];
    ui_event_t *key = &ui_image_backend_scripted_events[1];
    ui_event_t *commit = &ui_image_backend_scripted_events[2];
    memset(ui_image_backend_scripted_events, 0, sizeof(ui_image_backend_scripted_events));
    mouse->type = UI_EVT_MOUSE;
    mouse->btn = UI_BTN_L;
    mouse->x = x;
    mouse->y = y;
    key->type = UI_EVT_KEY;
    snprintf(key->key, sizeof(key->key), "%s", text);
    commit->type = UI_EVT_KEY;
    commit->key[0] = '\n';
    ui_image_backend_scripted_event_count = 3;
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
    ui_event_t *event;
    if (!backend || backend->finished) return 1;
    if (backend->scripted_event_index < ui_image_backend_scripted_event_count) {
        if (ui_image_backend_scripted_event_wait > 0) {
            ui_image_backend_scripted_event_wait--;
            return 0;
        }
        event = _ui_evtslot(backend->ctx);
        if (!event) return 1;
        *event = ui_image_backend_scripted_events[backend->scripted_event_index++];
        ui_image_backend_scripted_event_wait = ui_image_backend_scripted_event_gap;
        if (event->type == UI_EVT_MOUSE || event->x || event->y) {
            backend->ctx->mousex = event->x;
            backend->ctx->mousey = event->y;
        }
    }
    return 0;
}

int ui_backend_redraw(ui_backend_t *backend)
{
    ui_image_t *screen;
    if (!backend || !backend->ctx || !backend->output_path) return UI_ERR_BADINP;
    if (backend->scripted_event_index < ui_image_backend_scripted_event_count ||
        backend->ctx->tail != backend->ctx->head) {
        return UI_OK;
    }
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
