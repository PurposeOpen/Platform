/*
 * MyFonts Webfont Build ID 741383, 2011-04-04T00:56:43-0400
 * 
 * The fonts listed in this notice are subject to the End User License
 * Agreement(s) entered into by the website owner. All other parties are 
 * explicitly restricted from using the Licensed Webfonts(s).
 * 
 * You may obtain a valid license at the URLs below.
 * 
 * Webfont: Swiss 721 Condensed
 * URL: http://new.myfonts.com/fonts/bitstream/swiss-721/condensed/
 * Foundry: Bitstream
 * Copyright: Copyright 1990-2003 Bitstream Inc. All rights reserved.
 * License: http://www.myfonts.com/viewlicense?1056
 * Licensed pageviews: 1,000,000/month
 * CSS font-family: Swiss721BT-RomanCondensed
 * CSS font-weight: normal
 * 
 * Webfont: Swiss 721 Bold Condensed
 * URL: http://new.myfonts.com/fonts/bitstream/swiss-721/bold-condensed/
 * Foundry: Bitstream
 * Copyright: Copyright 1990-2003 Bitstream Inc. All rights reserved.
 * License: http://www.myfonts.com/viewlicense?1056
 * Licensed pageviews: 1,000,000/month
 * CSS font-family: Swiss721BT-BoldCondensed
 * CSS font-weight: normal
 * 
 * Webfont: Swiss 721 Condensed Italic
 * URL: http://new.myfonts.com/fonts/bitstream/swiss-721/condensed-italic/
 * Foundry: Bitstream
 * Copyright: Copyright 1990-2003 Bitstream Inc. All rights reserved.
 * License: http://www.myfonts.com/viewlicense?1056
 * Licensed pageviews: 1,000,000/month
 * CSS font-family: Swiss721BT-ItalicCondensed
 * CSS font-weight: normal
 * 
 * Webfont: Swiss 721 Condensed Bold Italic
 * URL: http://new.myfonts.com/fonts/bitstream/swiss-721/condensed-bold-italic/
 * Foundry: Bitstream
 * Copyright: Copyright 1990-2003 Bitstream Inc. All rights reserved.
 * License: http://www.myfonts.com/viewlicense?1056
 * Licensed pageviews: 1,000,000/month
 * CSS font-family: Swiss721BT-BoldCondensedItalic
 * CSS font-weight: normal
 * 
 * (c) 2011 Bitstream, Inc
*/



// safari 3.1: data-css
// firefox 3.6+: woff
// firefox 3.5+: data-css
// chrome 4+: data-css
// chrome 6+: woff
// IE 5+: eot
// IE 9: woff
// opera 10.1+: data-css
// mobile safari: svg/data-css
// android: data-css

var browserName, browserVersion, webfontType,  webfontTypeOverride;
 
if (typeof(customPath) == 'undefined')
	var customPath = false;


if (typeof(woffEnabled) == 'undefined')
	var woffEnabled = true;


if (/myfonts_test=on/.test(window.location.search))
	var myfonts_webfont_test = true;

else if (typeof(myfonts_webfont_test) == 'undefined')
	var myfonts_webfont_test = false;


if (customPath)
	var path = customPath;

else {
	var scripts = document.getElementsByTagName("SCRIPT");
	var script = scripts[scripts.length-1].src;

	if (!script.match("://") && script.charAt(0) != '/')
		script = "./"+script;
		
	var path = script.replace(/\\/g,'/').replace(/\/[^\/]*\/?$/, '');
}


if (myfonts_webfont_test)
	document.write('<script type="text/javascript" src="' +path+ '/MyFontsWebfontsOrderM2838654_test.js"></script>');


if (/webfont=(woff|ttf|eot)/.test(window.location.search))
{
	webfontTypeOverride = RegExp.$1;

	if (webfontTypeOverride == 'ttf')
		webfontTypeOverride = 'data-css';
}


