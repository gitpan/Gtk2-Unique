#include "unique-perl.h"


MODULE = Gtk2::UniqueBackend  PACKAGE = Gtk2::UniqueBackend  PREFIX = unique_backend_


UniqueBackend*
unique_backend_create (class)
	C_ARGS: /* No args */


const gchar*
unique_backend_get_name (UniqueBackend *backend)


void
unique_backend_set_name (UniqueBackend *backend, const gchar *name)


const gchar*
unique_backend_get_startup_id (UniqueBackend *backend)


void
unique_backend_set_startup_id (UniqueBackend *backend, const gchar *startup_id)


GdkScreen*
unique_backend_get_screen (UniqueBackend *backend)


void
unique_backend_set_screen (UniqueBackend *backend, GdkScreen *screen)


guint
unique_backend_get_workspace (UniqueBackend *backend)


gboolean
unique_backend_request_name  (UniqueBackend *backend)


UniqueResponse
unique_backend_send_message (UniqueBackend *backend, gint command_id, UniqueMessageData_ornull *message_data, guint time_)

