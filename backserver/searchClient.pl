#!/usr/bin/perl -w

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         May 8 2013                ##
##  Project:      wMOS                      ##
##############################################


use strict;
use warnings;
use Net::SNMP;
use threads;
use threads::shared;
use Thread::Semaphore;
use XML::Simple;
use FindBin;
use lib "$FindBin::Bin/lib";
use OIDS;
use Data::Dumper;

require "$FindBin::Bin/lib/common_snmp.pl";

BEGIN { our $start_run = time(); }

my ($clientMAC, $ERR);
if (@ARGV >= 1) {
	$clientMAC = $ARGV[0];
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
use vars qw ($gatingWCL $gatingCommunity);


my $clientMAC_dec = mac_hex_decimal($clientMAC);
#mac_hex_decimal($client_mac_hex);
search_client($gatingWCL, $gatingCommunity, ,$clientMAC_dec);

sub search_client {
	my ($host, $community, $client_ip, $clientMAC_dec) = @_;
	
	my ($client_mac_dec, $ap_mac_dec, $ap_ip, $ap_slot_id, $client_ch);
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
				$ap_mac_dec = mac_hex_decimal(format_mac_hex($$client_ap_info{"$OID_grp_bsnMobileStationAPMacAddr.$client_mac_dec"}));
				$ap_slot_id = $$client_ap_info{"$OID_grp_bsnMobileStationAPIfSlotId.$client_mac_dec"};
				$client_ap_info = $session->get_request(-varbindlist => [ "$OID_grp_bsnApIpAddress.$ap_mac_dec", "$OID_grp_bsnAPIfPhyChannelNumber.$ap_mac_dec.$ap_slot_id" ] );
				$ap_ip = $$client_ap_info{"$OID_grp_bsnApIpAddress.$ap_mac_dec"};
				$client_ch = $$client_ap_info{"$OID_grp_bsnAPIfPhyChannelNumber.$ap_mac_dec.$ap_slot_id"};
			}
		}
	}
	return ($ap_mac_dec, $ap_slot_id, $ap_ip, $client_ch);
}
