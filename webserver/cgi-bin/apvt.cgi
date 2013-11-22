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
use vars qw (%video_list @grp $wmosserver $wmosuser);
use FindBin;

require "$FindBin::Bin/conf/wMOSweb.conf";

$ENV{PATH}="/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin";
my $email = "yinche\@cisco.com";
my $client_ip = $ENV{'REMOTE_ADDR'};
my $host = $ENV{'SERVER_NAME'};
my $clients_info;
my $info_text;
my $cur_dir = getcwd(); 
my $perl = '/usr/bin/perl';
my $ssh = '/usr/bin/ssh';
my $script_name = $0;
$script_name =~ s/$cur_dir\///;


#mac address regexp
my $d = "[0-9A-Fa-f]";
my $dd = "$d$d";


print header;
print start_html(-title => "Cisco APVT",
				 -script=> [{	-type 	=> 'text/javascript',
				 				-src	=> '/javascript/apvt.js'	
				 			}]);
my @fields = param;
if (@fields ==0) {
	print <<EndHTML;
	<h2>Csico AP Validation Tool</h2>
	
	<h3>This is a demo version, interal user only</h3>
	
	<p> Please Click the 'start' button to start the Validation </p>
	
EndHTML
	
	print start_form(-method=>'POST', -action=>"http://$host/cgi-bin/$script_name"), hidden('client_ip', $client_ip),
		"<br>", submit(-name=>'sub_form', -value=>'Start Validation'), end_form, hr;

} elsif (param('client_ip')) {
	my $client_ip = param('client_ip');

	my ($client_mac_dec, $ap_mac_hex, $ap_rf_hex, $ap_slot_id, $ap_ip, $client_ch, $p_wlc, $s_wlc, $location) = `$perl searchClient.pl $client_ip`;
	
	print <<EndHTML;
	<h2> Basic Informarion </h2>
	<h3> AP MAC Address 					: $ap_mac_hex </h3>
	<h3> AP IP Address  					: $ap_ip </h3>
	<h3> AP Channel 						: $client_ch </h3>
	<h3> AP Primary Controller Address 		: $p_wlc </h3>
	<h3> AP Secondary Controller Address	: $s_wlc </h3>
	<h3> AP Location 						: $location </h3>
	
EndHTML
	print start_form(-method=>'POST', -action=>"http://$host/cgi-bin/$script_name"), hidden('ap_mac_hex', $ap_mac_hex), 
		hidden("client_mac_dec", $client_mac_dec), hidden('ap_rf_hex', $ap_rf_hex), textfield( -name => 'ap_id', -id => 'AP ID', -size => 17, -maxlength => 17),
		"<br>", submit(-name=>'sub_form', -value=>'Push AP Configuration'), end_form, hr;
} elsif (param('ap_id')) {
	my $client_mac_dec = param('client_mac_dec');
	my $ap_id = param('ap_id');
	my $ap_mac_hex = param('ap_mac_hex');
	my $ap_rf_hex = param('ap_rf_hex');
	my ($p_wlc, $s_wlc, $location, $err) = `$perl updateAPConfig.pl $ap_rf_hex $ap_id`; 
	print <<EndHTML;
	<h2> Updated Informarion </h2>
	<h3> Primary Controller 	: $p_wlc </h3>
	<h3> Secondary Controller  	: $s_wlc </h3>
	<h3> Location 				: $location </h3>
	<br>
	<button id="apreboot" onclick="newpage_disabe(http://$host/cgi-bin/rebootAP.cgi?ap_mac=$ap_mac_hex)">Reboot AP $ap_mac_hex</button>
	<br><br>
	<h2> Waiting til the AP is up after reboot the AP, </h2>
	<h2> Click "Validating AP Setting" button after client is associated with new SSID. </h2>

EndHTML
	print start_form(-method=>'POST', -action=>"http://$host/cgi-bin/$script_name"), hidden('ap_id', $ap_id), hidden('ap_rf_hex', $ap_rf_hex),	 
		hidden("client_mac_dec", $client_mac_dec), hidden('p_wlc', $p_wlc), "<br>", submit(-name=>'sub_form', -value=>'Validating AP Setting'), end_form, hr;
	print "<button onclick='enable()'>Reset</button>";
	
} elsif (param('p_wlc')) {
	my $crt_wlc = param('p_wlc');
	my $ap_id = param('ap_id');
	my $client_mac_dec = param('client_mac_dec');
	my ($ap_mac_hex, $ap_rf_hex, $ap_slot_id, $ap_ip, $client_ch, $p_wlc, $s_wlc, $location) = `$perl searchClient.pl $client_ip $client_mac_dec $ap_id`;
	print <<EndHTML;
	<h2> Validation Informarion </h2>
	<h3> AP MAC Address 		: $ap_mac_hex </h3>
	<h3> AP IP Address  		: $ap_ip </h3>
	<h3> Current Controller		: $crt_wlc <h3>
	<h3> Primary Controller 	: $p_wlc </h3>
	<h3> Secondary Controller  	: $s_wlc </h3>
	<h3> Location 				: $location </h3>
	<br>
	
EndHTML
	
}

print end_html;
