$(document).ready(function () {

  var blastId = undefined;
  var baseUrl = $('#clone_email').attr('data-url');
  var dropDown = function (parentCombo, dependentCombo) {
    var parentComboValue = parentCombo.val();
    var actionName = dependentCombo.parent().attr('action-name');

    if (parentComboValue == "" || parentComboValue == undefined) {
      toggleFields(dependentCombo.parent());
    } else {
      subUrl = actionName.replace("id", parentComboValue)
      doAjax(baseUrl + subUrl, dependentCombo);
    }

  };

  var doAjax = function (url, enableSelect) {
    jQuery.ajax({
      url:url,
      dataType:"json",
      success:function (data) {
        enableSelect.attr("disabled", false);
        resetAndLoadData(enableSelect, data);
      }
    });
  };

  var toggleFields = function (dependent) {
    dependent.find('select').attr('disabled', true);
    dependent.find('select').val('');
    $("#button_clone").attr("disabled", true);

  };

  var resetFields = function () {
    campaignsSelect.val('');
    pushsSelect.find('option[value != ""]').remove();
    emailsSelect.find('option[value!= ""]').remove();
    pushsSelect.attr('disabled', true);
    emailsSelect.attr('disabled', true);
    $("#button_clone").attr("disabled", true);
  }


  var resetAndLoadData = function (selectBox, data) {
    selectBox.find('option[value != ""]').remove();
    for (i = 0; i < data.length; i++) {
      selectBox.append($('<option>', {
        value:data[i].value,
        text:data[i].label
      }));
    }
  };
  $("#clone_email").dialog({
    autoOpen:false,
    height:300,
    width:450,
    modal:true,
    resizable:false,
    title:"Select an email to clone",
    close:function () {
      resetFields();
    },
    open:function () {
      resetFields();
    },
    buttons:[
      {
        id:"button_clone",
        text:"Clone",
        click:function () {
          var selectedEmail = $('#email').val();
          if (selectedEmail != undefined && selectedEmail != "") {
            url = baseUrl + '/emails/' + $('#email').val() + '/clone?blast_id=' + blastId;
            window.location.href = url;
          }
        }
      }
    ]
  });

  $(".clone_email_button").click(function (e) {
    var blast_id = $(this).attr("blast_id");
    blastId = blast_id;

    $("#clone_email").dialog("open");
    return false;
  });

  var campaignsSelect = $('#campaign');
  var pushsSelect = $('#push');
  var emailsSelect = $('#email');
  campaignsSelect.change(function () {
    dropDown($('#campaign'), $('#push'));
  });
  pushsSelect.change(function () {
    dropDown($('#push'), $('#email'));
  });

  emailsSelect.change(function () {
    if (emailsSelect.val() != '') {
      $("#button_clone").attr("disabled", false);
    } else {
      $("#button_clone").attr("disabled", true);
    }
  })
});
