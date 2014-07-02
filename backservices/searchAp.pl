#!/usr/bin/perl

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Nov 21 2013               ##
##  Project:      apvt                      ##
##############################################


use strict;
use warnings;
use Net::SNMP qw(:snmp);
use FindBin;
use lib "$FindBin::Bin/lib";
use OIDS;
use Data::Dumper;
use File::Slurp;
require "$FindBin::Bin/lib/common_snmp.pl";

BEGIN { our $start_run = time(); }

my ($host, $community, $client_ip, $AP_MAC_dec, $community, $ERR, $controller_ip, $controller_community);
if (@ARGV >= 1) {
    $client_ip = $ARGV[0];
    if (@ARGV >=2 ) {
        $AP_MAC_dec = $ARGV[1];
    }
    if (@ARGV >=4) {
        $controller_ip = $ARGV[2];
        $controller_community = $ARGV[3];
    }
} else {
    print "ERROR: no argument passed";
    exit 1;
}

if (! -r "$FindBin::Bin/conf/appt.conf") {
     print "ERROR: apvt.conf is not readable\n";
     exit 2;
}
# global variables

require "$FindBin::Bin/conf/appt.conf";
use vars qw ($gatingWLC $gatingCommunity %csv_file $perl);

if ($controller_ip) {
    $host = $gatingWLC;
    $community = $gatingCommunity;
} else {
    $host = controller_ip;
    $community = $controller_community;
}

#mac_hex_decimal($client_mac_hex);
my ($error_msg, $ap_name, $ap_eth_hex, $ap_rf_hex, $ap_ip, $p_wlc, $s_wlc, $location, $ap_grp) = search_client($host, $community, $client_ip, $AP_MAC_dec);
print "$error_msg;$ap_name,$ap_eth_hex,$ap_rf_hex,$ap_ip,$p_wlc,$s_wlc,$location,$ap_grp";

sub search_client {
    my ($host, $community, $client_ip, $AP_MAC_dec) = @_;
    my $err_msg = "";
    my ($target_mac_dec, $ap_name, $ap_rf_dec, $ap_rf_hex, $ap_eth_hex, $ap_ip, $ap_slot_id, $client_ch, $p_wlc, $s_wlc, $location, $ap_grp);
    # create SNMP session
    my ($error, $session) = snmp_connect($host, $community);
    if (!$session) {
        $err_msg = $error;      
        printf("ERROR: %s.\n", $error);
        print Dumper $error;
        exit 1;
    } else {
        if (!$AP_MAC_dec) { # search the AP MAC by Client IP in WLC
            my $client_ips = $session->get_table(-baseoid => $OID_grp_bsnMobileStationIpAddress);
            foreach my $oid (keys %$client_ips){
                if($$client_ips{$oid} eq $client_ip){
                    my $client_mac_dec = $oid;
                    $client_mac_dec =~ s/$OID_grp_bsnMobileStationIpAddress\.//;
                    my $client_status = $session->get_request(-varbindlist => ["$OID_grp_bsnMobileStationStatus.$client_mac_dec"] );
                    if ($$client_status{"$OID_grp_bsnMobileStationStatus.$client_mac_dec"} == 3){
                        my $client_ap_info = $session->get_request(-varbindlist => [ "$OID_grp_bsnMobileStationAPMacAddr.$client_mac_dec"] );
                        $target_mac_dec = mac_hex_decimal(format_mac_hex($$client_ap_info{"$OID_grp_bsnMobileStationAPMacAddr.$client_mac_dec"}));
                    }   
                    last;
                }
            }
            undef $client_ips; # free memory
        } else {
            my %tables;
            $$session{'_nonblocking'}=1;
            my $result = $session->get_bulk_request(   
                -callback       => [\&bulk_cb, \%tables, $bsnAPEthernetMacAddress, $bsnAPEthernetMacAddress],
               -maxrepetitions => 10,
               -varbindlist    => [$bsnAPEthernetMacAddress]);
            $$session{'_nonblocking'}=0;
            if (!defined($result)) {
                $err_msg = "ERROR: $session->error";
                $session->close;
                exit 1;
            }
            snmp_dispatcher();
            if (exists $tables{"$bsnAPEthernetMacAddress.$AP_MAC_dec"}) {
                $target_mac_dec = $AP_MAC_dec;
            } else {
                foreach my $oids (keys %tables){
                  if (mac_hex_decimal(format_mac_hex($tables{$oids})) eq $AP_MAC_dec) {
                      $target_mac_dec =$oids;
                      $target_mac_dec =~ s/$bsnAPEthernetMacAddress\.//;
                  }
                }
            }
        }
        if ($target_mac_dec){
            my $ap_info = $session->get_request(-varbindlist => [ "$OID_grp_bsnApIpAddress.$target_mac_dec", "$bsnAPEthernetMacAddress.$target_mac_dec", 
                "$bsnAPName.$target_mac_dec", "$bsnAPLocation.$target_mac_dec", "$bsnAPDot3MacAddress.$target_mac_dec",
                "$bsnAPPrimaryMwarName.$target_mac_dec", "$bsnAPSecondaryMwarName.$target_mac_dec", "$bsnAPGroupVlanName.$target_mac_dec"] );
            $ap_name = $$ap_info{"$bsnAPName.$target_mac_dec"};
            $ap_ip = $$ap_info{"$OID_grp_bsnApIpAddress.$target_mac_dec"};
            $ap_eth_hex = format_mac_hex($$ap_info{"$bsnAPEthernetMacAddress.$target_mac_dec"});
            $p_wlc = $$ap_info{"$bsnAPPrimaryMwarName.$target_mac_dec"};
            $s_wlc = $$ap_info{"$bsnAPSecondaryMwarName.$target_mac_dec"};
            $location = $$ap_info{"$bsnAPLocation.$target_mac_dec"};
            $ap_rf_hex = format_mac_hex($$ap_info{"$bsnAPDot3MacAddress.$target_mac_dec"});   
            $ap_grp = $$ap_info{"$bsnAPGroupVlanName.$target_mac_dec"};  
        } else {
            $err_msg = "Error: Couldn't find AP on WLC: $host";
        }
    }
    $session->close();
    return ($err_msg, $ap_name, $ap_eth_hex, $ap_rf_hex, $ap_ip, $p_wlc, $s_wlc, $location, $ap_grp);
}