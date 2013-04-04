/* http://github.com/luizfar/View */

FakeView = (function () {
  var self = {};

  var _supportedElements = {
    input: "<input type='text'>",
    textInput: "<input type='text'>",
    hidden: "<input type='hidden'>",
    checkBox: "<input type='checkbox'>",
    form: "<form>",
    div: "<div>",
    p: "<p>",
  };

  for (var element in _supportedElements) {
    if (_supportedElements.hasOwnProperty(element)) {
      createFactoryFunction(element, _supportedElements[element]);
    }
  }

  function createFactoryFunction(elementName, elementDefinition) {
    self[elementName] = function (spec) {
      var jqueryObject = prepare($(elementDefinition), spec);
      if (elementName == "form") {
        jqueryObject.submit = function () {};
      }
      return jqueryObject;
    };
  }

  function prepare(element, spec) {
    for (var specAttribute in spec) {
      if (spec.hasOwnProperty(specAttribute)) {
        if (specAttribute == "contains") {
          $.each(spec.contains, function (index, child) {
            element.append(child);
          });
        }
        else if (specAttribute == "classes") { $.each(spec.classes, function (index, clazz) { element.addClass(clazz); }) }
        else if (specAttribute == "checked" && spec[specAttribute]) { element.attr("checked", "checked") }
        else if (specAttribute == "css") { for (c in spec.css) element.css(c, spec.css[c]); }
        else if (specAttribute == "value") { element.val(spec.value); }
        else { element.attr(specAttribute, spec[specAttribute]); }
      }
    }

    return element;
  }

  function createAccessor(result, definition, key) {
    var element = definition[key];
    if (element instanceof Array) {
      var array = [];
      for (var i = 0; i < element.length; i++) {
        array.push(element[i].get(0));
      }
      element = $(array);
    }
    result[key] = function () { return element; };
  }
  
  self.stub = function (definition) {
    var result = {};
    for (var key in definition) {
      createAccessor(result, definition, key);
    }
    return result;
  };

  return self;
}) ();