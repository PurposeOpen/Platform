(function($) {
  function dateRangePicker(options) {
    var fromSelector = options.fromSelector;
    var onSelectFrom = options.onSelectFrom || function(){};
    var onSelectTo = options.onSelectTo || function(){};
    var toSelector = options.toSelector;
    var dateFormat = options.dateFormat || $.datepicker._defaults.dateFormat;
    var readOnly = options.readOnly || false;

    $(fromSelector).datepicker({
      dateFormat: dateFormat,
      onSelect:function(dateText, inst) {
        $(toSelector).datepicker("option", "minDate", dateText);
        onSelectFrom(dateText, inst);
      }
    });

    $(toSelector).datepicker({
      dateFormat: dateFormat,
      onSelect:function(dateText, inst) {
        $(fromSelector).datepicker("option", "maxDate", dateText);
        onSelectTo(dateText, inst);
      }
    });

    if (readOnly) {
      $.each([fromSelector, toSelector], function(index, value) {
        $(value).keydown(function(event) {
          event.preventDefault();
        });
      });
    }
    $.datepicker._selectDate($(fromSelector), $(fromSelector).val());
    $.datepicker._selectDate($(toSelector), $(toSelector).val());
    $('#ui-datepicker-div').hide();
  }

  $.dateRangePicker = dateRangePicker;
})(jQuery);
