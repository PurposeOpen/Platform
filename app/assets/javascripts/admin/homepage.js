$.page("#homepages_edit", function (page) {
  var successCallback =  function (target, response) {
    var popupContainer = $('#image-upload-container');
    popupContainer.fadeOut(300);
    popupContainer.dialog("close");
    target.val($(response).attr('src'));
  }
  Purpose.initImageUploader(page, successCallback);
  Purpose.Preview.setupPreviewAction();
  Purpose.Preview.disableSaveAndPreviewDuringAjax(page);
});
