#include "unique-perl.h"


MODULE = Gtk2::UniqueApp  PACKAGE = Gtk2::UniqueApp  PREFIX = unique_app_


UniqueApp_noinc*
unique_app_new (class, const gchar *name, const gchar_ornull *startup_id, ...)
	ALIAS:
		new_with_commands = 1
	
	PREINIT:
		UniqueApp *app = NULL;
		
	CODE:
		PERL_UNUSED_VAR(ix);

		if (items == 3) {
			app = unique_app_new(name, startup_id);
		}
		else if (items > 3 && (items % 2 == 1)) {
			/* Calling unique_app_new_with_command(), First create a new app with
			   unique_app_new() and the populate the commands one by one with
			   unique_app_add_command().
			 */
			int i;
			app = unique_app_new(name, startup_id);

			for (i = 3; i < items; i += 2) {
				SV *command_name_sv = ST(i);
				SV *command_id_sv = ST(i + 1);
				gchar *command_name = NULL;
				gint command_id;

				if (! looks_like_number(command_id_sv)) {
					g_object_unref(G_OBJECT(app));
					croak(
						"Invalid command_id at position %d, expected a number but got '%s'",
						i,
						SvGChar(command_id_sv)
					);
				}
				command_name = SvGChar(command_name_sv);
				command_id = SvIV(command_id_sv);
				unique_app_add_command(app, command_name, command_id);
			}
		}
		else {
			croak(
				"Usage: Gtk2::UniqueApp->new(name, startup_id)"
				"or Gtk2::UniqueApp->new_with_commands(name, startup_id, @commands)"
			);
		}

		RETVAL = app;

	OUTPUT:
		RETVAL


void
unique_app_add_command (UniqueApp *app, const gchar *command_name, gint command_id)


void
unique_app_watch_window (UniqueApp *app, GtkWindow *window)


gboolean
unique_app_is_running (UniqueApp *app)


#
# $app->send_message($ID) -> unique_app_send_message(app, command_id, NULL);
# $app->send_message($ID, text => $text) -> set_text() unique_app_send_message(app, command_id, message);
# $app->send_message($ID, data => $data) -> set() unique_app_send_message(app, command_id, message);
# $app->send_message($ID, uris => @uri) -> set_uris() unique_app_send_message(app, command_id, message);
#
# $app->send_message_by_name('command') -> unique_app_send_message(app, command_id, NULL);
# $app->send_message_by_name('command', text => $text) -> set_text() unique_app_send_message(app, command_id, message);
# $app->send_message_by_name('command', data => $data) -> set() unique_app_send_message(app, command_id, message);
# $app->send_message_by_name('command', uris => @uri) -> set_uris() unique_app_send_message(app, command_id, message);
#
#
UniqueResponse
unique_app_send_message (UniqueApp *app, SV *command, ...)
	ALIAS:
		send_message_by_name = 1

	PREINIT:
		UniqueMessageData *message = NULL;
		SV **s = NULL;
		gint command_id = 0;

	CODE:

		switch (ix) {
			case 0:
				{
					command_id = (gint) SvIV(command);
				}
			break;

			case 1:
				{
					gchar *command_name = SvGChar(command);
					command_id = unique_command_from_string(app, command_name);
					if (command_id == 0) {
							croak("Command '%s' isn't registered with the application", command_name);
					}
				}
			break;

			default:
				croak("Method called with the wrong name");
		}

		if (items == 4) {
			SV *sv_data;
			gchar *type;

			message = unique_message_data_new();
			type = SvGChar(ST(2));
			sv_data = ST(3);
			
			if (g_strcmp0(type, "data") == 0) {
				SV *sv;
				STRLEN length;
				char *data;
				
				length = sv_len(sv_data);
				data = SvPV(sv_data, length);
				unique_message_data_set(message, data, length);
			}
			else if (g_strcmp0(type, "text") == 0) {
				STRLEN length;
				char *text;
				
				length = sv_len(sv_data);
				text = SvGChar(sv_data);
				unique_message_data_set_text(message, text, length);
			}
			else if (g_strcmp0(type, "filename") == 0) {
				SV *sv;
				char *filename;
				
				filename = SvGChar(sv_data);
				unique_message_data_set_filename(message, filename);
			}
			else if (g_strcmp0(type, "uris") == 0) {
				gchar **uris = NULL;
				gsize length;
				AV *av = NULL;
				int i;

				if (SvTYPE(SvRV(sv_data)) != SVt_PVAV) {
					unique_message_data_free(message);
					croak("Value for the type 'uris' must be an array ref");
				}

				/* Convert the Perl array into a C array of strings */
				av = (AV*) SvRV(sv_data);
				length = av_len(av) + 2; /* last index + extra NULL padding */
				
				uris = g_new0(gchar *, length);
				for (i = 0; i < length - 1; ++i) {
					SV **uri_sv = av_fetch(av, i, FALSE);
					uris[i] = SvGChar(*uri_sv);
				}
				uris[length - 1] = NULL;

				unique_message_data_set_uris(message, uris);
				g_free(uris);
			}
			else {
				unique_message_data_free(message);
				croak("Parameter 'type' must be: 'data', 'text', 'filename' or 'uris'; got %s", type);
			}
		}
		else if (items == 2) {
			message = NULL;
		}
		else {
			croak(
				"Usage: $app->send_message($id, $type => $data)"
				" or $app->send_message($id, uris => [])"
				" or $app->send_message($id)"
			);
		}
		
		RETVAL = unique_app_send_message(app, command_id, message);
		
		if (message) {
			unique_message_data_free(message);
		}

	OUTPUT:
		RETVAL
