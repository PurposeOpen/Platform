(function($) {
  function timeRangePicker(options) {
    var fromSelector = options.fromSelector;
    var filterOptionsOnOptionsSelector = options.filterOptionsOnSelector + ' option';
    var toSelector = options.toSelector;
    var filterFunction = function () {
      $.each($(filterOptionsOnOptionsSelector), function(i, val) {
        var optionValue = parseInt($(val).val(), 10);
        if (optionValue >= parseInt($(fromSelector).val(), 10) && optionValue <= parseInt($(toSelector).val(), 10)) {
          $($(filterOptionsOnOptionsSelector)[i]).removeAttr('disabled');
        } else {
          $($(filterOptionsOnOptionsSelector)[i]).attr('disabled', 'disabled');
        }
      });
    };

    setupChangeFor(fromSelector, toSelector + ' option', function(a, b) {return a < b;}, filterFunction);
    setupChangeFor(toSelector, fromSelector + ' option', function(a, b) {return a > b;}, filterFunction);

    $(fromSelector).change();
    $(toSelector).change();
  }

  function setupChangeFor(inputASelector, inputBSelector, comparator, filterFunction) {
    $(inputASelector).change(function(event) {
      var selectedOption = $(event.target).val();
      var option;
      $(inputBSelector).removeAttr('disabled');
      $.each($(inputBSelector), function(i, val) {
        option = $(val);
        var a = parseInt(option.val(), 10);
        var b = parseInt(selectedOption, 10);
        if (comparator(a, b)) {
          option.attr('disabled', 'disabled');
        }
      });
      filterFunction();
    });
  }

  $.timeRangePicker = timeRangePicker;
})(jQuery);
