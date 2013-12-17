
# Common SNMP related procedures

##############################################
##  Author:       Yin Chen                  ##
##  Contact:      yinche@cisco.com          ##
##  Data:         Oct 24 2012               ##
##  Project:      wMOS                      ##
##############################################

use Net::SNMP qw(:snmp);
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
	
	#my $connection = `ping -c 3 -W 2 $hostname | grep -c "64 bytes"`; 
	#return ("the $hostname is not reachable\n") if $connection < 1;

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


sub bulk_cb {
   my ($session, $table, $search_base, $grp_oids) = @_;
   if (!defined($session->var_bind_list)) {

      printf("ERROR: %s\n", $session->error);

   } else {

      # Loop through each of the OIDs in the response and assign
      # the key/value pairs to the anonymous hash that is passed
      # to the callback.  Make sure that we are still in the table
      # before assigning the key/values.

      my $next;

      foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
#        print $bsnAPEntry . "-" . $search_base ."\n";
         if (!oid_base_match($search_base, $oid)) {
            $next = undef;
            last;
         }
         $next = $oid;
         if ( $oid =~ /$grp_oids/ ) {
            $$table{$oid} = $session->var_bind_list->{$oid};
         }
      }

      # If $next is defined we need to send another request 
      # to get more of the table.

      if (defined($next)) {

         my $result = $session->get_bulk_request(
            -callback       => [\&bulk_cb, $table, $search_base, $grp_oids],
            -maxrepetitions => 10,
            -varbindlist    => [$next]
         );

         if (!defined($result)) {
            printf("ERROR: %s\n", $session->error);
         }

      }
   }
}

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

sub format_ip_hex {
   my ($mac) = @_;
   $mac = uc ($mac);
   $mac =~ m/0X(..)(..)(..)(..)/;
   return ("$1:$2:$3:$4");
}

sub ip_hex_decimal{
   my ($mac) = @_;
    
    $mac =~ /([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})/;
   return (sprintf ("%d.%d.%d.%d", hex($1),hex($2),hex($3),hex($4)));
}

sub ip_dec_hex {
    my ($ip) = @_;
    my ($a, $b, $c, $d)=($ip=~/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/);
    return (sprintf ("%#.2x%.2x%.2x%.2x", $a,$b,$c,$d));
}
1;
