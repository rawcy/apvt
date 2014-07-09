#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Log::Log4perl;
use OIDS;

my ($username, $ap_rf_hex, $flashingAp);
my $script_name = $0;

require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/appt.conf";
use vars qw ($gatingWLC $gatingCommunity $perl $searchAp $snmpget $snmpset $pgrep $log_conf);

Log::Log4perl::init("$FindBin::Bin/conf/$log_conf");
my $access_logger = Log::Log4perl->get_logger('appt_access');
my $error_logger = Log::Log4perl->get_logger('appt_error');

if (@ARGV >= 2) {
    $username =$ARGV[0];
    $ap_rf_hex = $ARGV[1];
} else {
    $error_logger->error("user: $username missing arguments. $0 looks for 2 arguments and got @ARGV");
    exit 1;
}

my $ap_rf_dec = mac_hex_decimal($ap_rf_hex);
my $running = `$pgrep -fl "$perl.*$script_name.*$ap_rf_hex\$"`;
print $running . "-----\n";
if ($running !~ /$ap_rf_hex.*\n.*$ap_rf_hex/) {
    $access_logger->info("user $username: flashed AP $ap_rf_hex LED.");
    foreach my $i (1..30) {
        `$snmpset -v2c -c $gatingCommunity $gatingWLC $cLApLEDState.$ap_rf_dec i 2`;
        sleep(1);
        `$snmpset -v2c -c $gatingCommunity $gatingWLC $cLApLEDState.$ap_rf_dec i 1`;
        sleep(1);
    } 
} else {
    $access_logger->warn("user $username: AP LED $ap_rf_hex has been flashing.");
} 
exit 0;
