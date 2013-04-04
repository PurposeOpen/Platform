var Purpose = Purpose || {};

Purpose.ActionSequence = (function () {
  var self = {};

  self.init = function (view) {

    view.publishedToggle().change(function () {
      var form = view.publishedStatusForm();
      var published = view.publishedToggle().is(":checked");

      form.find('[name="published"]').val(published);
      form.submit();

      if (published) {
        view.unpublishedMessage().hide();
        view.publishedMessage().show();
      } else {
        view.publishedMessage().hide();
        view.unpublishedMessage().show();
      }
    });

    view.languageToggles().change(function () {
      var toggle = $(this);
      var isoCode = toggle.val();
      var enabled = toggle.is(":checked");
      var form = view.languageToggleForm();

      form.find('[name="iso_code"]').val(isoCode);
      form.find('[name="enabled"]').val(enabled);
      form.submit();

      unpublishActionSequenceIfAllLanguagesAreDisabled();
    });

    function unpublishActionSequenceIfAllLanguagesAreDisabled() {
      var any_languages_enabled = false
      view.languageToggles().each(function() {
        if ($(this).is(':checked')) {
          any_languages_enabled = true;
        }
      });

      if (!any_languages_enabled && view.publishedToggle().is(":checked")) {
        toggleCheckBox(view.publishedToggle());
      }
    }
  };

  return self;
}) ();

$.page("#action_sequences_show", function(page) {
  var view = View({
    publishedToggle: "#published_toggle",
    publishedMessage: ".published_message",
    unpublishedMessage: ".unpublished_message",
    publishedStatusForm: "#toggle_published_status_form",
    languageToggles: ".language_toggle",
    languageToggleForm: "#toggle_enabled_language_form"
  });

  Purpose.ActionSequence.init(view);
});
