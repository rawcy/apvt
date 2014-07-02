#!/usr/bin/perl

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Jun 17 2014               ##
##  Project:      apvt                      ##
##############################################

use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use CGI::Cookie;
use CGI::Session;
use strict;
use FileHandle;
use CGI::Carp 'fatalsToBrowser';
use Cwd;
use File::Slurp;
use FindBin;
use Time::HiRes qw( time );
require "$FindBin::Bin/conf/apptweb.conf";
require "$FindBin::Bin/lib/common.pl";
use vars qw ($perl $updateApconfig $searchAp $fetchPreset $getApGroupList $joinApGroup $login $rebootAp $getTemplate $getProperty $provisionSubmitation);


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

my $username = CGI->cookie('username') || '';
CGI::Session->name("appt");
my $session = new CGI::Session(undef, undef, {Directory=>'$log_path'}) or die CGI::Session->errstr;
print $session->header();

print start_html(-title => "Cisco APPT",
                 -script=> [{   -type   => 'text/javascript',
                                -src    => '/cgi-bin/appt/javascript/appt.js'    
                            },
                            {   -type   => 'text/javascript',
                                -src    => '/cgi-bin/appt/javascript/jquery.jeditable.js'
                            },
                            {   -type   => 'text/javascript',
                                -src    => '/cgi-bin/appt/javascript/jquery-1.10.2.min.js'
                            }],
                 -style=>{-src=>['/cgi-bin/appt/css/appt.css']});
require "header.cgi";

