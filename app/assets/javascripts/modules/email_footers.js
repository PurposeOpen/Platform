var Purpose = Purpose || {};
Purpose.EmailFooters = Purpose.EmailFooters || {};

Purpose.EmailFooters.init = function (view) {
  view.tabsContainer().tabs();
};

Purpose.EmailFooters.createView = function (rootElement) {
  var self = {};
  var root = $(rootElement);

  self.tabsContainer = function () {
    return root.find("#language_tabs");
  };

  return self;
};