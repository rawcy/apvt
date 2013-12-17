function edit() { // loginForm is submitted
    var username = document.getElementById('userid').value; // get username
    alert("login loaded " + username);
    
    
    if (username) { // values are not empty
    	alert("test1 " + username);
      $.ajax({
        type: "GET",
        url: "/cgi-bin/login.pl", // URL of the Perl script
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        // send username and password as parameters to the Perl script
        data: "username=" + username,
        // script call was *not* successful
        error: function(XMLHttpRequest, textStatus, errorThrown) { 
          $('div#loginResult').text("responseText: " + XMLHttpRequest.responseText 
            + ", textStatus: " + textStatus 
            + ", errorThrown: " + errorThrown);
          $('div#loginResult').addClass("error");
          return false;
        }, // error 
        // script call was successful 
        // data contains the JSON values returned by the Perl script 
        success: function(data){
          if (data.error) { // script returned error
            $('div#loginResult').text("Error: " + data.error);
            $('div#loginResult').addClass("error");
            return false;
          } // if
          else { // login was successful
            return checkMACAddress();
          } //else
        } // success
      }); // ajax
    } else {
      $('div#loginResult').text("enter username");
      $('div#loginResult').addClass("error");
      return false;
    } // else
    $('div#loginResult').fadeIn();
    return false;

};