if(!$username){
    print <<EndHTML;
    <div class="content_inner_section">
    <center><h2>Cisco AP Validation Tool</h2>
    
    <h3>This is a demo version - Interal use only</h3></center>
    
EndHTML
    # printf "This sessin is: %s\n", $session->is_new ? 'NEW': 'old';
    
    # print "username: $username";
    # $session->param('client_ip' => $client_ip);
    print "<div id='loginResult' style='display:none;'> </div>";
    print start_form(-id => 'loginForm', -method=>'POST', -action=>"http://$host/cgi-bin/$script_name", -onSubmit=>"javascript:return login('/cgi-bin/$login', '$client_ip')"), "<br>",
        "<fieldset> <legend>Login</legend>  
        <div id='username'> <p> <label for='username'>Username</label> </p> </div> <p>", 
        textfield( -name => 'userid', -id => 'userid', -size => 20, -maxlength => 20), "</p>",
        "<p>", submit(-name=>'sub_form', -value=>'Login'), "</p>", "</fieldset>", end_form, "</div>";
} else {
   
    my $ap_mac;
    my $search_ap = "$perl $searchAp $client_ip";
    if (param('ap_mac') ne "FF:FF:FF:FF:FF:FF") {
        $ap_mac = param('ap_mac');
        $session->param('ap_mac' => $ap_mac);
        my $ap_mac_dec = mac_hex_decimal(param('ap_mac'));
        $search_ap .= " $ap_mac_dec";
    }
    my $result = `$search_ap`;
    my ($error, $result_data) = split(";", $result, 2);
    print "<div class=\"loginbar\"><div class=\"logout light\" onclick=\"logout('http://$host/cgi-bin/$script_name');\">logout: $username</div></div>";

    if ($error) {
        print <<EndHTML;
        <div class="content_inner_section">
            <fieldset>
                <div class='error'>
                    <p>Please check if connect to the correct ESSID</p>
                    <p>or enter the AP MAC below</p>  
EndHTML
        if (param('ap_mac') ne "FF:FF:FF:FF:FF:FF" && param('ap_mac')){
            print "<p> $error </p>";
        } 
        print "</div>";
        print start_form(-id => 'loginForm', -method=>'POST', -action=>"http://$host/cgi-bin/$script_name", -onSubmit=>"javascript:return checkMACAddress();"), "<br>", 
        "<div id='mac_div'> <p> <label for='mac'>AP Mac Address</label> </p> </div> <p>", "<div id='macErrorMsg' style='display:none;'> </div>", "<div id='macExample' style='display:none;'> </div>",
        textfield( -name => 'ap_mac', -id => 'mac', -default => 'FF:FF:FF:FF:FF:FF', -size => 20, -maxlength => 17), "</p> <p>",
        
        submit(-name=>'sub_form', -value=>'Start Provisioning'), "</p>", "</fieldset>", end_form, "</div>";  
        print <<EndHTML;
                </div>
EndHTML
    } else {
        my @staging_ap_info = split(',', $result_data, 8);

        $ap_mac = param('ap_mac');
        $session->param('ap_mac' => $ap_mac);
        my $conf_dir = "$FindBin::Bin/conf";
        my %property;
        my @property_menu;
        my @lines = read_file("$conf_dir/property.csv") or die "unable to read $conf_dir/property.csv";
        splice (@lines, 0, 1);
        foreach my $line (@lines) {
            my @data = split(',', $line);
            push(@property_menu,$data[0]);
        }
        @property_menu = sort { lc($a) cmp lc($b) } @property_menu;
        print <<EndHTML;
        <script>
            \$(document).ready(function() {
                \$('#property').prop('selectedIndex', -1);
            });
        </script>
        <div class='content_inner_section'>
            <fieldset id='template_fieldset'>
EndHTML
        print "<legend id='info_header'>$staging_ap_info[1]</legend>";
        print <<EndHTML;
                <table id='template_table'>
                    <tr class='template_property'> 
                        <td> <label for='property'>Property</label> </td>
                        <td>
EndHTML
        print popup_menu( -name => 'property', -id => 'property', -value =>\@property_menu, -onchange=>"loadTemplate('/cgi-bin/$getTemplate', '/cgi-bin/$getProperty', '$staging_ap_info[1]', '$staging_ap_info[2]')");
        print <<EndHTML;
            </td>
            </tr>
            <div id='template_msg' style='display:none;'> </div>
        </table>
        <table id='comfirm_table' style='display:none;'>
                <caption> Comfirm Informarion </caption>
            <tr>
                <td></td>
                <td>Current Settings</td>
                <td>Provisioning Settings</td>
            </tr>
            <tr>
                <td>AP Name</td>
                <td>$staging_ap_info[0]</td>
                <td id='provisioning_apname'></td>
            </tr>
            <tr>
                <td>Prime Controller Name</td>
                <td>$staging_ap_info[4]</td>
                <td id='provisioning_primary_controller_name'></td>
            </tr>
            <tr>
                <td>Secondary Controller Name</td>
                <td>$staging_ap_info[5]</td>
                <td id='provisioning_secondary_controller_name'></td>
            </tr>
            <tr>
                <td>Location</td>
                <td>$staging_ap_info[6]</td>
                <td id='provisioning_location'></td>
            </tr>
            <tr>
                <td>AP Group</td>
                <td>$staging_ap_info[7]</td>
                <td id='provisioning_apgroup'></td>
            </tr>
            <tr>   
EndHTML
            print "<td><button onclick=\"submitChange('$provisionSubmitation');\">Submit</button></td>";
            print <<EndHTML
                <td></td>
                <td>
                <button onclick=\"backPrvisionForm();\">Back</button>
                </td>
            </tr>
        </table>
        <table id='validate_table' style='display:none;'>
                <caption> Validated Informarion </caption>
            <tr>
                <td></td>
                <td>Current Settings</td>
                <td>Provisioning Settings</td>
            </tr>
            <tr>
                <td>AP Name</td>
                <td id='validate_apname'></td>
                <td id='provisioning_apname'></td>
            </tr>
            <tr>
                <td>Prime Controller Name</td>
                <td id='validate_primary_controller_name'></td>
                <td id='provisioning_primary_controller_name'></td>
            </tr>
            <tr>
                <td>Secondary Controller Name</td>
                <td id='validate_secondary_controller_name'></td>
                <td id='provisioning_secondary_controller_name'></td>
            </tr>
            <tr>
                <td>Location</td>
                <td id='validate_location'></td>
                <td id='provisioning_location'></td>
            </tr>
            <tr>
                <td>AP Group</td>
                <td id='validate_apgroup'></td>
                <td id='provisioning_apgroup'></td>
            </tr>
            <tr>   
EndHTML
            print "<td><button onclick=\"submitChange('$provisionSubmitation');\">Submit</button></td>";
            print <<EndHTML
                <td></td>
                <td>
                <button onclick=\"backPrvisionForm();\">Back</button>
                </td>
            </tr>
        </table>
        </fieldset></div>
EndHTML
    }
}
require "footer.cgi";
print end_html;
