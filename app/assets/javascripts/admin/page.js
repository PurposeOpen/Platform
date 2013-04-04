(function($) {
  
  // Accepts a list of selectors and an initializer function. Initializer is passed to jQuery ready fn
  // for every matching selector.
  //
  // Usage:
  //
  //   $.page("#edit_user", "#new_user", function() {
  //     ... initialize this ...
  //   })
  $.page = function() {
    var args = $.makeArray(arguments),
        initializer = args.pop(),
        pages = args.join(', ');

    $(document).ready(function() {
      $(pages).each(function(index, element) {
        initializer(element);
      });
    });
  };

})(jQuery);