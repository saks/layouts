var displayTime = 10000;
var bannerTimer = -1;
var bannerNo = 0;
var windowActive = true;

jQuery.fx.interval = 50;

function growBar() {
	jQuery("#bar").stop(true, true);
	jQuery("#bar").css("width","1px");
	jQuery("#bar").animate({
		width: '100%',
	}, displayTime, 'linear');
}

//Function to detect if a browser is a mobile browser or not.
function isMobile(){
	//So far not mobile
	mobile = false;

	//List of platforms and useragents to look for.
	platforms = new Array("Symbian OS","S60", "iPod");
	useragents = new Array("SymbOS", "SymbianOS", "Opera Mobi", "iPhone", "iPad", "iPod", "Android", "Windows Phone", "webOS");

	//Try and find them
	for(p = 0; p <= platforms.length; p++){
		if (navigator.platform == platforms[p]){
			mobile = true;
			break;
		}
	}
	if(!mobile){
		for(p = 0; p <= useragents.length; p++){
			if (navigator.userAgent.indexOf(useragents[p]) >= 0){
				mobile = true;
				break;
			}
		}
	}
	return mobile;
}

function setCookie(name,value,time) {
	if (time) {
		var date = new Date();
		date.setTime(date.getTime()+(time*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}
function getCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function changeBanner() {
	var bannerNo = jQuery("#post-ads a").size();
	var cur = parseInt(jQuery("#post-ads a.opaque").attr("id").replace("banner-", ""));
	var nex = (cur+1)%bannerNo;

	jQuery("#post-ads a").removeClass("opaque");
	jQuery("#post-ads #banner-"+nex).addClass("opaque");

	jQuery("#chooser li").removeClass("displaying");
	jQuery("#chooser .to-"+nex).addClass("displaying");

	setCookie('banner_pos', nex, 60);

	growBar();
}

function start(){
	//Check that this is not a mobile browser
	if(isMobile()){
		return false;
	}

	//Set the window to active
	windowActive = true;

	//Get number of banners
	bannerNo = jQuery("#post-ads a").size();

	//Reset the interval
	clearInterval(bannerTimer);
	bannerTimer = setInterval (changeBanner, displayTime );
	//console.log("Interval id = " + bannerTimer);

	//Expand the bar
	growBar();

	//Get current banner
	var cur = getCookie('banner_pos');

	//Check the banner in the cookie exists
	if(!(document.getElementById("banner-"+cur) != null)){
		cur = 0;
		setCookie('banner_pos', 0, 60);
	}

	//Check the chosen banner is ok, if this fails we basically have no banners
	if(document.getElementById("banner-"+cur) != null){
		//Hide all of the banners, and just show the current one.
		jQuery("#post-ads a").removeClass("opaque");
		jQuery("#post-ads #banner-"+cur).addClass("opaque");

		jQuery("#chooser li").removeClass("displaying");
		jQuery("#chooser .to-"+cur).addClass("displaying");
	}

	growBar();
}

function time(){
	var curtime = new Date();
	var h = curtime.getHours();
	var m = curtime.getMinutes();
	var s = curtime.getSeconds();
	return '' + h + ':' + m + ':' + s;
}

function stop(){
	windowActive = false;
	clearInterval(bannerTimer);
	//console.log("Stoppening interval " + bannerTimer);
	jQuery("#bar").stop(true, true);
	jQuery("#bar").css("width","0px");
}

jQuery("#post-ads").ready(function() {
	start();
});

jQuery(document).ready(function() {
  if (jQuery('ul.xoxo').size() == 0) return;

	//Start
	start();

	//Only run when window has focus.
	//jQuery(window).focus(function() { console.log("GAINED FOCUS: " + time()); start(); });
	//jQuery(window).blur(function() { console.log("LOST FOCUS: " + time()); stop(bannerTimer); });
	jQuery(window).focus(function() { start(); });
	jQuery(window).blur(function() { stop(bannerTimer); });

	//When a banner is clicked
	jQuery("#controls li").click(function() {

		//If the window is active
		if(windowActive){
			//Hide all banners
			jQuery("#post-ads a").removeClass("opaque");
			jQuery("#chooser li").removeClass("displaying");

			//Get the one clicked
			var imageToShow = parseInt(jQuery(this).attr("class").replace("to-", ""));

	 		if ( jQuery(this).attr("id") ) { var adjust = parseInt(jQuery(this).attr("id").replace("a", "")); }
	 		else { var test = null; }

	 		jQuery("#adjuster li").attr("class",function() {
	 			if ( !test ) { adjust = parseInt(jQuery(this).attr("id").replace("a", "")); to = imageToShow; }
	 			else { var to = parseInt(jQuery(this).attr("class").replace("to-", "")); }
	 			return "to-"+((to+adjust)%bannerNo);
	 		});

			//Show this banner
			jQuery("#post-ads #banner-"+imageToShow).addClass("opaque");
			jQuery("#chooser .to-"+imageToShow).addClass("displaying");

			//Set the cookie
			setCookie('banner_pos', imageToShow, 60);
		}
	});

	//When a banner is hovered over
	jQuery("#post-ads").hover(
		function() {
			if(windowActive){
				clearInterval(bannerTimer);
				jQuery("#bar").stop(true, true);
				jQuery("#bar").css("width","0px");
			}
		},
		function() {
			if(windowActive){
				clearInterval(bannerTimer);
				bannerTimer = setInterval(changeBanner, displayTime);
				growBar();
			}
		}
	);
});

