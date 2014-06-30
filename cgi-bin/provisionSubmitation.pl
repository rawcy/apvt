#!/usr/bin/perl
use CGI;
use File::Slurp;
use strict;
use warnings;
use FindBin;

require "$FindBin::Bin/conf/apptweb.conf";

use vars qw ($perl $updateApconfig $rebootAp);
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

my $json = "";
my $cmd_string = "$perl $updateApconfig $apName $apRadioMac $primaryControllerName $primaryControllerIp $apLocation $apGroup";
if ($secondaryControllerName){
    $cmd_string .= " $secondaryControllerName $secondaryControllerIp"; 
}
my $resultPushSettingToAp = `$cmd_string`;
my $string = quotemeta "Failed object";
if($resultPushSettingToAp =~ /$string/){
    $json = qq{{"err" : "$cmd_string"}};
} else {
    $json = qq{{"results" : "$cmd_string"}};
}

print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;