var Purpose = Purpose || {};

Purpose.initImageUploader = function (view, callbackOnSuccess, failureCallback) {
  $('input.uploader').wrap('<span class="deleteicon" />').after($('<span/>').click(function (e) {
    var target = $(this).prev('input');
    var imageUploadContainer = $('#image-upload-container');
    if (imageUploadContainer.dialog) {
      imageUploadContainer.dialog({
        modal:true,
        height:650,
        width:800,
        autoOpen:false
      });
    }
    imageUploadContainer.load('/assets/tinymce/plugins/purposeImageManagerPlugin/dialog_other.htm', function () {
      if (callbackOnSuccess == undefined) {
        callbackOnSuccess = function (target, response) {
          target.val(response);
          imageUploadContainer.fadeOut(300);
          imageUploadContainer.dialog("close");
        };
      }
      PurposeImageManagerPluginDialog.initNonTinyMCE($.extend({successCallback: callbackOnSuccess}, imageUploadContainer[0].dataset));
      PurposeImageManagerPluginDialog.settings.target = target;
      imageUploadContainer.dialog("open");
    });
  }));
}

Purpose.initImageUploaderOn = function (partialTree, callbackOnSuccess, failureCallback) {
  partialTree.find('input.uploader').wrap('<span class="deleteicon" />').after($('<span/>').click(function (e) {
    var target = $(this).prev('input');
    var imageUploadContainer = $('#image-upload-container');
    if (imageUploadContainer.dialog) {
      imageUploadContainer.dialog({
        modal:true,
        height:650,
        width:800,
        autoOpen:false
      });
    }
    imageUploadContainer.load('/assets/tinymce/plugins/purposeImageManagerPlugin/dialog_other.htm', function () {
      if (callbackOnSuccess == undefined) {
        callbackOnSuccess = function (target, response) {
          target.val(response);
          imageUploadContainer.fadeOut(300);
          imageUploadContainer.dialog("close");
        };
      }
      PurposeImageManagerPluginDialog.initNonTinyMCE($.extend({successCallback:callbackOnSuccess}, imageUploadContainer[0].dataset));
      PurposeImageManagerPluginDialog.settings.target = target;
      imageUploadContainer.dialog("open");
    });
  }));
}


