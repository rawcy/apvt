#!/usr/bin/perl 
use Net::Ping;
use FindBin;
use Net::IP;

use File::Slurp;
use Data::Dumper qw(Dumper);
require "$FindBin::Bin/lib/common_snmp.pl";

my $hex = "64:d9:89:47:5f:e0";
my $dec = mac_hex_decimal($hex);
my $test;
if (defined !$test){
	print $dec ."\n";
}
my $ip= Net::IP->new("100.100.100.100")->hexip();
print $ip;




sub set_callback
{
	my ($session) = @_;

	my $result = $session->var_bind_list();

	if (defined $result) {
		printf "The sysContact for host '%s' was set to '%s'.\n",
		$session->hostname(), $result->{$OID_sysContact};
	} else {
		printf "ERROR: Set request failed for host '%s': %s.\n",
		$session->hostname(), $session->error();
	}

	return;
}

