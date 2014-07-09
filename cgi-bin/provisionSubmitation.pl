#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Cookie;
use JSON qw( decode_json );
use FindBin;
use Data::Dumper

require "$FindBin::Bin/conf/apptweb.conf";

use vars qw ($perl $updateApconfig);
# read the CGI params
my $cgi = CGI->new;
my $apName = $cgi->param("ap_name");
my $apRadioMac = $cgi->param("ap_radio_mac");
my $primaryControllerName = $cgi->param("primary_controller_name");
my $primaryControllerIp = $cgi->param("primary_controller_ip");
my $secondaryControllerName =$cgi->param("secondary_controller_name");
my $secondaryControllerIp = $cgi->param("secondary_controller_ip");
my $apLocation = $cgi->param("ap_location");
my $apGroup = $cgi->param("ap_group");
my $username = CGI->cookie('username') || '';

my $rcvd_cookies = $ENV{'HTTP_COOKIE'};
my @cookies = split(";", $rcvd_cookies);
my ( $provisioning_info, $ap_info);
foreach my $cookie (@cookies) {
    $provisioning_info = $2 if ($cookie =~ /(provisioning_info=)(.*)/);
    $ap_info = $2 if ($cookie =~ /(ap_info=)(.*)/);
} 
my $decoded_provision_info = decode_json($provisioning_info);
my $decoded_ap_info = decode_json($ap_info);
my $property = $decoded_provision_info->{'property'};
my $apEthMac = $decoded_ap_info->{'eth_mac'};
my $json = "";
$apLocation =~ s/'//g;
my $cmd_string = "$perl $updateApconfig $username $apName $apEthMac $apRadioMac $primaryControllerName $primaryControllerIp '$apLocation' $apGroup";
if ($secondaryControllerName) {
    $cmd_string .= " $secondaryControllerName $secondaryControllerIp"; 
} else {
    $cmd_string .= " '' ''";
}

$cmd_string .= " $property";

my $resultPushSettingToAp = `$cmd_string`;
my $string = quotemeta "Failed object";
if($resultPushSettingToAp =~ /$string/){
    $json = qq{{"err" : $resultPushSettingToAp}};
} else {
    $json = qq{{"results" : "$cmd_string"}};
}

print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;