if (/MSIE (\d+\.\d+)/.test(navigator.userAgent))
{
	browserName = 'MSIE';
	browserVersion = new Number(RegExp.$1);
	if (browserVersion >= 9.0 && woffEnabled)
		webfontType = 'woff';
	else if (browserVersion >= 5.0)
		webfontType = 'eot';
}
else if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent))
{
	browserName = 'Firefox';
	browserVersion = new Number(RegExp.$1);
	if (browserVersion >= 3.6 && woffEnabled)
		webfontType = 'woff';
	else if (browserVersion >= 3.5)
		webfontType = 'data-css';
}
else if (/Chrome\/(\d+\.\d+)/.test(navigator.userAgent)) // must check before safari
{
	browserName = 'Chrome';
	browserVersion = new Number(RegExp.$1);

	if (browserVersion >= 6.0 && woffEnabled)
		webfontType = 'woff';

	else if (browserVersion >= 4.0)
		webfontType = 'data-css';
}
else if (/Mozilla.*(iPhone|iPad).* OS (\d+)_(\d+).* AppleWebKit.*Safari/.test(navigator.userAgent))
{
		browserName = 'MobileSafari';
		browserVersion = new Number(RegExp.$2) + (new Number(RegExp.$3) / 10)

	if(browserVersion >= 4.2)
		webfontType = 'data-css';

	else
		webfontType = 'svg';
}
else if (/Mozilla.*(iPhone|iPad|BlackBerry).*AppleWebKit.*Safari/.test(navigator.userAgent))
{
	browserName = 'MobileSafari';
	webfontType = 'svg';
}
else if (/Safari\/(\d+\.\d+)/.test(navigator.userAgent))
{
	browserName = 'Safari';
	if (/Version\/(\d+\.\d+)/.test(navigator.userAgent))
	{
		browserVersion = new Number(RegExp.$1);
		if (browserVersion >= 3.1)
			webfontType = 'data-css';
	}
}
else if (/Opera\/(\d+\.\d+)/.test(navigator.userAgent))
{
	browserName = 'Opera';
	if (/Version\/(\d+\.\d+)/.test(navigator.userAgent))
	{
		browserVersion = new Number(RegExp.$1);
		if (browserVersion >= 10.1)
			webfontType = 'data-css';
	}
}


if (webfontTypeOverride)
	webfontType = webfontTypeOverride;

switch (webfontType)
{
		case 'eot':
		document.write("<style>\n");
				document.write("@font-face {font-family:\"Swiss721BT-RomanCondensed\";src:url(\"" + path + "/webfonts/eot/c9be09373812c72d893c22d946c20ea3.eot\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-BoldCondensed\";src:url(\"" + path + "/webfonts/eot/55bc78797622817819d7dba36281945b.eot\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-ItalicCondensed\";src:url(\"" + path + "/webfonts/eot/da386a08ef5d8c521a1736cbf9bf1d87.eot\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-BoldCondensedItalic\";src:url(\"" + path + "/webfonts/eot/c7f61f98b04d3312bbbacbb53d9b892c.eot\");}\n");
				document.write("</style>");
		break;
		
		case 'woff':
		document.write("<style>\n");
				document.write("@font-face {font-family:\"Swiss721BT-RomanCondensed\";src:url(\"" + path + "/webfonts/woff/c9be09373812c72d893c22d946c20ea3.woff\") format(\"woff\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-BoldCondensed\";src:url(\"" + path + "/webfonts/woff/55bc78797622817819d7dba36281945b.woff\") format(\"woff\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-ItalicCondensed\";src:url(\"" + path + "/webfonts/woff/da386a08ef5d8c521a1736cbf9bf1d87.woff\") format(\"woff\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-BoldCondensedItalic\";src:url(\"" + path + "/webfonts/woff/c7f61f98b04d3312bbbacbb53d9b892c.woff\") format(\"woff\");}\n");
				document.write("</style>");
		break;
	
		case 'data-css':
		//document.write("<link rel='stylesheet' type='text/css' href='" + path + "/webfonts/datacss/eef71022c96a9c1721e0c0623ec70f9d.css'>");
		break;
	
		case 'svg':
		document.write("<style>\n");
				document.write("@font-face {font-family:\"Swiss721BT-RomanCondensed\";src:url(\"" + path + "/webfonts/svg/c9be09373812c72d893c22d946c20ea3.svg#Swiss721BT-RomanCondensed\") format(\"svg\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-BoldCondensed\";src:url(\"" + path + "/webfonts/svg/55bc78797622817819d7dba36281945b.svg#Swiss721BT-BoldCondensed\") format(\"svg\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-ItalicCondensed\";src:url(\"" + path + "/webfonts/svg/da386a08ef5d8c521a1736cbf9bf1d87.svg#Swiss721BT-ItalicCondensed\") format(\"svg\");}\n");
				document.write("@font-face {font-family:\"Swiss721BT-BoldCondensedItalic\";src:url(\"" + path + "/webfonts/svg/c7f61f98b04d3312bbbacbb53d9b892c.svg#Swiss721BT-BoldCondensedItalic\") format(\"svg\");}\n");
				document.write("</style>");
		break;
		
	default:
		break;
}