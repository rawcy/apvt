#!/usr/bin/perl
use CGI;
use File::Slurp;
use strict;
use warnings;
use FindBin;

# read the CGI params
my $cgi = CGI->new;
my $apName = $cgi->param("provisioning-apname");
my $primary-controller-ip = $cgi->param("provisioning-primary-controller-ip");
my $secondary-controller-ip = $cgi->param("provisioning-secondary-controller-ip");
my $apLocation = $cgi->param("provisioning-location");
my $apGroup = $cgi->param("provisioning-apgroup");

my $json = "";
if(1){
    $json = qq{{"results" : "passed", "name" : "$apName", "pip" : "$primary-controller-ip",
                "sip" : "$$secondary-controller-ip", "location" : "$apLocation", "apgroup" : "$apGroup"}};
} else {
    $json = qq{{"results" : "failed", "name" : "$apName", "pip" : "$primary-controller-ip",
                "sip" : "$$secondary-controller-ip", "location" : "$apLocation", "apgroup" : "$apGroup"}};

}

print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;