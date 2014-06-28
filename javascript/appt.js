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
    return true;
    // disable();
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
    // if (macAddress == "FF:FF:FF:FF:FF:FF"){
    //  return true;
    // }
    
    if (invalidMAC.test(macAddress) == true) {
        $('div#macErrorMsg').text("please enter a nonvalid mac address,");
        $('div#macExample').text("example XX:XX:XX:XX:XX:XX, X = 0-9,A-F,a-f");
        checked = 0;
    }   
    if(!(macAddress.length==17 || macAddress.length==14) && checked == 1) {
        $('div#macErrorMsg').text("Mac Address is not the proper length.");
        checked = 0;
    }

    if (macAddressRegExp1.test(macAddress)==false && macAddressRegExp2.test(macAddress)==false && checked == 1) { //if match failed
        $('div#macErrorMsg').text("Please enter a valid MAC Address.");
        checked = 0;
    }
    
    if (checked == 0){
        // $('div#loginResult').addClass("error");
  //       $('div#loginResult').fadeIn();
        $('div#mac_div').addClass("clr_red");
        document.getElementById('mac').classList.add('clr_red');
        $('div#macErrorMsg').addClass("clr_red");
        $('div#macExample').addClass("clr_red");
        $('div#macErrorMsg').fadeIn();
        $('div#macExample').fadeIn();
        return false;
    }
    
    $('div#macErrorMsg').addClass("success");
    createCookie('ap_mac', macAddress);
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
        $('div#loginResult').fadeIn();
        return false;
    }
    return true;
}

function disable(id_t){
    document.getElementById(id_t).disabled=true;
    $('div#reboot').fadeOut();
    $('div#rebootedMsg').fadeIn();
    return true;
}

function enable(id_f){
    document.getElementById(id_f).disabled=false;
    $('div#reboot').fadeIn();
    $('div#rebootedMsg').fadeOut();
    return true;
}

function resetLogin() {
    document.getElementById('userid').classList.remove('clr_red');
    $('div#loginResult').removeClass("error");
    $('div#username').removeClass("clr_red");
    $('div#loginResult').text("");
    $('div#loginResult').fadeOut();
    // $('div#mac_div').removeClass("clr_red");   
    // document.getElementById('mac').classList.remove('clr_red');
}

