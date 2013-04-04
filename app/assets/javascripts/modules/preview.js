/*
* Preview action_pages
* */

var Purpose = Purpose || {};
Purpose.Preview = Purpose.Preview || {};

Purpose.Preview.setupPreviewAction = function(){
  $('#preview').click(function(event) {
    event.preventDefault();
    $this = $(this);
    if ($this.attr('disabled')) return false;
    $this.text("Generating preview...");

    var url = $this.attr('href'),
        parameters = $this.parents('form').serialize();

    $.ajax({
      url: url,
      type: "PUT",
      data: parameters,
      success: function(data) {
        $this.text("Preview");
        window.open(data, '_blank');
      },
      error: function(data) {
        if (console && console.log) { console.log("Error calling preview:", data); }
        $this.text("Preview");
      }
    });
    return false;
  });
};

Purpose.Preview.disableSaveAndPreviewDuringAjax = function(page) {
  var disableSubmitAndPreview = function(){
    $('input[type="Submit"]').attr('disabled', 'disabled');
    $('#preview').attr('disabled', 'disabled');
  };

  var enableSubmitAndPreview = function(){
    $('input[type="Submit"]').removeAttr('disabled');
    $('#preview').removeAttr('disabled');
  }
  $(page).ajaxStart(disableSubmitAndPreview).ajaxStop(enableSubmitAndPreview);
};
