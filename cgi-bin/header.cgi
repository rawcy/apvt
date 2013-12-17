#!/usr/bin/perl

##############################################
##  Author:       Yin Chen                  ##                     
##  Contact:      yinche@cisco.com          ##
##  Data:         Nov 25 2013               ##
##  Project:      apvt                      ##
##############################################


use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;

print<<HTML;
	<div class="header">
	<table>
	<tr>
		<td width="20%"><img src="icon/header_l.jpg" width="160" height="80"/></td>
		<td width="60%">Cisco AP valiadation Tool</td>
		<td width="20%"><img src="icon/header_r.jpg" width="180" height="80"/></td>
	</tr>
	</table>
	</div>
	<hr>
HTML
