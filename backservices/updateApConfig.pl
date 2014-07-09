#!/usr/bin/perl -w
#
###############################################
###  Author:       Yin Chen                  ##
###  Contact:      yinche@cisco.com          ##
###  Data:         Nov 21 2013               ##
###  Project:      apvt                      ##
###############################################

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use Log::Log4perl;
use Log::Dispatch::FileRotate;
use File::Path qw(make_path);
use File::Slurp;
use OIDS;

require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/appt.conf";
use vars qw ($gatingWLC $gatingCommunity $perl $snmpget $snmpset $log_conf $provision_log_path);

Log::Log4perl::init("$FindBin::Bin/conf/$log_conf");
my $access_logger = Log::Log4perl->get_logger('appt_access');
my $error_logger = Log::Log4perl->get_logger('appt_error');

my $start = Time::HiRes::gettimeofday();
my ($username, $ap_eth_mac, $ap_name, $ap_location, $ap_radio_mac, $primary_controller_name, $primary_controller_ip, $secondary_controller_name, $secondary_controller_ip, $ap_group, $property);
if (@ARGV >= 11) { 
    $username = $ARGV[0];
    $ap_name = $ARGV[1];
    $ap_eth_mac = $ARGV[2];
    $ap_radio_mac= $ARGV[3];
    $primary_controller_name = $ARGV[4];
    $primary_controller_ip = $ARGV[5];
    $ap_location = $ARGV[6];
    $ap_group = $ARGV[7];
    $secondary_controller_name = $ARGV[8];
    $secondary_controller_ip = $ARGV[9];
    $property = $ARGV[10];
} else {
    $error_logger->error("Missing argument required 11 arguments, received @ARGV");
    exit 1;
}

if (!$secondary_controller_name){
    $secondary_controller_name = "''";
    $secondary_controller_ip = "''";
}
$ap_location =~ s/'//g;
my $ap_rf_dec = mac_hex_decimal($ap_radio_mac);
my $read = `$snmpget -v2c -c $gatingCommunity $gatingWLC $bsnAPName.$ap_rf_dec $bsnAPLocation.$ap_rf_dec`;
my $cmd_string = "$snmpset -v2c -c $gatingCommunity $gatingWLC $bsnAPName.$ap_rf_dec s $ap_name $bsnAPLocation.$ap_rf_dec s '$ap_location' $bsnAPPrimaryMwarName.$ap_rf_dec s $primary_controller_name $cLApPrimaryControllerAddress.$ap_rf_dec s $primary_controller_ip $bsnAPSecondaryMwarName.$ap_rf_dec s $secondary_controller_name $cLApSecondaryControllerAddress.$ap_rf_dec s $secondary_controller_ip $bsnAPGroupVlanName.$ap_rf_dec s $ap_group";
my $result = `$cmd_string 2>&1`;

my $end = Time::HiRes::gettimeofday();
my $execution_time = sprintf("\n%.2f\n", $end - $start);
if ($result !~ /error/i) {
    chomp($execution_time);
    $access_logger->info("user: $username");
    $access_logger->info("it took $execution_time milliseconds to push the setting to AP.");
    $access_logger->info("------------------------------------------------------------------------");
    $access_logger->info($result);
    $access_logger->info("------------------------------------------------------------------------");

    if (!-d $provision_log_path){
        make_path($provision_log_path);
    }

    my $log_conf = q(
        log4perl.rootLogger              = INFO, LOG4
        log4perl.appender.LOG4           = Log::Dispatch::FileRotate
        log4perl.appender.LOG4.filename  = sub { logfilename(); };
        log4perl.appender.LOG4.mode      = append
        log4perl.appender.LOG4.max       = 5
        log4perl.appender.LOG4.size      = 15000
        log4perl.appender.LOG4.layout    = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.LOG4.layout.ConversionPattern = %d,%m%n
    );
    Log::Log4perl::init(\$log_conf);
    my $provision_logger = Log::Log4perl->get_logger();
    if (-z logfilename() ) {
     write_file( logfilename(), "timestamp,username,provision_stats,property,ap_name,ap_eth_mac,ap_radio_mac,ap_location,ap_primary_name,ap_primary_ip,ap_secondary_name,ap_secondary_ip,ap_group\n");
    }
    $provision_logger->info("$username,pushed,$property,$ap_name,$ap_eth_mac,$ap_radio_mac,$ap_location,$primary_controller_name,$primary_controller_ip,$secondary_controller_name,$secondary_controller_ip, $ap_group");
    
} else {
    $error_logger->error("user: $username");
    $error_logger->error("$0: $cmd_string");
    $error_logger->error("------------------------------------------------------------------------");
    $error_logger->error($result);
    $error_logger->error("------------------------------------------------------------------------");
}

exit 0;


sub logfilename {
    return "$provision_log_path/$property.csv";
}
