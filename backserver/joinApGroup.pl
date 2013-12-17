#!/usr/bin/perl -w

##############################################
##  Author:       Yin Chen                  ##
##  Contact:      yinche@cisco.com          ##
##  Data:         Dec 16 2013               ##
##  Project:      apvt                      ##
##############################################

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use FindBin;
use OIDS;

require "$FindBin::Bin/lib/common_snmp.pl";
if (! -r "$FindBin::Bin/conf/apvt.conf") {
     print "ERROR: apvt.conf is not readable\n";
     exit 1;
}
require "$FindBin::Bin/conf/apvt.conf";
# global variables
my $perl = '/usr/bin/perl';
use vars qw ($gatingWLC $gatingWLC_s $gatingCommunity %csv_file);
my ($host, $ap_grp, $ap_rf_dec, $ap_rf_hex, $client_ip, $preset);

if (@ARGV >= 3) {
	$ap_rf_hex = $ARGV[0];
	$ap_grp = $ARGV[1];
    $client_ip = $ARGV[2]
} else {
	print "ERROR: no argument passed";
	exit 1;
}
$ap_rf_dec = mac_hex_decimal($ap_rf_hex);

if($client_ip =~ /[0-9]{2}\.[0-9]{2}\.129\.[0-9]{2}/) {
    $host = $gatingWLC;
}elsif ($client_ip =~ /[0-9]{2}\.[0-9]{2}\.130\.[0-9]{2}/) {
    $host = $gatingWLC_s;
}

if (!$host) {
     $host = $gatingWLC_s;
}
# print "snmpget -v2c -c $gatingCommunity $host $bsnAPGroupVlanName.$ap_rf_dec $bsnAPReset.$ap_rf_dec\n";
my $result = `snmpget -v2c -c $gatingCommunity $host $bsnAPGroupVlanName.$ap_rf_dec`;
# print "snmpset -v2c -c $gatingCommunity $host $bsnAPGroupVlanName.$ap_rf_dec s $ap_grp_name $bsnAPReset.$ap_rf_dec i 1";
$result = `snmpset -v2c -c $gatingCommunity $host $bsnAPGroupVlanName.$ap_rf_dec s $ap_grp`;
if($result !~ /error/){
    $result = `$perl rebootAP.pl $ap_rf_hex $client_ip`;
}
print $result;