#!/usr/bin/perl

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Oct 24 2012               ##
##  Project:      wMOS                      ##
##############################################

package OIDS;
use strict;
use warnings;
use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw($cLApPrimaryControllerAddress $cLApSecondaryControllerAddress $bsnAPLocation $bsnAPReset $cLApIfMacAddress $bsnAPGroupVlanName $bsnAPGroupsVlanName $bsnAPPrimaryMwarName $bsnAPSecondaryMwarName
				$bsnAPEntry $bsnAPOperationStatus $bsnAPName $bsnMobileStationMacAddress $bsnAPEthernetMacAddress $bsnAPDot3MacAddress
				$OID_sysUpTime $OID_agentCurrentCPUUtilization $OID_agentFreeMemory $OID_bsnAPStatsTimer $OID_cisco_product
				$OID_bsnAPNumOfSlot $OID_grp_bsnMobileStationIpAddress $OID_grp_bsnMobileStationAPIfSlotId
				$OID_grp_bsnMobileStationAPMacAddr  $OID_grp_bsnApIpAddress $OID_grp_bsnMobileStationStatus $OID_grp_bsnMobileStationStatsEntry
				$OID_grp_bsnAPIfLoadParametersEntry $OID_grp_bsnAPIfLoadParametersEntry $OID_grp_bsnAPIfChannelInterferenceInfoEntry
				$OID_grp_bsnAPIfPhyChannelNumber $OID_grp_bsnAPIfChannelNoiseInfoEntry %Numeric_Oid_arr %interested_oid);

# FOR APVT

our $cLApPrimaryControllerAddress ='.1.3.6.1.4.1.9.9.513.1.1.1.1.11';
our $cLApSecondaryControllerAddress = '.1.3.6.1.4.1.9.9.513.1.1.1.1.13';
our $bsnAPPrimaryMwarName = '.1.3.6.1.4.1.14179.2.2.1.1.10';
our $bsnAPSecondaryMwarName = '.1.3.6.1.4.1.14179.2.2.1.1.23';
our $bsnAPGroupsVlanName = '.1.3.6.1.4.1.14179.2.10.2.1.1';
our $bsnAPEntry = '.1.3.6.1.4.1.14179.2.2.1.1';
our $bsnAPDot3MacAddress = '.1.3.6.1.4.1.14179.2.2.1.1.1';
our $bsnAPName = '.1.3.6.1.4.1.14179.2.2.1.1.3';
our $bsnAPLocation = '.1.3.6.1.4.1.14179.2.2.1.1.4';
our $bsnAPOperationStatus = '.1.3.6.1.4.1.14179.2.2.1.1.6';
our $bsnAPReset = '.1.3.6.1.4.1.14179.2.2.1.1.11';
our $bsnAPGroupVlanName = '.1.3.6.1.4.1.14179.2.2.1.1.30';
our $bsnAPEthernetMacAddress  = '.1.3.6.1.4.1.14179.2.2.1.1.33';
our $cLApIfMacAddress = '.1.3.6.1.4.1.9.9.513.1.1.1.1.2';
our $bsnMobileStationMacAddress = '.1.3.6.1.4.1.14179.2.1.4.1.1';
# interested MIBs Infomation
our $OID_sysUpTime = '.1.3.6.1.2.1.1.3.0';
our $OID_agentCurrentCPUUtilization ='.1.3.6.1.4.1.14179.1.1.5.1.0';
our $OID_agentFreeMemory = '.1.3.6.1.4.1.14179.1.1.5.3.0';
our $OID_bsnAPStatsTimer = '.1.3.6.1.4.1.14179.2.2.1.1.12';

our $OID_cisco_product = '.1.3.6.1.4.1.9.1.1279';
our $OID_bsnAPNumOfSlot = '.1.3.6.1.4.1.14179.2.2.1.1.2';
our $OID_grp_bsnMobileStationIpAddress = '.1.3.6.1.4.1.14179.2.1.4.1.2';
our $OID_grp_bsnMobileStationAPIfSlotId = '.1.3.6.1.4.1.14179.2.1.4.1.5';
our $OID_grp_bsnMobileStationAPMacAddr = '.1.3.6.1.4.1.14179.2.1.4.1.4';
our $OID_grp_bsnApIpAddress = '.1.3.6.1.4.1.14179.2.2.1.1.19';
our $OID_grp_bsnMobileStationStatus = '.1.3.6.1.4.1.14179.2.1.4.1.9';
our $OID_grp_bsnMobileStationStatsEntry = '.1.3.6.1.4.1.14179.2.1.6.1';
our $OID_grp_bsnAPIfLoadParametersEntry = '.1.3.6.1.4.1.14179.2.2.13.1';
our $OID_grp_bsnAPIfChannelInterferenceInfoEntry = '.1.3.6.1.4.1.14179.2.2.14.1';
our $OID_grp_bsnAPIfPhyChannelNumber = '.1.3.6.1.4.1.14179.2.2.2.1.4';
our $OID_grp_bsnAPIfChannelNoiseInfoEntry = '.1.3.6.1.4.1.14179.2.2.15.1';

