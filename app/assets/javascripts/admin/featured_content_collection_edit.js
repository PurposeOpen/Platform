$.page("#featured_content_collections_edit", "#featured_content_collections_update", function (page) {
  var view = Purpose.FeaturedContent.createView(page);
  Purpose.FeaturedContent.init(view);
  var successCallback =  function (target, response) {
    var popupContainer = $('#image-upload-container');
    popupContainer.dialog("close");
    target.val($(response).attr('src'));
  }
  Purpose.initImageUploader(view, successCallback);
  Purpose.Preview.setupPreviewAction();
  Purpose.Preview.disableSaveAndPreviewDuringAjax(page);
});
