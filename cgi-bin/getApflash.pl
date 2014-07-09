#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Cookie;
use FindBin;

require "$FindBin::Bin/lib/common.pl";
require "$FindBin::Bin/conf/apptweb.conf";
use vars qw ($perl $flashAp $searchAp);


my $cgi = CGI->new;
my $apRadioMac = $cgi->param("ap_radio_mac");
my ($json, $pid); 
if (@ARGV >= 1) {
   $apRadioMac = $ARGV[0];
}
my $username = CGI->cookie('username') || '';
my $ap_rf_dec = mac_hex_decimal($apRadioMac);
my $result=`$perl $searchAp "" $ap_rf_dec $username`;

my ($error, $result_data) = split(";", $result, 2);

if ($error) {
    $json = qq{{"error ":"AP $apRadioMac not find on Staging Contoller"}};
} else {
    $pid = fork();
    if (defined $pid && $pid == 0) {
        my $cmd_string = "$perl $flashAp $username $apRadioMac &>/dev/null &"; 
        system($cmd_string);
    exit 0;
    }
    $json = qq{{"success" : " $username flashing the ap $apRadioMac"}};     
}
    
print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;
exit 0;
