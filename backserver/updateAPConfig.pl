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
use Net::IP;
use lib "$FindBin::Bin/lib";
use OIDS;
use Data::Dumper;

require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/apvt.conf";
use vars qw ($gatingWCL $gatingCommunity %csv_file);

my ($ap_rf_hex, $ap_mac_hex, $ap_id);
if (@ARGV >= 2) {
	$ap_rf_hex = $ARGV[0];
	$ap_id = $ARGV[1];
} else {
	print "ERROR: no argument passed";
	exit 1;
}

my $ap_rf_dec = mac_hex_decimal($ap_rf_hex);

my $result = `snmpset -v2c -c $gatingCommunity $csv_file{$ap_id}{'p_wlc'} 
		$cLApPrimaryControllerAddress.$ap_rf_dec x Net::IP->new($csv_file{$ap_id}{'p_wlc'})->hexip() 
		$cLApSecondaryControllerAddress.$ap_rf_dec x Net::IP->new($csv_file{$ap_id}{'s_wlc'})->hexip() 
		$bsnAPLocation.$ap_rf_dec s $csv_file{$ap_id}{'location'}`;
		
if($result =~! /error/){
	return ($csv_file{$ap_id}{'p_wlc'}, $csv_file{$ap_id}{'s_wlc'}, $csv_file{$ap_id}{'location'}, '');
}
else {
	return ('', '', '', $result);
}
