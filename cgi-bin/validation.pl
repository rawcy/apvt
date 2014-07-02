#!/usr/bin/perl
use CGI;
use File::Slurp;
use strict;
use warnings;
use FindBin;

# read the CGI params
my $cgi = CGI->new;

my $controller_ip = $cgi->param("controller_ip");
my $ap_eth_mac =$cgi->param("ap_eth_mac");
my $client_ip = $cgi->param("client_ip");

my $json = "";
my $conf_dir = "$FindBin::Bin/conf";
require "$FindBin::Bin/conf/apptweb.conf";
my $search_ap = "$perl $searchAp $client_ip $ap_eth_mac $controller_ip ";