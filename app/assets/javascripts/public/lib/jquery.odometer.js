/*
 * JQuery Odometer
 * Based on jOdometer by Jesus Carrera <jesus.carrera@trafficbroker.co.uk>
 * Improved graphics and jquery binding hooks by Stefano Mazzocchi <stefano@metaweb.com>
 */

/*
* jOdometer (1.0) // 2008.03.17 // <http://plugins.jquery.com/project/jOdometer>
*
* REQUIRES jQuery 1.2.3+ <http://jquery.com/>
*
* Copyright (c) 2008 TrafficBroker <http://www.trafficbroker.co.uk>
* Licensed under GPL and MIT licenses
*
* jOdometer is a counter that works like an odometer: moving the numbers up like a wheel
*
* Usually we will need a "position: relative" and an "overflow: hidden" in the container element.
*
* Sample Configuration:
* $('.counter').jOdometer({increment: 3.17, counterStart:'0087.15', counterEnd:'0159.50', numbersImage: '/images/numbers.png', spaceNumbers: 2, offsetRight:5});
*
* Config Options:
* counterStart: Number we are starting with. To get a specific number of digits/decimals it have to be a string (e.g. '0005.50') // Default: '0000.00'
* counterEnd: The counter stop when reach this number. If it is the same as counterStart the odometer is static. False to don't stop never. // Default: false
* delayTime: Delay between each number change // Default: 1000
* increment: Number increment after each delayTime // Default: 0.01
* speed: Speed for the change number animation // Default: 500
* easing: Easing for the change number animation. Other than 'swing' or 'linear' must be provided by plugin // Default: 'swing'
* numbersImage: Image used for the numbers. You can use .psd provided // Default: '/images/numbers.png'
* heightNumber: The height that each number needs // Default: 31
* widthNumber: Width of the numbers' image // Default: 14
* offsetRight: Distance to the right // Default: 0
* spaceNumbers: Separation between the numbers' columns // Default: 0
* widthDot: Decimal dot's special width // Default: 10
*
* We can override the defaults with:
* $.fn.jOdometer.defaults.spaceNumbers = 1;
*
* @param  settings  An object with configuration options
* @author    Jesus Carrera <jesus.carrera@trafficbroker.co.uk>
*/

