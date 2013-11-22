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
use lib "$FindBin::Bin/lib";
use OIDS;
use Data::Dumper;

require "$FindBin::Bin/lib/common_snmp.pl";

BEGIN { our $start_run = time(); }

my ($client_ip, $clientMAC, $ap_id, $host, $community, $ERR);
if (@ARGV >= 1) {
	$client_ip = $ARGV[0];
	if (@ARGV >=2 ) {
		$clientMAC = $ARGV[1];
	}
	if (@ARGV >=3 ) {
		$ap_id = $ARGV[2];
	}
} else {
	print "ERROR: no argument passed";
	exit 1;
}

if (! -r "$FindBin::Bin/conf/apvt.conf") {
     print "ERROR: apvt.conf is not readable\n";
     exit 2;
}

# global variables
my $perl = '/usr/bin/perl';
require "$FindBin::Bin/conf/apvt.conf";
use vars qw ($gatingWCL $gatingCommunity %csv_file);

if(defined !$ap_id){
	$host = $gatingWCL;
	$community = $gatingCommunity;
} else {
	$host=$csv_file{$ap_id}{'p_wlc'};
	$community=$csv_file{$ap_id}{'community'};
}

my $clientMAC_dec = mac_hex_decimal($clientMAC);
#mac_hex_decimal($client_mac_hex);
search_client($host, $community, $client_ip, $clientMAC_dec);

sub search_client {
	my ($host, $community, $client_ip, $clientMAC_dec) = @_;
	
	my ($client_mac_dec, $ap_rf_dec, $ap_rf_hex, $ap_mac_hex, $ap_ip, $ap_slot_id, $client_ch, $p_wlc, $s_wlc, $location);
	# create SNMP session
	
	my ($error, $session) = snmp_connect($host, $community);
	if (!$session) {
		print "ERROR:$error";
        	return;	    
	} else {
        my $client_status;
		if (!$clientMAC_dec){ # search the client MAC by IP in WLC
			my $client_ips = $session->get_table(-baseoid => $OID_grp_bsnMobileStationIpAddress);
			foreach my $oid (keys %$client_ips){
					if($$client_ips{$oid} == $client_ip){
						$client_mac_dec = $oid;
						$client_mac_dec =~ s/$OID_grp_bsnMobileStationIpAddress\.//;
#						$client_mac_hex = mac_hex_decimal($client_mac_dec);				
						last;
					}
			}
			undef $client_ips; # free memory
		} else {
            $client_status = $session->get_request(-varbindlist => ["$OID_grp_bsnMobileStationStatus.$clientMAC_dec"]);
			if ($$client_status{"$OID_grp_bsnMobileStationStatus.$clientMAC_dec"} !~ /noSuchInstance/) {
				$client_mac_dec = $clientMAC_dec;
#				$client_mac_hex = mac_hex_decimal($client_mac_dec);
			}
		}
		if ($client_mac_dec){
			my $client_status = $session->get_request(-varbindlist => ["$OID_grp_bsnMobileStationStatus.$client_mac_dec"] );
			if ($$client_status{"$OID_grp_bsnMobileStationStatus.$client_mac_dec"} == 3){
				my $client_ap_info = $session->get_request(-varbindlist => [ "$OID_grp_bsnMobileStationAPMacAddr.$client_mac_dec", "$OID_grp_bsnMobileStationAPIfSlotId.$client_mac_dec" ] );
				$ap_rf_hex = format_mac_hex($$client_ap_info{"$OID_grp_bsnMobileStationAPMacAddr.$client_mac_dec"});
				$ap_rf_dec = mac_hex_decimal($ap_rf_hex);
				$ap_slot_id = $$client_ap_info{"$OID_grp_bsnMobileStationAPIfSlotId.$client_mac_dec"};
				$client_ap_info = $session->get_request(-varbindlist => [ "$OID_grp_bsnApIpAddress.$ap_rf_dec", "$OID_grp_bsnAPIfPhyChannelNumber.$ap_rf_dec.$ap_slot_id", 
					"$cLApIfMacAddress.$ap_rf_dec", "$cLApPrimaryControllerAddress.$ap_rf_dec", "$cLApSecondaryControllerAddress.$ap_rf_dec", "$bsnAPLocation.$ap_rf_dec" ] );
				$ap_ip = $$client_ap_info{"$OID_grp_bsnApIpAddress.$ap_rf_dec"};
				$ap_mac_hex = format_mac_hex($$client_ap_info{"$cLApIfMacAddress.$ap_rf_dec"});
				$client_ch = $$client_ap_info{"$OID_grp_bsnAPIfPhyChannelNumber.$ap_rf_dec.$ap_slot_id"};
				$p_wlc	= $$client_ap_info{"$cLApPrimaryControllerAddress.$ap_rf_dec"};
				$s_wlc = $$client_ap_info{"$cLApSecondaryControllerAddress.$ap_rf_dec"};
				$location = $$client_ap_info{"$bsnAPLocation.$ap_rf_dec"};
			}
		}
	}

	return ($client_mac_dec, $ap_mac_hex, $ap_rf_hex, $ap_slot_id, $ap_ip, $client_ch, $p_wlc, $s_wlc, $location);
}
