$(function () {
  window.PurposeImageManagerPluginDialog = {
    settings:undefined,
    init:function (ed, url) {
      PurposeImageManagerPluginDialog.initFileAndPreviewConstructs(tinymce.selectedInstance.settings);
      $('form').submit(PurposeImageManagerPluginDialog.saveAsset);
    },

    initFileAndPreviewConstructs:function (params) {
      $('input[type="file"]').change(function () {
        var fileReader = new FileReader;
        fileReader.onload = function () {
          modifedImage = new Image;
          modifedImage.onload = function () {
            canvas = $("canvas")[0];
            canvas.setAttribute('width', modifedImage.width);
            canvas.setAttribute('height', modifedImage.height);
            ctx = canvas.getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.drawImage(modifedImage, 0, 0);
          }
          modifedImage.src = this.result;
        }
        fileReader.readAsDataURL(this.files[0]);
      });
      $('#configured_image_parameters #image_height').html(params.imageHeight+ ' px');
      $('#configured_image_parameters #image_width').html(params.imageWidth + ' px');
      $('#configured_image_parameters #image_dpi').html(params.imageDpi + ' pixels/inch');

      if(params.imageHeight == undefined || (params.imageHeight == "null" && params.imageWidth ==  "null" && params.imageDpi == "null")){
        $('#configured_image_parameters').hide();
      }
    },

    initNonTinyMCE:function (settings) {
      PurposeImageManagerPluginDialog.settings = settings;
      PurposeImageManagerPluginDialog.initFileAndPreviewConstructs(settings);
      $('#purposeImageManagerUploadForm').submit(PurposeImageManagerPluginDialog.save);
    },

    uploadFiles:function (url, files, successCallback, failureCallback) {
      var formData = new FormData();
      for (var i = 0, file; file = files[i]; ++i) {
        formData.append('image[image]', file);
      }
      var xhr = new XMLHttpRequest();
      var token = tinyMCE.$("meta[name='csrf-token']").attr("content");
      xhr.open('POST', url, true);
      xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      xhr.onreadystatechange = function () {
        if (xhr.readyState == 4)
          xhr.status == 200 ? successCallback(xhr.responseText) : failureCallback(xhr.responseText);
      }
      xhr.setRequestHeader("X-CSRF-Token", token);
      xhr.send(formData);
    },

    saveAsset:function (e) {
      e.preventDefault();
      $('#imageUploadSubmit').attr('disabled', 'disabled');
      PurposeImageManagerPluginDialog.uploadFiles(tinymce.selectedInstance.settings.imageUploadUrl, document.querySelector('input[type="file"]').files, function (response) {
        $('#imageUploadSubmit').removeAttr('disabled');
        tinyMCEPopup.editor.execCommand('mceInsertContent', false, response);
        tinyMCEPopup.close();
      }, function (responseText) {
        alert("An Error Occurred. Please contact the systems administrator!");
        $('#imageUploadSubmit').removeAttr('disabled');
      });
      return false;
    },

    save:function (e) {
      e.preventDefault();
      $('#imageUploadSubmit').attr('disabled', 'disabled');
      PurposeImageManagerPluginDialog.uploadFiles(PurposeImageManagerPluginDialog.settings.imageUploadUrl, document.querySelector('input[type="file"]').files, function (response) {
        $('#imageUploadSubmit').removeAttr('disabled');
        if (PurposeImageManagerPluginDialog.settings.successCallback)
          PurposeImageManagerPluginDialog.settings.successCallback(PurposeImageManagerPluginDialog.settings.target, response);
      }, function (responseText) {
        alert("An Error Occurred. Please contact the systems administrator!");
        $('#imageUploadSubmit').removeAttr('disabled');
        if (PurposeImageManagerPluginDialog.failureCallback)
          PurposeImageManagerPluginDialog.failureCallback(PurposeImageManagerPluginDialog.settings.target, response);
      });
    }
  };
  if (tinyMCE)
    tinyMCEPopup.onInit.add(PurposeImageManagerPluginDialog.init, PurposeImageManagerPluginDialog);
});
