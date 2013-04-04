
describe("target.geo", function () {
  it("should set the supplied property with geo data", function () {
    var my = { location_property: null, center_for_user: function () {} },
        locator = {
          getCurrentPosition: function (fn_success, fn_error) {
            fn_success({coords: {latitude: 5, longitude: 3}});
          }
        };

    target.geo.user({map: my, location_property: "location_property", locator: locator});
    expect(my.location_property.lat).toBe(5);
    expect(my.location_property.lng).toBe(3);
  });
});
