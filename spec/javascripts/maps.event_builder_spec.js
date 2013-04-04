
describe("target.maps event builder", function () {
  beforeEach(function () {
    jasmine.getFixtures().fixturesPath = "/__spec__/fixtures/";
    jasmine.getFixtures().load("maps_create.html");
    maps = target.maps.event_builder.create();
    maps.template_provider = function () { return ""; };
    maps.geo_bounds = function () { return null; };
    maps.display_location_map_node = $("<div></div>");
    maps.display_location_text_node = $("<div></div>");
    maps.display_lookup_button_node = $("<div></div>");
    jQuery("#create-event")
        .append(maps.display_location_map_node)
        .append(maps.display_location_text_node)
        .append(maps.display_lookup_button_node);
  });

  describe("bind to node", function () {
    beforeEach(function () {
      maps.bind_to_node(jQuery("#create-event"));
    });

    it("should initially hide the event details", function () {
      expect(jQuery("#create-event fieldset.event-details").css("display")).toBe("none");
    });

    it("should add a 'lookup address' button", function () {
      expect(jQuery("#create-event input.lookup").size()).toBe(1);
    });
  });

  describe("initialisation", function () {
    var geocoder_response = [{
      geometry: {location: "0,0"},
      formatted_address: "A formatted address"
    }];
    beforeEach(function () {
      mock_geocoder = {
        geocode: function (options, callback) {
          callback(geocoder_response, true);
        }
      };
      sinon.spy(mock_geocoder, "geocode");
      maps.bind_to_node(jQuery("#create-event"));
      maps.geocoder = mock_geocoder;
      maps.geocoder_status_codes.OK = true;
      maps.geo_bounds = function () { return "bounds"; };
      maps.template_provider = function () { return ""; };
      maps.map_factory = function () {
        return {setCenter: function() {}, setZoom: function() };
      };
      maps.marker_factory = function () {};
      maps.display_location_map_node = $("<div></div>");
      maps.display_location_text_node = $("<div></div>");
      maps.display_lookup_button_node = $("<div></div>");
      maps.location_to_latlng = function () {
        return {lat: function () { return 0; }, lng: function () { return 0; } };
      };
    });

    it("should show the event details and location if geocodes are already supplied", function() {
      sinon.spy(maps, "show_address");
      sinon.spy(maps, "enable_details");
      jQuery("input#event_suburb_latitude").val("-29.6911226");
      jQuery("input#event_suburb_longitude").val("152.93319930000007");
      jQuery("input#event_address_latitude").val("-29.6911226");
      jQuery("input#event_address_longitude").val("152.94356300000004");
      maps.bind_to_node(jQuery("#create-event"));
      expect(maps.show_address).toHaveBeenCalled();
      expect(maps.enable_details).toHaveBeenCalled();
    });

  });

  describe("verify address", function () {
    var geocoder_response = [{
      geometry: {location: "0,0"},
      formatted_address: "A formatted address"
    }];
    beforeEach(function () {
      mock_geocoder = {
        geocode: function (options, callback) {
          callback(geocoder_response, true);
        }
      };
      sinon.spy(mock_geocoder, "geocode");
      maps.bind_to_node(jQuery("#create-event"));
      maps.geocoder = mock_geocoder;
      maps.geocoder_status_codes.OK = true;
      maps.geo_bounds = function () { return "bounds"; };
      maps.template_provider = function () { return ""; };
      maps.map_factory = function () {
        return {setCenter: function() {}};
      };
      maps.marker_factory = function () {};
      maps.display_location_map_node = $("<div></div>");
      maps.display_location_text_node = $("<div></div>");
      maps.display_verify_button_node = $("<div></div>");

      maps.location_to_latlng = function () {
        return {lat: function () { return 0; }, lng: function () { return 0; } };
      };
    });

    it("should send a request to google api with the address", function () {
      maps.lookup_address("51 Pitt Street Sydney NSW 2000 Australia");
      expect(mock_geocoder.geocode).toHaveBeenCalledWith({address: "51 Pitt Street Sydney NSW 2000 Australia", bounds: "bounds"});
    });

    it("should present the returned address to the user", function () {
      sinon.spy(maps, "show_address");
      maps.lookup_address("10 George Street Sydney NSW 2000 Australia");
      expect(maps.show_address).toHaveBeenCalledWith(geocoder_response);
    });

    it("should replace newlines with spaces before sending for geocoding", function () {

      maps.lookup_address("51 Pitt Street \n\nSydney NSW 2000\n\n Australia");
      expect(mock_geocoder.geocode).toHaveBeenCalledWith({address: "51 Pitt Street Sydney NSW 2000 Australia", bounds: "bounds"});
    });

    it("should create a new map when presenting the address", function () {
      maps.map_factory = function (element, options) {
        jQuery(element).html("text");
        return {setCenter: function() {}};
      };
      sinon.spy(maps.map_provider, "Map");
      maps.show_address([{geometry: {location: "0,0"}}]);
      expect(maps.display_location_map_node.html()).toBe("text");
    });

    it("indicate the address could not be found", function () {
      maps.geocoder = {
        geocode: function (options, callback) {
          callback(geocoder_response, "ZERO_RESULTS");
        }
      };
      sinon.spy(maps, "show_address");
      maps.lookup_address("Does not exist");
      expect(maps.display_location_text_node.html()).toBe("<p>Address could not be found</p>");
    });

    it("should insert geolocation data when an address is verified", function () {
       maps.map = {setCenter: function() {}};
       maps.select_location({"geometry": {
        "location": {
          "lat": function () { return 0; },
          "lng": function () { return 0; }
        }}});
       maps.select_location({"geometry": {
        "location": {
          "lat": function () { return -33.8906466; },
          "lng": function () { return 151.2129254; }
        }}});
      expect(jQuery("#create-event input#event_address_latitude").val()).toBe("-33.8906466");
      expect(jQuery("#create-event input#event_address_longitude").val()).toBe("151.2129254");
    });

    it("should insert reverse geolocation as suburb geocode", function () {
      var lat = 2, lng = 5;
      maps.location_to_latlng = function () {
        return {lat: function () { return 2; }, lng: function () { return 5; } };
      };
      maps.geocoder = {
        geocode: function (options, callback) {
          callback([{
            geometry: {
              location: {
                lat: function () { return lat; },
                lng: function () { return lng; }},
              location_type: "APPROXIMATE"
            },
            formatted_address: "A formatted address",
            address_components: [{
                                   "long_name": "1234",
                                   "short_name": "1234",
                                   "types": ["postal_code"]
                                }]
          }], maps.geocoder_status_codes.OK);
        }
      };
      maps.reverse_lookup();
      expect(jQuery("#create-event input#event_suburb_latitude").val()).toBe("2");
      expect(jQuery("#create-event input#event_suburb_longitude").val()).toBe("5");
      expect(jQuery("#create-event input#event_postcode").val()).toBe("1234");

    });

    it("should enable entering of event details once an address is verified", function () {
      maps.verify_address();
      expect(jQuery("#create-event fieldset.event-details").css("display")).toBe("block");
    });

  });
});
