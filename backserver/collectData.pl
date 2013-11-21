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
use FileHandle;
use Cwd;
use FindBin;
use lib "$FindBin::Bin/lib";
use OIDS;

use vars qw ($delay_cycle $samplingrate $default_samplingrate $maxRunTime);

my $log_dir = "$FindBin::Bin/tmp";
require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/apvt.conf";

my ($host, $community, $client_ip, $client_mac_dec, $ap_mac_dec, $ap_ip, $ap_slot_id, $client_ch, $output, @threads, $ERR, $WARN);
$SIG{TERM} = \&interrupt;
my $term = 1;
# retrieve the %client_list
if (@ARGV >= 9) {
	$host = $ARGV[0];
	$community = $ARGV[1];
	$client_ip = $ARGV[2];
	$client_mac_dec = $ARGV[3];
	$ap_mac_dec = $ARGV[4];
	$ap_ip = $ARGV[5];
	$ap_slot_id = $ARGV[6];
	$client_ch = $ARGV[7];
	$output = $ARGV[8];
} else {
	print "ERROR: only @ARGV  argument passed, required was 9. \n";
	$ERR .= "ERROR: only @ARGV argument passed, required was 9. \n";
	exit 1;
}

if (!-d $log_dir){
	`mkdir $log_dir`;
}

# log the session info 
my $logfile = "$log_dir/$output.log";
#print $logfile . "\n";
my $fh = FileHandle->new();
my $client_mac_hex = format_mac_decimal($client_mac_dec);
my $ap_mac_hex = format_mac_decimal($ap_mac_dec);

open($fh, "> $logfile");
print $fh "Client INFO\tMAC address:$client_mac_hex, IP_Address:$client_ip, Channel:$client_ch\n";	
print $fh "Assoicated AP INFO\tMAC_address:$ap_mac_hex, IP_address:$ap_ip, AP_Slot_Id:$ap_slot_id\n";
close $fh;

# create SNMP session 
my ($error, $session) = snmp_connect($host, $community);
my $csvfile = "$log_dir/$output.csv";
#print $csvfile . "\n";
my @interested_oid = ();

my $set_samplingrate = $session->set_request(-varbindlist => ["$OID_bsnAPStatsTimer.$ap_mac_dec", INTEGER, $samplingrate],);

if (! -e $csvfile){
	open($fh, "> $csvfile");
	print $fh "timestamp,";
	foreach my $key (sort keys %interested_oid){
		foreach my $oid (sort keys %{$interested_oid{$key}}){
			print $fh "$oid,";
			my $oid_num = ${$interested_oid{$key}}{$oid};
			$oid_num =~ s/AP_mac_dec/$ap_mac_dec/e; # get oid for AP mac address
			$oid_num =~ s/APSlotId/$ap_slot_id/e; # get oid for AP Slot Id
			$oid_num =~ s/client_mac_dec/$client_mac_dec/e; # get oid for client mac
			$oid_num =~ s/client_channel/$client_ch/e; # get oid for client channel
			push(@interested_oid, $oid_num);
		}	
	}	
	print $fh "\n";	
} else {
	open($fh, ">> $csvfile");
}

do{
	my $start = time();
   # print $start . "\n";
	my $stationstats = $session->get_request(-varbindlist => \@interested_oid);
	print $fh time . ",";
	foreach my $key (@interested_oid){
		print $fh $$stationstats{"$key"} . ",";
	}
	print $fh "\n";
	while ((time - $start) lt $samplingrate) {}
	my $currentRunTime=`ps ax | awk '/$output\$/ {split(\$4,a,":"); print a[1]}'`;
	#print $currentRunTime . "\n";
	if (($term == 2) || ($maxRunTime == $currentRunTime)){
		$term = 0 if $delay_cycle == 0;
		$delay_cycle--;
	}
}while($term);
close $fh;

$session->close();

sub interrupt {
	my $set_samplingrate = $session->set_request(-varbindlist => ["$OID_bsnAPStatsTimer.$ap_mac_dec", INTEGER, $default_samplingrate],);
    $term = 2;
}

