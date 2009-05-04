#include "unique-perl.h"


MODULE = Gtk2::UniqueMessageData  PACKAGE = Gtk2::UniqueMessageData  PREFIX = unique_message_data_

SV*
unique_message_data_get (UniqueMessageData *message_data)
	PREINIT:
		const guchar *string = NULL;
		gint length = 0;
		
	CODE:
		string = unique_message_data_get(message_data, &length);
		if (string == NULL) {XSRETURN_UNDEF;}
		
		RETVAL = newSVpvn(string, length);
	
	OUTPUT:
		RETVAL

gchar*
unique_message_data_get_text (UniqueMessageData *message_data)


gchar*
unique_message_data_get_filename (UniqueMessageData *message_data)


void
unique_message_data_get_uris (UniqueMessageData *message_data)
	PREINIT:
		gchar **uris = NULL;
		gchar *uri = NULL;
		gint i = 0;
		
	PPCODE:
		uris = unique_message_data_get_uris(message_data);
		if (uris == NULL) {XSRETURN_EMPTY;}
		
		for (i = 0; TRUE; ++i) {
			uri = uris[i];
			if (uri == NULL) {break;}
			
			XPUSHs(sv_2mortal(newSVGChar(uri)));
		}
		g_strfreev(uris);


GdkScreen*
unique_message_data_get_screen (UniqueMessageData *message_data)


const gchar*
unique_message_data_get_startup_id (UniqueMessageData *message_data)


guint
unique_message_data_get_workspace (UniqueMessageData *message_data)
