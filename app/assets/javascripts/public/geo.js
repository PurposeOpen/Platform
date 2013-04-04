/*global window, $, jQuery, document */

var target = window.target || { };
target.geo = {};


target.geo.user = function (options) {
  options.locator.getCurrentPosition(function (position) {
    options.map[options.location_property] = {
      lat: position.coords.latitude,
      lng: position.coords.longitude
    };
    options.map.center_for_user();
  }, function () {
    options.map[options.location_property] =  null;
  });
};
