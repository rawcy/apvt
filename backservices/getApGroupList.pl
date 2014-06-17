#!/usr/bin/perl -w

##############################################
##  Author:       Yin Chen                  ##
##  Contact:      yinche@cisco.com          ##
##  Data:         Dec 17 2013               ##
##  Project:      apvt                      ##
##############################################

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use FindBin;
use OIDS;
use Net::SNMP qw(:snmp);
use Data::Dumper;

my ($preset, $host, $community, $ap_grp_list, $err_msg);

if (@ARGV >= 1) {
    $preset = $ARGV[0];
} else {
    print "ERROR: no argument passed";
    exit 1;
}

require "$FindBin::Bin/lib/common_snmp.pl";
if (! -r "$FindBin::Bin/conf/apvt.conf") {
     print "ERROR: apvt.conf is not readable\n";
     exit 1;
}
require "$FindBin::Bin/conf/apvt.conf";
# global variables

use vars qw (%csv_file);



$host = $csv_file{$preset}{'p_wlc'};
$community = $csv_file{$preset}{'community'};

my ($error, $session) = snmp_connect($host, $community);
if (!$session) {
	$err_msg = $error;	    
    printf("ERROR: %s.\n", $error);
    print Dumper $error;
    exit 1;
} else {
	my %tables;
	$$session{'_nonblocking'} = 1;
	my $result = $session->get_bulk_request(   	
		-callback       => [\&bulk_cb, \%tables, $bsnAPGroupsVlanName, $bsnAPGroupsVlanName],
		-maxrepetitions => 10,
		-varbindlist    => [$bsnAPGroupsVlanName]);
	$$session{'_nonblocking'}=0;
	if (!defined($result)) {
            $err_msg = "ERROR: $session->error";
            exit 1;
    }
    snmp_dispatcher();
    $session->close;
    $ap_grp_list = "default-group";
    foreach my $grp (sort values %tables) {
        if($grp ne "default-group"){
            $ap_grp_list .= ",$grp";
        }
    }
}

print $ap_grp_list;