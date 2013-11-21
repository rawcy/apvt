//////////////////////////////////////////////
//  Author:       Yin Chen                  //                     
//  Contact:      yinche@cisco.com          //
//  Data:         May 9 2013                //
//  Project:      wMOS                      //
//////////////////////////////////////////////

function pageload() {
	alert('Hit OK, and then wait for the page to be loaded.');
}

function checkMACAddress() {
	var macAddress=document.getElementById('mac').value;
	var macAddressRegExp1=/^(?:[0-9A-F]{2}([-:]))(?:[0-9A-F]{2}\1){4}[0-9A-F]{2}$/i;
	var macAddressRegExp2=/^([0-9A-F]{4}[.]){2}[0-9A-F]{4}$/i;
	var invalidMAC=/^([0|F]{2}:){5}[0|F]{2}$/i;

	if (invalidMAC.test(macAddress) == true) {
		alert("please enter a nonvalid mac address\nexample XX:XX:XX:XX:XX:XX\nX = 0-9,A-F,a-f");
		return false;
	}	
	if(!(macAddress.length==17 || macAddress.length==14)) {
		alert('Mac Address is not the proper length.');
		return false;
	}

	if (macAddressRegExp1.test(macAddress)==false && macAddressRegExp2.test(macAddress)==false) { //if match failed
		alert("Please enter a valid MAC Address.");
		return false;
	}
	
	
	pageload();
	return true;
}

function disable(){
	document.getElementById("videolist").disabled=true;
}
function enable(){
	document.getElementById("videolist").disabled=false;
}



