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
my ($host, $ap_rf_dec, $ap_rf_hex, $client_ip);
if (@ARGV >= 2) {
    $ap_rf_hex = $ARGV[0];
    $client_ip = $ARGV[1];
} else {
    print "ERROR: no argument passed";
    exit 1;
}

if (! -r "$FindBin::Bin/conf/apvt.conf") {
     print "ERROR: apvt.conf is not readable\n";
     exit 1;
}
require "$FindBin::Bin/conf/apvt.conf";
require "$FindBin::Bin/lib/common_snmp.pl";
# global variables
use vars qw ($gatingWLC $gatingWLC_s $gatingCommunity %csv_file $perl $snmpget $snmpset);

if($client_ip =~ /[0-9]{2}\.[0-9]{2}\.129\.[0-9]{2}/) {
    $host = $gatingWLC;
} elsif ($client_ip =~ /[0-9]{2}\.[0-9]{2}\.130\.[0-9]{2}/) {
    $host = $gatingWLC_s;
} else {
    $host = $gatingWLC;
}

$ap_rf_dec = mac_hex_decimal($ap_rf_hex);


my $result = `$snmpget -v2c -c $gatingCommunity $host $bsnAPReset.$ap_rf_dec`;
$result = `$snmpset -v2c -c $gatingCommunity $host $bsnAPReset.$ap_rf_dec i 1`;
my $string = quotemeta "$ap_rf_dec = INTEGER: 1";
if($result =~ /$string/){
    print "AP reboot Seccussful.";
}