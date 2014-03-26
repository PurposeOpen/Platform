var Purpose = Purpose || {};

Purpose.Emails = (function () {
  var self = {};

  self.init = function (view) {
    var default_text_align = view.emailSubject().css('text-align');
    var default_font_size = view.emailSubject().css('font-size');

    view.emailLanguage().change(function () {
      if(view.emailLanguageSelection().text() == 'Arabic'){
        view.emailSubject().css({'text-align': 'right', 'font-size': '30px'});
      }else {
        view.emailSubject().css({'text-align': default_text_align, 'font-size': default_font_size});
      };
    });
  };

  return self;
}) ();

$.page("#new_email", function(page) {
  var view = View({
    emailLanguage: "#email_language_id",
    emailLanguageSelection: "#email_language_id option:selected",
    emailSubject: "#email_subject"
  });

  Purpose.Emails.init(view);
});