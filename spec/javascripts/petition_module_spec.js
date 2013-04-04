describe('Petition Module', function() {

  var languagesElement;
  beforeEach(function() {
    languagesElement = $('<div>');
    var languageLinks = $('<ul>');
    languagesElement.append(languageLinks);

    function addLanguage(isoCode) {
      languageLinks.append('<li><a id="page_' + isoCode + '_link">' + isoCode + '</a></li>');
      var languageContainer = $('<div id="page-' + isoCode + '" data-lang="' + isoCode + '">');
      languageContainer.append('<input data-sync-across-languages=true name="content_modules[111][signatures_goal]">');
      languageContainer.append('<input data-sync-across-languages=true name="content_modules[111][thermometer_threshold]">');
      languagesElement.append(languageContainer);
    }

    addLanguage('en');
    addLanguage('pt');
    addLanguage('fr');
    
    Purpose.ActionModules.initialize(languagesElement);
  });

  it('should keep the threshold fields consistent across languages when the value changes on any language', function() {
    languagesElement.find('#page-en [name$="[thermometer_threshold]"]').val(100).change();

    expect(languagesElement.find('#page-pt [name$="[thermometer_threshold]"]').val()).toBe('100');
    expect(languagesElement.find('#page-fr [name$="[thermometer_threshold]"]').val()).toBe('100');
  });

  it('should keep the goal fields consistent across languages when the value changes on any language', function() {
    languagesElement.find('#page-en [name$="[signatures_goal]"]').val(100).change();

    expect(languagesElement.find('#page-pt [name$="[signatures_goal]"]').val()).toBe('100');
    expect(languagesElement.find('#page-fr [name$="[signatures_goal]"]').val()).toBe('100');
  });

  it('should prevent the threshold value to go beyond the target value', function() {
    var threshold = languagesElement.find('#page-en [name$="[thermometer_threshold]"]');
    threshold.val(400);
    languagesElement.find('#page-en [name$="[signatures_goal]"]').val(299).change().trigger('input');
    
    expect(threshold.attr('max')).toBe('299');
    expect(threshold.val()).toBe('299');
  });

});