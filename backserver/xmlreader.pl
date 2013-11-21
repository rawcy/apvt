#!/usr/bin/perl -w 
use FindBin;
use lib "$FindBin::Bin/lib";
use Data::Dumper;
use XML::Simple;

require "$FindBin::Bin/conf/wMOS.conf";

use vars qw (%wlc_grp);

print Dumper(%wlc_grp);
