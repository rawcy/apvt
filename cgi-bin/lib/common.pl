
##############################################
##  Author:       Yin Chen                  ##
##  Contact:      yinche@cisco.com          ##
##  Data:         Dec 17 2012               ##
##  Project:      wMOS                      ##
##############################################

sub mac_hex_decimal{
    my ($mac) = @_;
    $mac =~ /([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})[\:|\-]([0-9A-Fa-f]{2})/;
    return (sprintf ("%d.%d.%d.%d.%d.%d", hex($1),hex($2),hex($3),hex($4),hex($5),hex($6)));
}
1;