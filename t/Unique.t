#!/usr/bin/perl

use strict;
use warnings;

use Gtk2::TestHelper tests => 1;

use Gtk2::Unique;

exit tests();

sub tests {
	ok($Gtk2::Unique::VERSION, "Library loaded");
	return 0;
}
