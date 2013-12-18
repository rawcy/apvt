#!/usr/bin/perl -w

##############################################
##  Author:       Yin Chen                  ##
##  Contact:      yinche@cisco.com          ##
##  Data:         Nov 21 2013               ##
##  Project:      apvt                      ##
##############################################

use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use FindBin;
use File::Slurp;
use lib "$FindBin::Bin/lib";
require "$FindBin::Bin/conf/apvtweb.conf";


use vars qw ($perl $joinApGroup);
my $client_ip = $ENV{'REMOTE_ADDR'};
print header;
print start_html(-title => "Cisco APVT",
                  -style=>{-src=>['/cgi-bin/css/apvt.css']} );
my @fields = param;
if (@fields == 0) {
    print "<h2>ERROR: NO AP MAC address passed</h2>";  
} elsif (param('ap_mac')) {
      
    my $ap_rf_hex = param('ap_mac');
    my $ap_grp = param('ap_grp');
    my results = system("$perl $joinApGroup $ap_rf_hex $ap_grp $client_ip");
    print "<div class='content_inner_section'>";
    print "<h2>The AP is rebooting, and it will take few minutes to allow the AP to get in working stats. </h2>";
    print<<HTMLend;
    <form method="post">
        <button action="action" value="Close Window" onclick="javascript:window.close();">Close Window</button>
    </form>
HTMLend
    print "</div>";
    
}
print end_html;