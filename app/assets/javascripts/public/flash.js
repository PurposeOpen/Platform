
$.fn.flash = function () {
  var flash_element =$(this);

  // if(!flash_element.html().match(/^\s*$/gi, "")) {
    // flash_element.fadeIn("slow").delay(3000).fadeOut("slow");
    flash_element.fadeIn("slow").delay(3000);
  // }
};
