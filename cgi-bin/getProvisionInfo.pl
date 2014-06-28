#!/usr/bin/perl
use CGI;
use File::Slurp;
use strict;
use warnings;
use FindBin;

# read the CGI params
my $cgi = CGI->new;
my $property = $cgi->param("property");

my ($templateName, $json);
my $conf_dir = "$FindBin::Bin/conf";
my @lines = read_file("$conf_dir/property.csv") or die "unable to read $conf_dir/property.csv";
splice (@lines, 0, 1);
foreach my $line (@lines) {
    chomp($line);
    if ($line =~ /$property/ ) {
        my @data = split(',', $line);
        $json = qq{{"property" : "$data[0]", "service_code" : "$data[2]", "division" : "$data[3]", "primary_controller_name" : "$data[4]", "primary_controller_ip" : "$data[5]", "secondary_controller_name" : "$data[6]", "secondary_controller_ip" : "$data[7]", "ap_group" : "$data[8]"}};
        last;
    }
    next;
}

print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;