(function($) {

$.fn.odometer = function(settings) {

    settings = $.extend({}, $.fn.odometer.defaults, settings);

    return this.each(function(){

        var $this = $(this); // store the actual counter

        var zeroSet = -settings.heightNumber; // position of the first 0
        var counter = parseFloat(settings.counterStart); // initialize counter with the start number

        // to store the digits of the number
        var integersArray = [];
        var decimalsArray = [];
        var digits = String(settings.counterStart).split('.'); // separate integers and decimals
        var numberOfDecimals = 0;
        var widthDot = 0;

        var width = settings.counterStart.length * settings.widthNumber + "px";
        var height = settings.heightNumber + "px";

        $this.css({
           "position"            : "relative",
           "overflow"            : "hidden",
           "width"               : width,
           "height"              : height,
           "background-image"    : "url('" + settings.backgroundImage + "')",
           "background-position" : "top right"
        });

        // if has decimals
        if (digits[1]) {
            // create a column for each decimal digit with the image in the position of the correspondent number
            var j = 0;
            for (var i = digits[1].length - 1; i > -1; i--) {
                decimalsArray[i] = digits[1].charAt(i);
                $this.append('<img style="position:absolute; right:'+( j*settings.widthNumber + settings.offsetRight + j*settings.spaceNumbers )+'px; top:'+ ((parseInt(decimalsArray[i]) *settings.heightNumber*-1)+zeroSet)+'px;" class="jodometer_decimal_'+i+'" src="'+settings.numbersImage+'" alt="Decimal '+(i+1)+'" />');
                j++;
            }
            // add the dot
            $this.append('<div style="position:absolute; width:'+settings.widthDot+'px; height:'+settings.heightNumber+'px; background:url('+settings.numbersImage+') no-repeat center bottom; right:'+( digits[1].length*settings.widthNumber + settings.offsetRight + digits[1].length*settings.spaceNumbers )+'px;" class="jodometer_dot"></div>');
            numberOfDecimals = digits[1].length;
            widthDot = settings.widthDot;
        }

        // create a column for each integer digit with the image in the position of the correspondent number
        var integers = digits[0];
        var j = integers.length-1;
        for (var i = 0; i < integers.length; i++) {
            integersArray[i] = integers.charAt(j);
            $this.append('<img style="position:absolute; right:'+ ( i*settings.widthNumber + numberOfDecimals*settings.widthNumber + widthDot + settings.offsetRight + numberOfDecimals*settings.spaceNumbers + i*settings.spaceNumbers + settings.spaceNumbers) +'px; top:'+ ((parseInt(integersArray[i]) *settings.heightNumber*-1)+zeroSet)+'px;" class="jodometer_integer_'+i+'" src="'+settings.numbersImage+'" alt="Integer '+(i+1)+'" />');
            j--;
        }

        // add the interval
        if (parseFloat(settings.counterStart) != settings.counterEnd || (settings.counterEnd.toString() == 'false' && parseFloat(settings.counterStart) == 0) ) {
            if (settings.delayTime > 0) {
                 var counterInterval = setInterval(advanceCounter,  settings.delayTime);
            }
        }

        function advanceCounter() {
            counter += settings.increment;
            setNumbers(counter);
            // if we reach the end clear the interval and use the ending number
            if (settings.counterEnd != false && counter >= settings.counterEnd) {
                clearInterval(counterInterval);
                setNumbers(settings.counterEnd);
            }
        }

        $this.bind("advanceCounter",advanceCounter);

        function rollbackCounter() {
            counter -= settings.increment;
            if (counter < 0) counter = 0;
            setNumbers(counter);
        }

        $this.bind("rollbackCounter",rollbackCounter);

        // to move the colums from one number position to another
        function setNumbers(counter) {
            digits = String(counter).split('.'); // check decimals
            // if we where using decimals
            if (decimalsArray.length > 0) {
                // for each decimal digit, update the old digit position to the new
                for (var i = 0; i < decimalsArray.length; i++) {
                    oldDigit = decimalsArray[i];
                    // the new numer could have not decimal part, but we need it anyway
                    if (digits[1]) {
                        decimalsArray[i] = digits[1].charAt(i);
                    }
                    if (decimalsArray[i] == '') {
                        decimalsArray[i] = '0';
                    }
                    updatePosition($('.jodometer_decimal_'+i, $this), parseInt(decimalsArray[i]), parseInt(oldDigit));
                }
            }

            integers = digits[0];
            j = integers.length-1;
            // for each integer digit, update the old digit position to the new
            for (var i = 0; i < integersArray.length; i++) {
                oldDigit = integersArray[i];
                integersArray[i] = integers.charAt(j);
                if (integersArray[i] == '') {
                    integersArray[i] = '0';
                }
                updatePosition($('.jodometer_integer_'+i, $this), parseInt(integersArray[i]), parseInt(oldDigit));
                j--;
            }
        }

        // changes the column position from one number to another
        function updatePosition(col, newDigit, oldDigit) {
            if (newDigit != oldDigit) {
                col.stop();
                // if the number is 0 use the bottom 0 in the image, and change intantly to the top 0
                if (newDigit == 0) {
                    col.animate({top: (10*settings.heightNumber*-1)+zeroSet}, settings.speed, settings.easing).animate({top: zeroSet},1, 'linear');
                } else {
                    // if the new number is lower than the old, we have to go to the bottom 0 and start from the top 0, with the apropiate speed, to don't note the jump
                    if (newDigit < oldDigit) {
                        col.animate({top: (10*settings.heightNumber*-1)+zeroSet}, settings.speed*((10-oldDigit)/10), 'linear').animate({top: zeroSet},1, 'linear').animate({top: (newDigit*settings.heightNumber*-1)+zeroSet}, settings.speed*oldDigit/10, settings.easing);
                    } else {
                        col.animate({top: (newDigit*settings.heightNumber*-1)+zeroSet}, settings.speed, settings.easing);
                    }
                }
            }
        }
    });
};

$.fn.odometer.defaults = {
    counterStart: '00000',
    counterEnd: false,
    delayTime: 0,
    increment: 1,
    speed: 500,
    easing: 'swing',
    numbersImage: 'numbers.png',
    backgroundImage: 'background.png',
    heightNumber: 27,
    widthNumber: 20,
    offsetRight: 0,
    spaceNumbers: 0,
    widthDot: 20
};

})(jQuery);