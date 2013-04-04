if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}


// Global helpers to run on every page.
function bigLink(index, container) {
  container = $(container);
  container.css({cursor: 'pointer'});
  container.click(function(ev) {
    if ($.inArray(ev.target.tagName, ["DIV", "LI"]) >= 0) {
      document.location = container.find('a:first').attr('href');
    }
  });
}

function onEveryPage() {
  $('input').livequery(function(){
    $(this).placeholder();
  });

  $('.big-link').each(bigLink);
}

$(onEveryPage);
var anchorString = self.document.location.hash.substring(1).replace("%20", " ");


document.documentElement.className += ' has-js';

// Workaround for not needing to replace every confirm dialog in the system
// Rails.js will trigger the confirm:complete event so we take the oportunity to save the target element to this variable
// We then use it in the JQuery UI dialog to complete the action in case the user clicks 'Yes'
var targetOfConfirmDialog;

$(document).ready(function () {
  $('a[data-confirm]').live('confirm:complete', function(e, data){
    targetOfConfirmDialog = $(e.target);
  });

  $("body").append("<div id=\"dialog-confirm\" title=\"Confirmation required\"></div>");
  $.rails.confirm = (function () { return customConfirmDialog; }());

  function customConfirmDialog(msg) {
    $("#dialog:ui-dialog").dialog("destroy");
    $("#dialog-confirm").html(msg);
    $("#dialog-confirm").dialog({
      resizable: false,
      modal: true,
      buttons: {
        "Yes": function() {
          //stub confirm function to allow the click to go through
          $.rails.confirm = function () { return true; };
          targetOfConfirmDialog.click();
          //restores it so further confirm dialogs work correctly
          $.rails.confirm = (function () { return customConfirmDialog; }());
          $(this).dialog("close");
        },
        "No": function() {
          $(this).dialog("close");
        }
      }
    });
  }

  var picker = $("header .title > ul.movements"),
      clicker = $("header .title > a.movement");
  picker.css({ left: clicker.position().left, top: clicker.position().top + clicker.height() });

  picker.hide().menu({
    selected: function(event, ui) {
      window.location = $(event.target).attr("href");
    }
  });

  var hidePicker = function() { clicker.removeClass("active"); picker.hide(); },
      showPicker = function() { clicker.addClass("active");    picker.show(); };

  clicker.click(function(evt) {
    evt.stopPropagation();
    picker.is(":visible") ? hidePicker() : showPicker();
  });

  $("body").click(function(evt) { hidePicker(); });
});
