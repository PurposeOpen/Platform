var Purpose = Purpose || {};
Purpose.movements = Purpose.movements || {};

Purpose.movements.initLanguagesMultiselectList = function(options) {
    $.extend($.ui.multiselect, {
        locale: {
            itemsCount:'languages selected',
            availableItemsHeader: 'available languages',
            displayActions: false
        }
    });

    $(options.selectSelector).multiselect({searchable: false, sortable:false});
    if(!options.enableSelectedList) {
        $('#languages-container ul.selected a').remove();
    }
};

Purpose.movements.updateDefaultLanguages = function (options) {
    var element = $(options.element);
    var sourceElement = $(options.sourceElement);
    var targetElements = $(options.targetElements);
    var updateDefaultLanguagesList = function(){
        var previouslySelectedDefaultLanguage = element.find("option:selected").val();
        var selectedOptions = sourceElement.find("option:selected");
        var sortedOptions = _.sortBy(selectedOptions, function(option) { return $(option).text()});

        var newOption;
        var newOptions = _.reduce(sortedOptions, function(acc, option) {
            newOption = "<option value='" + $(option).val() + "' " + (previouslySelectedDefaultLanguage === $(option).val() ? "selected='selected'" : '') + ">" + $(option).html() + "</option>";
            acc += newOption;
            return acc;
        }, "");
        element.html(newOptions);
    };
    targetElements.livequery('click', updateDefaultLanguagesList);
};

