#!/usr/bin/perl
use CGI;
use File::Slurp;
use strict;
use warnings;
use FindBin;
use CGI::Session;

# read the CGI params
my $cgi = CGI->new;
my $username = $cgi->param("username");
my (%userList, $json);
my $conf_dir = "$FindBin::Bin/conf";
## connect to the database
#my $dbh = DBI->connect("DBI:mysql:database=mydb;host=localhost;port=2009",  
#  "mydbusername", "mydbpassword") 
#  or die $DBI::errstr;


# check the username and password in the database
#my $statement = qq{SELECT id FROM users WHERE username=? and password=?};
#my $sth = $dbh->prepare($statement)
#  or die $dbh->errstr;
#$sth->execute($username, $password)
#  or die $sth->errstr;
#my ($userID) = $sth->fetchrow_array;
my @lines = read_file("$conf_dir/ual.csv") or die "unable to read $conf_dir/ual.csv";
my $heading=1;
foreach my $line (@lines) {
	chomp($line);
	if ($heading == 1){
		$heading++;
		next;
	}
	$userList{$line}=1;
}

if(exists $userList{$username}){
	$json = qq{{"success" : "login is successful", "userid" : "$username"}};
}else{
	$json = qq{{"error" : "username was wrong"}};
}

# create a JSON string according to the database result
#my $json = ($userID) ? 
#  qq{{"success" : "login is successful", "userid" : "$userID"}} : 
#  qq{{"error" : "username or password is wrong"}};

# return JSON string
print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;