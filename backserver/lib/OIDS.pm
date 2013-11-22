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
our @EXPORT = qw($cLApPrimaryControllerAddress $cLApSecondaryControllerAddress $bsnAPLocation $bsnAPReset $cLApIfMacAddress
				$OID_sysUpTime $OID_agentCurrentCPUUtilization $OID_agentFreeMemory $OID_bsnAPStatsTimer $OID_cisco_product
				$OID_bsnAPNumOfSlot $OID_grp_bsnMobileStationIpAddress $OID_grp_bsnMobileStationAPIfSlotId
				$OID_grp_bsnMobileStationAPMacAddr  $OID_grp_bsnApIpAddress $OID_grp_bsnMobileStationStatus $OID_grp_bsnMobileStationStatsEntry
				$OID_grp_bsnAPIfLoadParametersEntry $OID_grp_bsnAPIfLoadParametersEntry $OID_grp_bsnAPIfChannelInterferenceInfoEntry
				$OID_grp_bsnAPIfPhyChannelNumber $OID_grp_bsnAPIfChannelNoiseInfoEntry %Numeric_Oid_arr %interested_oid);

# FOR APVT
our $cLApPrimaryControllerAddress ='.1.3.6.1.4.1.9.9.513.1.1.1.1.11';
our $cLApSecondaryControllerAddress = '.1.3.6.1.4.1.9.9.513.1.1.1.1.13';
our $bsnAPLocation = '.1.3.6.1.4.1.14179.2.2.1.1.4';
our $bsnAPReset = '.1.3.6.1.4.1.14179.2.2.1.1.11';
our $cLApIfMacAddress = '.1.3.6.1.4.1.9.9.513.1.1.1.1.2';
# interested MIBs Infomation
our $OID_sysUpTime = '.1.3.6.1.2.1.1.3.0';
our $OID_agentCurrentCPUUtilization ='.1.3.6.1.4.1.14179.1.1.5.1.0';
our $OID_agentFreeMemory = '.1.3.6.1.4.1.14179.1.1.5.3.0';
our $OID_bsnAPStatsTimer = '.1.3.6.1.4.1.14179.2.2.1.1.12';

our $OID_cisco_product = '.1.3.6.1.4.1.9.1.1279';
our $OID_bsnAPNumOfSlot = '.1.3.6.1.4.1.14179.2.2.1.1.6';
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


our %Numeric_Oid_arr = ( 	'sysUpTime' => '.1.3.6.1.2.1.1.3.0', 
							'agentCurrentCPUUtilization' => '.1.3.6.1.4.1.14179.1.1.5.1.0',
							'agentFreeMemory' => '.1.3.6.1.4.1.14179.1.1.5.3.0');
							
our %interested_oid = (
		'bsnMobileStationStatsEntry' => {	
								'bsnMobileStationRSSI' => "$OID_grp_bsnMobileStationStatsEntry.1.client_mac_dec",
								'bsnMobileStationBytesReceived' => "$OID_grp_bsnMobileStationStatsEntry.2.client_mac_dec",
								'bsnMobileStationBytesSend' => "$OID_grp_bsnMobileStationStatsEntry.3.client_mac_dec",
								'bsnMobileStationPolicyErrors' => "$OID_grp_bsnMobileStationStatsEntry.4.client_mac_dec",
								'bsnMobileStationPacketReceived' => "$OID_grp_bsnMobileStationStatsEntry.5.client_mac_dec",
								'bsnMobileStationPacketSent' => "$OID_grp_bsnMobileStationStatsEntry.6.client_mac_dec",
								'bsnMobileStationSnr' => "$OID_grp_bsnMobileStationStatsEntry.26.client_mac_dec",
		},
		'bsnAPIfLoadParametersEntry' => {
							'bsnAPIfLoadRxUtilization' => "$OID_grp_bsnAPIfLoadParametersEntry.1.AP_mac_dec.APSlotId",
							'bsnAPIfLoadTxUtilization' => "$OID_grp_bsnAPIfLoadParametersEntry.2.AP_mac_dec.APSlotId",
							'bsnAPIfLoadChannelUtilization' => "$OID_grp_bsnAPIfLoadParametersEntry.3.AP_mac_dec.APSlotId",
							'bsnAPIfLoadNumOfClients' => "$OID_grp_bsnAPIfLoadParametersEntry.4.AP_mac_dec.APSlotId",
							'bsnAPIfLoadPoorSNRClients' => "$OID_grp_bsnAPIfLoadParametersEntry.24.AP_mac_dec.APSlotId",
		},
		'bsnAPIfLoadParametersEntry' => {
							'bsnAPIfLoadRxUtilization' => "$OID_grp_bsnAPIfLoadParametersEntry.1.AP_mac_dec.APSlotId",
							'bsnAPIfLoadTxUtilization' => "$OID_grp_bsnAPIfLoadParametersEntry.2.AP_mac_dec.APSlotId",
							'bsnAPIfLoadChannelUtilization' => "$OID_grp_bsnAPIfLoadParametersEntry.3.AP_mac_dec.APSlotId",
							'bsnAPIfLoadNumOfClients' => "$OID_grp_bsnAPIfLoadParametersEntry.4.AP_mac_dec.APSlotId",
							'bsnAPIfLoadPoorSNRClients' => "$OID_grp_bsnAPIfLoadParametersEntry.24.AP_mac_dec.APSlotId",
		},
		'bsnAPIfChannelInterferenceInfoEntry' => {
							'bsnAPIfChannelInterferencePower' => "$OID_grp_bsnAPIfChannelInterferenceInfoEntry.2.AP_mac_dec.APSlotId.client_channel",
							'bsnAPIfChannelInterferenceUtilization' => "$OID_grp_bsnAPIfChannelInterferenceInfoEntry.22.AP_mac_dec.APSlotId.client_channel",
		},
		'bsnAPIfChannelNoiseInfoEntry' => {
							'bsnAPIfChannelNoisePower' => "$OID_grp_bsnAPIfChannelNoiseInfoEntry.21.AP_mac_dec.APSlotId.client_channel",
	
		},
		'agentResourceInfoGroup' => {
							'agentCurrentCPUUtilization' => '.1.3.6.1.4.1.14179.1.1.5.1.0',
							'agentCurrentTotalMemory' => '.1.3.6.1.4.1.14179.1.1.5.2.0',
							'agentCurrentFreeMemory' => '.1.3.6.1.4.1.14179.1.1.5.3.0',
							'bsnSensorTemperature' => '.1.3.6.1.4.1.14179.2.3.1.13.0',
		},
	);