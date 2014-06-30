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
my ($ap_rf_dec, $ap_rf_hex, $ap_group);
if (@ARGV >= 2) {
    $ap_rf_hex = $ARGV[0];
    $ap_group = $ARGV[1];
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
#require "logs.pl";

# global variables
use vars qw ($gatingWLC $gatingCommunity $perl $snmpget $snmpset);

$ap_rf_dec = mac_hex_decimal($ap_rf_hex);

# print "$snmpset -v2c -c $gatingCommunity $host $bsnAPPrimaryMwarName.$ap_rf_dec s $p_wlc_name $bsnAPSecondaryMwarName.$ap_rf_dec s $s_wlc_name\n";


my $result = `$snmpget -v2c -c $gatingCommunity $gatingWLC $bsnAPGroupVlanName.$ap_rf_dec $bsnAPReset.$ap_rf_dec`;
$result = `$snmpset -v2c -c $gatingCommunity $gatingWLC $bsnAPGroupVlanName.$ap_rf_dec s $ap_group $bsnAPReset.$ap_rf_dec i 1`;
my $string = quotemeta "$ap_rf_dec = INTEGER: 1";
if($result =~ /$string/){
    print "AP reboot Seccussful.";
}