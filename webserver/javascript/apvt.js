//////////////////////////////////////////////
//  Author:       Yin Chen                  //                     
//  Contact:      yinche@cisco.com          //
//  Data:         Dec 13 2013                //
//  Project:      apvt                      //
//////////////////////////////////////////////

function pageload() {
	alert('Hit OK, and then wait for the page to be loaded.');
}


function newpage(link)
{
	window.open(link);
	disable();
}

function updateSync(val, tag){
    var elem = document.getElementById(tag);
    elem.value = val; 
}

function checkMACAddress() {
	var macAddress=document.getElementById('mac').value;
	var macAddressRegExp1=/^(?:[0-9A-F]{2}([-:]))(?:[0-9A-F]{2}\1){4}[0-9A-F]{2}$/i;
	var macAddressRegExp2=/^([0-9A-F]{4}[.]){2}[0-9A-F]{4}$/i;
	var invalidMAC=/^([0|F]{2}:){5}[0|F]{2}$/i;
	
	var checked = 1;
	if (macAddress == "FF:FF:FF:FF:FF:FF"){
		return true;
	}
	
	if (invalidMAC.test(macAddress) == true) {
        $('div#loginResult').text("please enter a nonvalid mac address\nexample XX:XX:XX:XX:XX:XX\nX = 0-9,A-F,a-f");
        checked = 0;
	}	
	if(!(macAddress.length==17 || macAddress.length==14) && checked == 1) {
        $('div#loginResult').text("Mac Address is not the proper length.");
        checked = 0;
	}

	if (macAddressRegExp1.test(macAddress)==false && macAddressRegExp2.test(macAddress)==false && checked == 1) { //if match failed
        $('div#loginResult').text("Please enter a valid MAC Address.");
        checked = 0;
	}
	
	if (checked == 0){
		$('div#loginResult').addClass("error");
        $('div#loginResult').fadeIn();
        $('div#mac_div').addClass("clr_red");
        document.getElementById('mac').classList.add('clr_red');
        return false;
	}
	
	$('div#loginResult').addClass("success");
	return true;
}

function checkPreset () {
	var preset=document.getElementById('preset_id').value;
	if (preset==null || preset==""){
		$('div#loginResult').text("Please enter a preset.");
		$('div#loginResult').addClass("error");
        $('div#loginResult').fadeIn();
        $('div#preset').addClass("clr_red");
        document.getElementById('preset_id').classList.add('clr_red');
		return false;
	}
	return true;
}

function disable(){
	document.getElementById("apreboot").disabled=true;
}

function enable(){
	document.getElementById("apreboot").disabled=false;
}

function login_reset() {
    document.getElementById('userid').classList.remove('clr_red');
    $('div#loginResult').removeClass("error");
    $('div#username').removeClass("clr_red");
    $('div#loginResult').text("");
    $('div#loginResult').fadeOut();
    $('div#mac_div').removeClass("clr_red");   
    document.getElementById('mac').classList.remove('clr_red');
}

function login() { // loginForm is submitted
    var username = document.getElementById('userid').value; // get username
    var results = false;
    login_reset();
    if (username) { // values are not empty
      $.ajax({
        type: "GET",
        url: "/cgi-bin/login.pl", // URL of the Perl script
        contentType: "application/json; charset=utf-8",
        async: false,
        dataType: "json",
        // send username and password as parameters to the Perl script
        data: "username=" + username,
        // script call was *not* successful
        error: function(XMLHttpRequest, textStatus, errorThrown) { 
          $('div#loginResult').text("responseText: " + XMLHttpRequest.responseText 
            + ", textStatus: " + textStatus 
            + ", errorThrown: " + errorThrown);
          $('div#loginResult').addClass("error");
        }, // error 
        // script call was successful 
        // data contains the JSON values returned by the Perl script 
        success: function(data){
          if (data.error) { // script returned error
            $('div#loginResult').text("Error: " + data.error);
            $('div#loginResult').addClass("error");
            $('div#username').addClass("clr_red");
            document.getElementById('userid').classList.add('clr_red');
          } // if
          else { // login was successful
            results = true;
            //return checkMACAddress();
          } //else
        } // success
      }); // ajax
    } // if
    else {
      $('div#loginResult').text("enter username");
      $('div#loginResult').addClass("error");
      $('div#username').addClass("clr_red");
      document.getElementById('userid').classList.add('clr_red');
    } // else
       //alert("test a " + results);
    $('div#loginResult').fadeIn();
    return results;
};