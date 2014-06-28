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
        $templateName = $data[1];
        last;
    }
    next;
}

if ($templateName){
    my @templates = read_file("$conf_dir/templates.csv") or die "unable to read $conf_dir/templates.csv";
    splice (@templates, 0, 1);
    foreach my $line (@templates) {
        chomp($line);
        if ($line =~ /$templateName/ ) {
            my @data = split(',', $line);
            $json = qq{{"templatename" : "$templateName", "color" : "$data[1]", "fields" : "$data[2]", "limits" : "$data[3]", "inputType" : "$data[4]"}};
            last;
        }
        next;
    }  
}else{
    $json = qq{{"error" : "$templateName"}};
}

print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;