var Purpose = Purpose || {};
Purpose.ActionPages = Purpose.ActionPages || {};

$.fn.toggleFields = function(fieldWrapper) {
  return $(this).each(function() {
    var input = $(this),
        trigger = function() { input.siblings(fieldWrapper).toggle( input.is(":checked") ); };

    trigger();
    input.change(trigger);
  });
};

Purpose.unloadMessage = function() {
  return 'You have entered new data on this page.' +
    ' If you navigate away from this page without' +
    ' first saving your data, the changes will be' +
    ' lost.';
};
Purpose.setConfirmUnload = function(on) {
  window.onbeforeunload = (on === true) ? Purpose.unloadMessage : undefined;
};

Purpose.ActionPages.setUpCharacterCounter = function() {
  $('textarea + span.counter').each(function() {
    textarea = $(this).prev();
    var maxlength = textarea.attr('maxlength') || textarea.data('soft-maxlength');
    textarea.charCount({ allowed: maxlength });
  });
};

Purpose.ActionPages.setUpWarnOnLeavingWithChanges = function() {
  $('input, textarea').change(function() { Purpose.setConfirmUnload(true); });
  $('form').submit(function() { Purpose.setConfirmUnload(false); });
};

Purpose.ActionPages.setUpDisableContentToggle = function() {
  var toggleCheckboxElement = '.disable_content_toggle';
  $(toggleCheckboxElement).change(function(event){
    var fields = $('#'+$(event.target).attr('fields'));
    if(event.target.checked){
      fields.fadeOut();
    }else{
      fields.fadeIn();
    }
  });
};

Purpose.ActionPages.getCrowdringCount = function(ui) {
  var getCrowdringCountButton = $('button.crowdring_count');
  getCrowdringCountButton.click(Purpose.fetchCount);

  var crowdringCampaignName = $('.crowdring_campaign_name');
  crowdringCampaignName.focus(Purpose.resetTestButton);
};

Purpose.ActionPages.setupImageUploader = function(ui){
  var successCallback =  function (target, response) {
    var popupContainer = $('#image-upload-container');
    popupContainer.dialog("close");
    target.val($(response).attr('src'));
  }
  Purpose.initImageUploader(ui, successCallback);
}

Purpose.resetTestButton = function(){
  this.nextElementSibling.textContent = 'Test';
  this.nextElementSibling.style.backgroundColor = '#13A7D2';
};

Purpose.fetchCount = function(e){
  $('.response_count').remove()
  var campaignNameField = $('.crowdring_campaign_name'),
  button = this,
  request = this.getAttribute('data-url') + "/campaign/" + campaignNameField[0].value + "/campaign-member-count?callback=?";
  e.preventDefault();
  if (campaignNameField[0].value != ''){
    $.getJSON(request, function(response){
      Purpose.setTestButtonStyle(button, 'Ok!', 'green');
      $('<p class="response_count" style="margin:0px;"> Crowdring member count:'+ response.count +'</p>').insertAfter(button);
    }).error(function(){
      Purpose.setTestButtonStyle(button, 'Failed!', 'red');
      $('<p class="response_count" style="margin:0px;">Invalid Campaign name</p>').insertAfter(button);
    });
  }
};

Purpose.setTestButtonStyle = function(button, text, color){
  button.style.backgroundColor = color;
  button.textContent = text;
}
