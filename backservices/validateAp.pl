#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use FindBin;
use Log::Log4perl;
use NetSNMP::TrapReceiver;
use NetSNMP::OID;

sub my_receiver {
    require "/opt/appt/conf/appt.conf";
    use vars qw ($gatingWLC $gatingCommunity $perl $log_conf);
    Log::Log4perl::init("/opt/appt/conf/$log_conf");
    my $logger = Log::Log4perl->get_logger('appt_snmptrap');
    $logger->info("********** Trap RECEIVED A NOTIFICATION:*********");
    $logger->info("receivedfrom: $_[0]{'receivedfrom'}, community: $_[0]{'community'}");
    $logger->info("VARBINDS:");
    foreach my $x (@{$_[1]}) {
    my $oid = new NetSNMP::OID($x->[0]);
        $logger->info("name: $oid, value: $x->[1]");
    }
}

NetSNMP::TrapReceiver::register("all", &my_receiver) || 
    die "Failed to laod Sample Trap Receivern";
$logger->info("*************************************************");
