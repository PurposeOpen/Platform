var Purpose = Purpose || {};
Purpose.JoinEmails = Purpose.JoinEmails || {};

Purpose.JoinEmails.init = function (view) {
  view.tabsContainer().tabs();
};

Purpose.JoinEmails.createView = function (rootElement) {
  var self = {};
  var root = $(rootElement);

  self.tabsContainer = function () {
    return root.find("#language_tabs");
  };

  return self;
};