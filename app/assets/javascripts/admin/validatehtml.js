function validateHtml(htmlFieldSelector, errorsSelector, validateHtmlUrl) {
  var htmlField = $(htmlFieldSelector);
  var errorsContainer = $(errorsSelector);
  var timeoutId;
  var lastXhr;
  var lastText;
  
  function validatedHtml(data, status, xhr) {
    htmlField.removeClass("loading");
    if (xhr != lastXhr || htmlField.val() != lastText) {
      return; 
    }
    errorsContainer.slideUp(40, function() {
        errorsContainer.html(data);
      });
    errorsContainer.slideDown();
  }
  
  function runValidation() {
    htmlField.addClass("loading");
    lastText = htmlField.val();
    lastXhr = $.get(validateHtmlUrl, {to_validate: lastText}, validatedHtml);
  }
  
  function politelyCheckHtml(e) {
    if (timeoutId !== undefined) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(runValidation, 1000);
  }
  
  htmlField.bind('keyup', politelyCheckHtml);
}