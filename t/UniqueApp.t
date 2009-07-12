#!/usr/bin/perl

use strict;
use warnings;

use Gtk2::TestHelper tests => 16;

use Gtk2::Unique;

my $COMMAND_FOO = 1;
my $COMMAND_BAR = 2;
my $APP_NAME = 'org.example.UnitTets';

exit tests();


sub tests {
	tests_new();
	tests_new_with_commands();
	return 0;
}


sub tests_new {
	my $app = Gtk2::UniqueApp->new($APP_NAME, undef);
	isa_ok($app, 'Gtk2::UniqueApp');
	
	$app->add_command(foo => $COMMAND_FOO);
	$app->add_command(bar => $COMMAND_BAR);
	
	generic_test($app);
}


sub tests_new_with_commands {

	my @commands = (
		foo => $COMMAND_FOO,
		bar => $COMMAND_BAR,
	);

	my $app = Gtk2::UniqueApp->new_with_commands($APP_NAME, undef, @commands);
	isa_ok($app, 'Gtk2::UniqueApp');
	
	generic_test($app);

	my $pass;

	# Check that the constructor enforces ints for the command ID
	$app = undef;
	$pass = 1;
	eval {
		$app = Gtk2::UniqueApp->new_with_commands($APP_NAME, undef, foo => 'not-an-int');
		$pass = 0;
	};
	if (my $error = $@) {
		$pass = 1;
	}
	ok($pass, "new_with_command() checks for IDs as int");


	# Check that the constructor enforces the argument count
	$app = undef;
	$pass = 1;
	eval {
		$app = Gtk2::UniqueApp->new_with_commands($APP_NAME, undef, foo => 1, 'bar');
		$pass = 0;
	};
	if (my $error = $@) {
		$pass = 1;
	}
	ok($pass, "new_with_command() checks for argument count");

}


sub generic_test {
	my ($app) = @_;
	
	if (! $app->is_running()) {
		SKIP: {
			skip "No app is running; execute perl -Mblib t/unit-tests.pl", 6;
		}
		return;
	}
	my $response;

	$response = $app->send_message($COMMAND_FOO, text => "hello");
	is($response, 'ok', "send_message(text)");

	$response = $app->send_message_by_name(foo => text => "hello");
	is($response, 'ok', "send_message_by_name(text)");


	$response = $app->send_message($COMMAND_BAR, filename => __FILE__);
	is($response, 'invalid', "send_message(filename)");

	$response = $app->send_message_by_name(bar => filename => __FILE__);
	is($response, 'invalid', "send_message_by_name(filename)");


	$response = $app->send_message($COMMAND_FOO, uris => [
		'http://live.gnome.org/LibUnique',
		'http://gtk2-perl.sourceforge.net/',
	]);
	is($response, 'ok', "send_message(uris)");

	$response = $app->send_message_by_name(foo =>, uris => [
		'http://live.gnome.org/LibUnique',
		'http://gtk2-perl.sourceforge.net/',
	]);
	is($response, 'ok', "send_message_by_name(uris)");

	
	my $window = Gtk2::Window->new();
	$app->watch_window($window);
}

