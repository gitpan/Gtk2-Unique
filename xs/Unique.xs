#include "unique-perl.h"


MODULE = Gtk2::Unique  PACKAGE = Gtk2::Unique  PREFIX = unique_

PROTOTYPES: DISABLE


BOOT:
#include "register.xsh"
#include "boot.xsh"
