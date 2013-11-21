
# Common SNMP related procedures

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Oct 24 2012               ##
##  Project:      wMOS                      ##
##############################################

use Net::SNMP;
#use strict;
#use warnings;
##Procedure Header
# Name: snmp_connect
# Description:
#   Call Net::SNMP->session
# Input:
#   $hostname      IP or hostname
#   $community     Community string
# Return Values:
#   $session        A reference to the Net::SNMP object
#   $error          The error string if a connection could not be established
sub snmp_connect {
    my ($hostname, $community) = @_;
	
	my $connection = `ping -c 3 -W 2 $hostname | grep -c "64 bytes"`; 
	return ("the $hostname is not reachable\n") if $connection < 1;

    my ($session, $error) = Net::SNMP->session(
                               -hostname      => $hostname,
                               -version       => "snmpv2c",
                               -community     => $community,
                               -timeout       => "2",
                            );
    if (!$session) {
        return ($error);
    }
    # Increase the size of the buffer coz some queries were failing (default 1472)
    $session->max_msg_size(1472*5);

	#Get the linux standard timestamp
    my @param_arr = ('-timeticks' => 0);
    $session->translate(\@param_arr);

    return ("", $session);
} # of snmp_connect()

##Procedure Header
# Name:
#        format_mac_decimal
# Description:
#        Converts a mac address in to a decimal number
# Input:
#        $mac: MAC address
# Output:
#      Returns a string representation of a MAC address

sub format_mac_decimal {
   my ($mac) = @_;
   $mac =~ /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/;
   return (sprintf ("%02X:%02X:%02X:%02X:%02X:%02X", $1,$2,$3,$4,$5,$6));
}

##Procedure Header
# Name:
#        format_mac_hex
# Description:
#        Converts a physical mac address in to a hexadecimal number
#        representation
# Input:
#        $mac: MAC address
# Output:
#      Returns a string representation of a MAC address
sub format_mac_hex {
   my ($mac) = @_;
   $mac = uc ($mac);
   $mac =~ m/0X(..)(..)(..)(..)(..)(..)/;
   return ("$1:$2:$3:$4:$5:$6");
}

sub mac_hex_decimal{
   my ($mac) = @_;
    
    $mac =~ /([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})/;
   return (sprintf ("%d.%d.%d.%d.%d.%d", hex($1),hex($2),hex($3),hex($4),hex($5),hex($6)));
}

1;
