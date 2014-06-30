#!/usr/bin/perl -w

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Nov 21 2013               ##
##  Project:      apvt                      ##
##############################################

use strict;
use warnings;
use Net::SNMP;
use FindBin;
use File::Slurp;
use lib "$FindBin::Bin/lib";
use OIDS;
use Data::Dumper;

my ($ap_name, $ap_location, $ap_rf_hex, $primary_controller_name, $primary_controller_ip, $secondary_controller_name, $secondary_controller_ip, $ap_group);
if (@ARGV >= 6) {
    $ap_name = $ARGV[0];
	$ap_rf_hex = $ARGV[1];
    $primary_controller_name = $ARGV[2];
    $primary_controller_ip = $ARGV[3];
	$ap_location = $ARGV[4];
    $ap_group = $ARGV[5];
    if(@ARGV >= 8){
        $secondary_controller_name = $ARGV[6];
        $secondary_controller_ip = $ARGV[7];
    }    
} else {
	print "ERROR: no argument passed";
	exit 1;
}

# my $start = Time::HiRes::gettimeofday();
require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/appt.conf";
use vars qw ($gatingWLC $gatingCommunity $perl $snmpget $snmpset);

my $ap_rf_dec = mac_hex_decimal($ap_rf_hex);

my $read = `$snmpget -v2c -c $gatingCommunity $gatingWLC $bsnAPName.$ap_rf_dec $bsnAPLocation.$ap_rf_dec`;
my $result = `$snmpset -v2c -c $gatingCommunity $gatingWLC $bsnAPName.$ap_rf_dec s $ap_name $bsnAPLocation.$ap_rf_dec s $ap_location $bsnAPPrimaryMwarName.$ap_rf_dec s $primary_controller_name $cLApPrimaryControllerAddress.$ap_rf_dec s $primary_controller_ip $bsnAPSecondaryMwarName.$ap_rf_dec s $secondary_controller_name $cLApSecondaryControllerAddress.$ap_rf_dec s $secondary_controller_ip $bsnAPGroupVlanName.$ap_rf_dec s $ap_group`;


# my $end = Time::HiRes::gettimeofday();
# printf("\n%.2f\n", $end - $start);