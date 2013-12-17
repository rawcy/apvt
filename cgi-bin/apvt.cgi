#!/usr/bin/perl

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Nov 21 2013               ##
##  Project:      apvt                      ##
##############################################


use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;
use FileHandle;
use CGI::Carp 'fatalsToBrowser';
use Cwd;
use XML::Simple;
use File::Slurp;
use FindBin;
use Time::HiRes qw( time );
require "$FindBin::Bin/conf/apvtweb.conf";
require "$FindBin::Bin/lib/common.pl";
use vars qw ($perl $updateApconfig $searchAp $fetchPreset $getApGroupList $joinApGroup $login $rebootAp);
my $start = time();
$ENV{PATH}="/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin";
my $email = "yinche\@cisco.com";
my $client_ip = $ENV{'REMOTE_ADDR'};
my $host = $ENV{'SERVER_NAME'};
my $cur_dir = getcwd(); 
my $script_name = $0;
$script_name =~ s/$cur_dir\///;


#mac address regexp
my $d = "[0-9A-Fa-f]";
my $dd = "$d$d";


print header;
print start_html(-title => "Cisco APVT",
                 -script=> [{   -type   => 'text/javascript',
                                -src    => '/javascript/apvt.js'    
                            },
                            {   -type   => 'text/javascript',
                                -src    => '/javascript/jquery.jeditable.js'
                            },
                            {   -type   => 'text/javascript',
                                -src    => '/javascript/jquery-1.10.2.min.js'
                            }],
                 -style=>{-src=>['/cgi-bin/css/apvt.css']});
