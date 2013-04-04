$(function() {

  $.fn.qtip.defaults = $.extend(true, {}, $.fn.qtip.defaults, {
    position:{
      my: 'top center',
      at: 'bottom center',
      effect: false
    },
    style: {
      tip: {
        width: 25,
        height: 15
      },
      classes: 'customised-tooltip'
    }
  });

  $("[data-tip]").each(function() {
    $(this).qtip({ content: $(this).data("tip") });
  });
});
