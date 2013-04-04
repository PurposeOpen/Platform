View = (function () {
  function addAccessor(result, definition, key) {
    result[key] = function () { return $(definition[key]); };
  }

  var self = function (definition) {
    var result = {};
    for (var key in definition) {
      addAccessor(result, definition, key);
    }
    return result;
  };

  return self;
}) ();