require "header.cgi";
my @fields = param;
if (@fields == 0) {
    print <<EndHTML;
    <div class="content_inner_section">
    <h2>Cisco AP Validation Tool</h2>
    
    <h3>This is a demo version, interal user only</h3>
    
EndHTML
    print "<div id='loginResult' style='display:none;'> </div>";
    print start_form(-id => 'loginForm', -method=>'POST', -action=>"http://$host/cgi-bin/$script_name", -onSubmit=>"javascript:return login('/cgi-bin/$login')&&checkMACAddress()&&checkPreset();"), hidden('client_ip', $client_ip), "<br>",
    	"<fieldset> <legend>Enter information</legend> <p> <div id='username'> <label for='username'>Username</label> </div> <br />",
    	textfield( -name => 'userid', -id => 'userid', -size => 20, -maxlength => 20), "</p> <p> <div id='preset'> <label for='preset'>Preset</label> </div> <br />",
    	textfield( -name => 'preset', -id => 'preset_id', -size => 20, -maxlength => 17), "</p> <p> <div id='mac_div'> <label for='mac'>AP Mac Address (Optinal)</label> </div> <br />",
    	textfield( -name => 'ap_mac', -id => 'mac', -default => 'FF:FF:FF:FF:FF:FF', -size => 20, -maxlength => 17), "</p> <p>",
    	
        submit(-name=>'sub_form', -value=>'Start Validation'), "</p>", "</fieldset>", end_form, "</div>";
        
} elsif (param('ap_mac')) {
    my $preset = param('preset');
    my $userid = param('userid');
    my $ap_mac;
    my $search_ap = "$perl $searchAp $client_ip";
    if (param('ap_mac') != "FF:FF:FF:FF:FF:FF") {
        $ap_mac = mac_hex_decimal(param('ap_mac'));
        $search_ap .= " $ap_mac";
    }
    my $result = `$search_ap`;
    my ($error, $result_data) = split(";", $result, 2);
    if ($error) {
        print <<EndHTML;
        <div class="content_inner_section">
                <div class='error'>
EndHTML
        if (!$ap_mac) {
            print "$error\n";
            print "<p>Please check if connect to the correct ESSID</p>";
            print "<p>or enter the target AP's MAC address on preivous page</p>"; 
        } else {
            print "Please check the AP MAC address $ap_mac entered is correct.</p>";
            print "Contact Admin if you still have problem.</p>";
        }  
        print <<EndHTML;
                </div>
            <button action="action" value="Back" onclick="history.go(-1);">Back</button>
        </div>
EndHTML
    } else {
    	my ($ap_name, $ap_eth_hex, $ap_rf_hex, $ap_ip, $p_wlc, $s_wlc, $location, $ap_grp) = split(',', $result_data);
    	my $update_result = `$perl $fetchPreset $preset`;
    	my ($ap_name_u, $p_wlc_u, $s_wlc_u, $location_u) =  split(',', $update_result);
        my $ap_grp_list = `$perl $getApGroupList $preset`;
        my @ap_grp_list = split(',', $ap_grp_list);
        print <<EndHTML;
    	<div class="content_inner_section">
	        <table class="content_table">
	            <tr>
	                <caption> Basic Informarion </caption>
	            </tr>
	            <tr>
	                <td>AP MAC Address </td>
	                <td>$ap_rf_hex</td>
	                <td></td>
	            </tr>
	            <tr>
	                <td>AP IP Address </td>
	                <td>$ap_ip</td>
	                <td></td>
	            </tr>
	            <tr>
	                <td>AP Name </td>
	                <td>$ap_name</td>
	                <td id="ap_name_u"><input class="clr_orange" type="text" value="$ap_name_u" name="ap_name_u" onchange="updateSync(this.value, "ap_name_input")"></td>
	            </tr>
	            <tr>
	                <td>AP Primary Controller Address</td>
	                <td>$p_wlc</td>
	                <div class="update"><td>$p_wlc_u</td></div>
	            </tr>
	            <tr>
	                <td>AP Secondary Controller Address</td>
	                <td>$s_wlc</td>
	                <div class="update"><td>$s_wlc_u</td></div>
	            </tr>
	            <tr>
	                <td>AP Location</td>
	                <td>$location</td>
	                <td id="ap_location_u"><input class="clr_orange" type="text" value="$location_u" name="location_u" onchange="updateSync(this.value, "location_input")"></td>
	            </tr>
                <tr>
                    <td>AP Group</td>
                    <td>$ap_grp</td>
                    <td id="ap_grp_u">
EndHTML
        print popup_menu( -class=>'clr_orange', -name => 'local',-value =>\@ap_grp_list, -default=>'$ap_grp_list[0]', -onchange=>"updateSync(this.value, 'ap_grp_input')" );
        print<<EndHTML;
                </td>
                </tr>
	        </table>
EndHTML
    print start_form(-method=>'POST', -action=>"http://$host/cgi-bin/$script_name"), 
    	hidden('preset', $preset), hidden(-id => 'ap_name_input', -name=>'ap_name', -value=>$ap_name_u), hidden(-id => 'location_input', -name=>'location', -value=>$location_u), hidden(-id => 'ap_grp_input', -name=> 'ap_grp', -value=>$ap_grp_list[0]),
        hidden('ap_rf_hex', $ap_rf_hex), "&nbsp; &nbsp", submit(-name=>'sub_form', -value=>'Push AP Configuration'), end_form;
    print "</div>";
    }
}   elsif (param('p_wlc')) {
    my $crt_wlc = param('p_wlc');
    my $preset = param('preset');
    my $ap_rf_dec = mac_hex_decimal(param('ap_rf_hex'));
    my $result = `$perl $searchAp $client_ip $ap_rf_dec $preset`;
    my ($error, $result_data) = split(';', $result, 2);
    my ($ap_name, $ap_eth_hex, $ap_rf_hex, $ap_ip, $p_wlc, $s_wlc, $location, $ap_grp) = split(',', $result_data);
    print <<EndHTML;
    <div class="content_inner_section">
        <table class="content_table">
            <tr>
                <caption> Validation Informarion </caption>
            </tr>
            <tr>
                <td>AP Name</td>
                <td>$ap_name</td>
            </tr>
            <tr>
                <td>AP MAC Address </td>
                <td>$ap_rf_hex</td>
            </tr>
            <tr>
                <td>AP IP Address </td>
                <td>$ap_ip</td>
            </tr>
            <tr>
                <td>Current Controller</td>
                <td>$crt_wlc</td>
            </tr>
            <tr>
                <td>AP Primary Controller Address</td>
                <td>$p_wlc</td>
            </tr>
            <tr>
                <td>AP Secondary Controller Address</td>
                <td>$s_wlc</td>
            </tr>
            <tr>
                <td>AP Location</td>
                <td>$location</td>
            </tr>
            <tr>
                <td>AP Group</td>
                <td>$ap_grp</td>
            </tr>
        </table>
    </div>
EndHTML
} elsif (param('ap_name')) {
    my $preset = param('preset');
    my $ap_rf_hex = param('ap_rf_hex');
    my $ap_name = param('ap_name');
    my $location = param('location');
    my $ap_grp =param('ap_grp');
    my $ap_rf_dec = mac_hex_decimal($ap_rf_hex);
    my $mid = Time::HiRes::gettimeofday();
    printf("\n%.2f\n", $mid - $start);
    my $update_result = `$perl $updateApconfig $ap_rf_hex $preset $ap_name $location $client_ip`;
    my ($ap_name_u, $p_wlc_u, $s_wlc_u, $location_u, $err) =  split(',', $update_result);
    print <<EndHTML;
    
    <div class="content_inner_section">
        <table class="content_table">
            <tr>
                <caption> Updated Informarion </caption>
            </tr>
             <tr>
                <td>AP Name</td>
                <td>$ap_name_u</td>
            </tr>
            <tr>
                <td>AP Primary Controller Address</td>
                <td>$p_wlc_u</td>
            </tr>
            <tr>
                <td>AP Secondary Controller Address</td>
                <td>$s_wlc_u</td>
            </tr>
            <tr>
                <td>AP Location</td>
                <td>$location_u</td>
            </tr>
            <tr>
                <td>AP Group <spam class="clr_red">(not updated yet)</spam><spam class="help" title="reboot AP is required to update AP Group">?<spam></td>
                <td>$ap_grp</td>
        </table>
    <button id="apreboot" onclick="newpage('http://$host/cgi-bin/rebootAP.cgi?ap_mac=$ap_rf_hex&ap_grp=$ap_grp')">Reboot AP $ap_rf_hex</button>
    <br><br>
    <h3> Waiting till the AP is up after reboot the AP, </h3>
    <h3> Click "Validating AP Setting" button after client is associated with new SSID. </h3>
    <hr>
    <table>
        <tr>
            <td>
EndHTML
    print start_form(-method=>'POST', -action=>"http://$host/cgi-bin/$script_name"), hidden('preset', $preset), hidden('ap_rf_hex', $ap_rf_hex),   
        hidden('p_wlc', $p_wlc_u), "<br>", submit(-name=>'sub_form', -value=>'Validating AP Setting'), end_form, "&nbsp; &nbsp; </td><td>&nbsp; &nbsp;</td><td><button onclick='enable()'>Reset</button></td></tr></table></div>";
    my $end = Time::HiRes::gettimeofday();
    printf("\n%.2f\n", $end - $mid);
}

require "footer.cgi";
print end_html;