function login(login_url) { // loginForm is submitted
    var username = document.getElementById('userid').value; // get username
    var results = false;
    resetLogin();
    if (username) { // values are not empty
      $.ajax({
        type: "GET",
        url: login_url, // URL of the Perl script
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
            $('div#loginResult').fadeIn();
          } // if
          else { // login was successful
            createCookie('username', username);
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
      $('div#loginResult').fadeIn();
    } // else
       //alert("test a " + results);
    
    return results;
};

function loadTemplate(template_url, property_url) { // template is submitted
    var property = document.getElementById('property').value; // get property
    $('div#template_err').removeClass("error");
    $('div#template_err').fadeOut();
    if (property) {
        $.ajax({
            type: "GET",
            url: template_url, // URL of the Perl script
            contentType: "application/json; charset=utf-8",
            async: false,
            dataType: "json",
            // send property as parameters to the Perl script
            data: "property=" + property,
            // script call was *not* successful
            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                $('div#template_err').text("responseText: " + XMLHttpRequest.responseText 
                + ", textStatus: " + textStatus 
                + ", errorThrown: " + errorThrown);
                $('div#template_err').addClass("error");
                $('div#template_err').fadeIn();
            }, // error 
            // script call was successful 
            // data contains the JSON values returned by the Perl script 
            success: function(data){
                if (data.error) { // script returned error
                    $('div#template_err').text("Error: " + data.error 
                        + "<br> Please contact Web Admin by email <a href=\"mailto:yinche\@cisco.com?Subject=APVT%20Support\" target=\"_top\">Send Mail</a><br>");
                    $('div#template_err').addClass("error");
                    $('div#template_err').fadeIn();
                } 
                else {
                    var template_fields = data.fields;
                    var fields_limits = data.limits;
                    var template_fields_array = data.fields.split(";");
                    var fields_limits_array = data.limits.split(";");
                    var input_type_array = data.inputType.split(";");
                    var template = document.getElementById('template');
                    $('.template_field').remove();
                    for (var i in template_fields_array) {
                        $('#template_table tr:last').after("<tr class='template_field'> <td> <label for='property'>" + template_fields_array[i] + "</label> </td> <td> <input class=\"template_input\" type=\"text\" name=\"" + template_fields_array[i].toLowerCase() + "_" + input_type_array[i].toLowerCase() + "\" size=\"" + fields_limits_array[i] + "\" maxlength=\"" + fields_limits_array[i] + "\" id=\"" + template_fields_array[i].toLowerCase() + "\" /> </td> </tr>");

                    }
                    $('#template_table tr:last').after("<tr class='template_field'> <td> <button action=\"action\" value=\"Back\" onclick=\"inputValidation(\'" + property_url + "');\">Next</button> </td></tr>");
                    $('#template_fieldset').css( "background-color", data.color);
              } 
            },
        });
    }
};

function inputValidation(property_url) {
    $('div#template_err').removeClass("error");
    $('div#template_err').fadeOut();
    $('.err_msg').remove();
    $(".clr_red").removeClass("clr_red");
    var provisioning_ap_name;
    var fieldList = document.querySelectorAll(".template_input");
    for (var i = 0, length = fieldList.length; i < length; i++) {
        var string_building=/^building$/;
        var string_floor=/^floor$/;
        var string_location=/^location$/;
        if (fieldList[i].name.indexOf("_d") >= 0) {
            var input_dig=/^\d+$/i;
            if (input_dig.test(fieldList[i].value)) {
                if (string_building.test(fieldList[i].name)) { }
            } else {
                $("input[name=" + fieldList[i].name + "]").addClass("clr_red");
                $('div#template_err').append("<p> <err class='err_msg'> Error: Only Digit is allowed in " + fieldList[i].id.capitalize() + "</err></p>");
                $('div#template_err').addClass("error");
                $('div#template_err').fadeIn();
            }
        } else if (fieldList[i].name.indexOf("_t") >= 0) {
            var input_text=/^[\s\S]{0,32}$/;
            if (input_text.test(fieldList[i].value)) {
                // alert(fieldList[i].name + ":" + fieldList[i].value);
            } else {
                $("input[name=" + fieldList[i].name + "]").addClass("clr_red");
                $('div#template_err').append("<p> <err class='err_msg'> Error: Char is allowed in" + fieldList[i].id.capitalize() + "</err></p>");
                $('div#template_err').addClass("error");
                $('div#template_err').fadeIn();
            }
        } 
        //alert(fieldList[i].name + ":" + fieldList[i].size);
    }
    if(!$("err").hasClass("err_msg")){
        $.ajax({
            type: "GET",
            url: property_url, // URL of the Perl script
            contentType: "application/json; charset=utf-8",
            async: false,
            dataType: "json",
            // send property as parameters to the Perl script
            data: "property=" + property,
            // script call was *not* successful
            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                $('div#template_err').text("responseText: " + XMLHttpRequest.responseText 
                + ", textStatus: " + textStatus 
                + ", errorThrown: " + errorThrown);
                $('div#template_err').addClass("error");
                $('div#template_err').fadeIn();
            }, // error 
            // script call was successful 
            // data contains the JSON values returned by the Perl script 
            success: function(data){

                if (data.error) { // script returned error
                    $('div#template_err').text("Error: " + data.error 
                        + "<br> Please contact Web Admin by email <a href=\"mailto:yinche\@cisco.com?Subject=APVT%20Support\" target=\"_top\">Send Mail</a><br>");
                    $('div#template_err').addClass("error");
                    $('div#template_err').fadeIn();
                } 
                else {
                    var provisioning_ap_name_location = "B" + document.getElementById('building').value  + "F" + document.getElementById('floor').value + document.getElementById('location').value;;
                    var provisioning_ap_name;
                    if (/^public$/.test(data.property)){
                        
                        provisioning_ap_name = data.service_code + "-" +provisioning_ap_name_location + "-" + data.division;
                    } else {
                        provisioning_ap_name = data.service_code + "-" +provisioning_ap_name_location + "-" + data.property + "-" + data.division;
                    }
                    
                    $('#provisioning-apname').text(provisioning_ap_name);
                    // $('#provisioning-primary-controller_name').text(data.primary_controller_name);
                    $('#provisioning-primary-controller-ip').text(data.primary_controller_ip);
                    // $('#provisioning-secondary-controller_name').text(data.secondary_controller_ip);
                    $('#provisioning-secondary-controller-ip').text(data.secondary_controller_ip);
                    $('#provisioning-location').text(document.getElementById('location').value);
                    $('#provisioning-apgroup').text(data.ap_group);
                }
            },
        });   
        $('#template_table').fadeOut();
        $('#comfirm_table').fadeIn();
    } 
}

function submitChange(submitchange_url) {
$.ajax({
        type: "GET",
        url: property_url, // URL of the Perl script
        contentType: "application/json; charset=utf-8",
        async: false,
        dataType: "json",
        // send property as parameters to the Perl script
        data: "provisioning-apname=" + document.getElementById('provisioning-apname') +"&provisioning-primary-controller-ip=" + document.getElementById('provisioning-primary-controller-ip') +"&provisioning-secondary-controller-ip=" + document.getElementById('provisioning-secondary-controller-ip') +"&provisioning-location=" + document.getElementById('provisioning-location').value + "&provisioning-apgroup=" + document.getElementById('provisioning-apgroup'),
        // script call was *not* successful
        error: function(XMLHttpRequest, textStatus, errorThrown) { 
            $('div#template_err').text("responseText: " + XMLHttpRequest.responseText 
            + ", textStatus: " + textStatus 
            + ", errorThrown: " + errorThrown);
            $('div#template_err').addClass("error");
            $('div#template_err').fadeIn();
        }, // error 
        // script call was successful 
        // data contains the JSON values returned by the Perl script 
        success: function(data){
            if(!data.err){
                alert("passed");
            } else {
                alert("failed");
            } 
        }
    });
}

function createCookie(name, value) {
   var date = new Date();
   date.setTime(date.getTime()+(1800*1000));
   var expires = "; expires="+date.toGMTString();
   document.cookie = name+"="+value+expires+"; path=/";
}

function removeCookie(name){
    document.cookie = name + '=; Path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
}

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}
