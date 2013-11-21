#!/usr/bin/perl 
use Net::Ping;

my $host="10.248.78.69";
my $p=`ping -c 5 -W 4 $host | grep -c "64 bytes"`;
print "live" if $p > 2;
print "$p\n";
`/usr/bin/perl /wMOS/collectData.pl 10.248.78.69 tH3MuCh@tRD 1.1.1.1 0.27.99.198.121.7 84.120.26.13.65.128 10.168.103.42 0 6 test &>/dev/null &`;
