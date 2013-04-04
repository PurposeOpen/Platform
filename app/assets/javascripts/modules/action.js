var Purpose = Purpose || {};

Purpose.ActionModules = {
  initialize: function(languageTabs) {
    var fieldsToSync = languageTabs.find('[data-sync-across-languages]');

    fieldsToSync.change(function() {
      var fieldAttribute = $(this).attr('name').match(/\[(?!\d).*]/)[0];
      var fieldSet = languageTabs.find("[name$='" + fieldAttribute + "']");
      var newValue = $(this).val();
      fieldSet.val(newValue).trigger('sync', [ $(this), newValue ]);
    });

    var thresholdFields = languageTabs.find('[name$="[thermometer_threshold]"]');
    var goalFields = languageTabs.find('[name$="[signatures_goal]"],[name$="[donations_goal]"]');

    goalFields.bind('input', function() {
      var maxValue = $(this).val();
      thresholdFields.attr('max', maxValue);
      
      (parseInt(thresholdFields.val()) >= parseInt(maxValue)) && thresholdFields.val(maxValue);
    });


    // *****
    // [Tags] [input] [for] [donation] [module]
    // ***************
    var suggestedAmountsFields = languageTabs.find('.suggested_amounts');

    suggestedAmountsFields.tagsInput({
      defaultText: '',
      width: '100%',
      onBeforeAddTag: function(tag) {
        if (/^([0-9]){1,}([.]){0,1}([0-9]){0,}$/.test(tag) && parseInt(tag) > 0) return true;
        $(this).markAsInvalid();
        return false;
      },
      onAddTag: function(amount) {
        var frequency = $(this).data('frequency');
        var moduleId = $(this).data('module-id');
        var currency = $(this).data('currency');

        if(frequency) {
          var recurringDefaultAmountContainerId = '#recurring_default_amount_option_' + moduleId + '_' + frequency + '_' + currency;
          // Add default amount
          $(recurringDefaultAmountContainerId).append(
            '<div class="default_amount_option" id="recurring_default_amount_option_' + moduleId + '_' + frequency + '_' + currency + '_' + amount +
              '"> <input id="content_modules_' + moduleId + '_recurring_default_amount_' + frequency + '_' + currency + '_' + amount + '" ' +
              'name="content_modules[' + moduleId + '][recurring_default_amount][' + frequency +'][' + currency + ']" type="radio" value="' + amount +
              '"> <label for="content_modules_' + moduleId + '_recurring_default_amount_' + frequency + '_' + currency + '_' + amount + '">' + amount +
              '</label></div>'
          );
          var suggestedAmountsForOtherModules = $('.suggested_amounts[data-module-id!=' + moduleId + '][data-frequency=' + frequency +'][data-currency=' + currency + ']');
        }else {
          var defaultAmountContainerId = '#default_amount_option_' + moduleId + '_' + currency;
          // Add default amount
          $(defaultAmountContainerId).append(
            '<div class="default_amount_option" id="default_amount_option_' + moduleId + '_' + currency + '_' + amount +
              '"> <input id="content_modules_' + moduleId + '_default_amount_' + currency + '_' + amount + '" ' +
              'name="content_modules[' + moduleId + '][default_amount][' + currency + ']" type="radio" value="' + amount +
              '"> <label for="content_modules_' + moduleId + '_default_amount_' + currency + '_' + amount + '">' + amount +
              '</label></div>'
          );

          var suggestedAmountsForOtherModules = $('.suggested_amounts[data-module-id!=' + moduleId + '][data-currency=' + currency + ']');
        }

        // sync across languages
        if (!suggestedAmountsForOtherModules.tagExist(amount)) {
          _.each(suggestedAmountsForOtherModules, function(suggested_amounts) {
            if(!$(suggested_amounts).tagExist(amount)) {
              $(suggested_amounts).addTag(amount);
            };
          });
        }
      },
      onRemoveTag: function(amount) {
        if (!amount) return;
        var frequency = $(this).data('frequency');
        var moduleId = $(this).data('module-id');
        var currency = $(this).data('currency');

        if(frequency) {
          var defaultAmountOptionId = '#recurring_default_amount_option_' + moduleId + '_' + frequency + '_' + currency + '_' + amount;
          $(defaultAmountOptionId).remove();

          var suggestedAmountsForOtherModules = $('.suggested_amounts[data-module-id!=' + moduleId + '][data-frequency=' + frequency +'][data-currency=' + currency + ']');
        }else {
          var defaultAmountOptionId = '#default_amount_option_' + moduleId + '_' + currency + '_' + amount;
          $(defaultAmountOptionId).remove();

          var suggestedAmountsForOtherModules = $('.suggested_amounts[data-module-id!=' + moduleId + '][data-currency=' + currency + ']');
        }

        // sync across languages
        if (suggestedAmountsForOtherModules.tagExist(amount)) {
          _.each(suggestedAmountsForOtherModules, function(suggested_amounts) {
            if($(suggested_amounts).tagExist(amount)) {
              $(suggested_amounts).removeTag(amount);
            };
          });
        }
      }
    });
  }
};

$(function() {
  Purpose.ActionModules.initialize($('#language_tabs'));
});