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
# my $start = Time::HiRes::gettimeofday();
require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/apvt.conf";
use vars qw ($gatingWLC $gatingWLC_s $gatingCommunity %csv_file);
my $perl = '/usr/bin/perl';
my ($host, $client_ip, $ap_name, $ap_location, $ap_rf_hex, $ap_mac_hex, $preset);
if (@ARGV >= 5) {
	$ap_rf_hex = $ARGV[0];
	$preset = $ARGV[1];
	$ap_name = $ARGV[2];
	$ap_location = $ARGV[3];
    $client_ip = $ARGV[4];
} else {
	print "ERROR: no argument passed";
	exit 1;
}
if($client_ip =~ /[0-9]{2}\.[0-9]{2}\.129\.[0-9]{2}/) {
    $host = $gatingWLC;
} elsif ($client_ip =~ /[0-9]{2}\.[0-9]{2}\.130\.[0-9]{2}/) {
    $host = $gatingWLC_s;
}
my $ap_rf_dec = mac_hex_decimal($ap_rf_hex);
my $p_wlc_ip = ip_dec_hex($csv_file{$preset}{'p_wlc'});
my $s_wlc_ip = ip_dec_hex($csv_file{$preset}{'s_wlc'});
my $read = `snmpget -v2c -c $gatingCommunity $host $bsnAPName.$ap_rf_dec $bsnAPLocation.$ap_rf_dec`;
my $result = `snmpset -v2c -c $gatingCommunity $host $bsnAPName.$ap_rf_dec s $ap_name $bsnAPLocation.$ap_rf_dec s $ap_location $cLApPrimaryControllerAddress.$ap_rf_dec x $p_wlc_ip $cLApSecondaryControllerAddress.$ap_rf_dec x $s_wlc_ip`;
		
if($result =~ /error/){
    print "'','','',$result";
}
else {
	my $result = `$perl searchAP.pl $client_ip $ap_rf_dec`;
	my ($error, $result_data) = split(";", $result, 2);
	
	my ($ap_name_a, $ap_eth_hex, $ap_rf_hex, $ap_ip, $p_wlc, $s_wlc, $location) = split(',', $result_data);
	
    print "$ap_name_a,$p_wlc,$s_wlc,$location,''";
}

# my $end = Time::HiRes::gettimeofday();
# printf("\n%.2f\n", $end - $start);