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
my ($host, $ap_grp, $ap_rf_dec, $ap_rf_hex, $client_ip, $preset);
if (@ARGV >= 3) {
    $ap_rf_hex = $ARGV[0];
    $ap_grp = $ARGV[1];
    $client_ip = $ARGV[2];
    $preset = $ARGV[3];
} else {
    print "ERROR: no argument passed";
    exit 1;
}


if (! -r "$FindBin::Bin/conf/appt.conf") {
     print "ERROR: apvt.conf is not readable\n";
     exit 1;
}

require "$FindBin::Bin/conf/apvt.conf";
require "$FindBin::Bin/lib/common_snmp.pl";
# global variables

use vars qw ($gatingWLC $gatingWLC_s $gatingCommunity %csv_file $perl $snmpget $snmpset $rebootAp);

if($client_ip =~ /[0-9]{2}\.[0-9]{2}\.129\.[0-9]{2}/) {
    $host = $gatingWLC;
} elsif ($client_ip =~ /[0-9]{2}\.[0-9]{2}\.130\.[0-9]{2}/) {
    $host = $gatingWLC_s;
} else {
    $host = $gatingWLC;
}

my $p_wlc_name = $csv_file{$preset}{'p_wlc_name'};
my $s_wlc_name = $csv_file{$preset}{'s_wlc_name'};


$ap_rf_dec = mac_hex_decimal($ap_rf_hex);

my $result = `$snmpget -v2c -c $gatingCommunity $host $bsnAPGroupVlanName.$ap_rf_dec`;
$result = `$snmpset -v2c -c $gatingCommunity $host $bsnAPGroupVlanName.$ap_rf_dec s $ap_grp $bsnAPPrimaryMwarName.$ap_rf_dec s $p_wlc_name $bsnAPSecondaryMwarName.$ap_rf_dec s $s_wlc_name`;
if($result !~ /error/){
    $result = `$perl $rebootAp $ap_rf_hex $client_ip $preset`;
}
print $result;