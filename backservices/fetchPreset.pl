#!/usr/bin/perl -w

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Nov 21 2013               ##
##  Project:      apvt                      ##
##############################################

use strict;
use warnings;
use FindBin;
use Net::IP;
use File::Slurp;
use lib "$FindBin::Bin/lib";
use OIDS;
use Data::Dumper;

require "$FindBin::Bin/lib/common_snmp.pl";
require "$FindBin::Bin/conf/apvt.conf";
use vars qw (%csv_file);

my ($preset);
if (@ARGV >= 1) {
	$preset = $ARGV[0];
} else {
	print "ERROR: no argument passed";
	exit 1;
}

print "$csv_file{$preset}{'name_prefix'},$csv_file{$preset}{'p_wlc'},$csv_file{$preset}{'s_wlc'},$csv_file{$preset}{'location'}";