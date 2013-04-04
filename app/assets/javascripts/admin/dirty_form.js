
$.fn.dirty_form = function (rules) {
  var scope = $(this),
  inputs = scope.find(":input"),
  is_dirty = false,
  set = function (dirty, message) {
	  is_dirty = dirty;
	  scope.find(rules.notify.selector).html(message);
	  if (rules.callback) {
	    rules.callback(is_dirty);
	  }
  };
  
  inputs.change(function () {
    set(true, rules.notify.message);
  });
  scope.find(rules.unless.selector).bind(rules.unless.action, function () {
    set(false, "");    
  });
};