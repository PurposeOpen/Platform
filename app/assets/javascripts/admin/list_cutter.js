
var Purpose = Purpose || {};
Purpose.ListCutter = (function() {

  var view = null;
  var filtersCount = 0;

  function initialize(v) {
    view = v;
    filtersCount = 0;
    attachAutoComplete(view.listForm());

    $.each(view.filters(), function (i, filter) { 
      initializeExistingFilter(filter);
    });
    if (view.filters().length == 0) { addFilter(); }
    view.addFilter().click(function() { addFilter(); });
    view.listForm().validate(formValidationConfig);
    attachDatePicker(view.listForm());
  }

    function findElementWithErrorClass(element) {
        var jElement = $(element), finalElement;
        finalElement = jElement;
        if (jElement.hasClass("multiselectcheckbox")) {
            finalElement = jElement.parent().find(".ui-multiselectcheckbox");
        }
        return finalElement;
    }

    var formValidationConfig = {
      errorClass:"list_cutter_error",
      errorPlacement:function (error, element) {
          var finalElement = findElementWithErrorClass(element);
          finalElement.qtip({content:error});
          finalElement.addClass(this.errorClass);
      },
      unhighlight:function (element, errorClass, validClass) {
          var finalElement = findElementWithErrorClass(element);
          finalElement.qtip("destroy");
          finalElement.removeClass(errorClass).addClass(validClass);
      },
      submitHandler:saveListAndWaitForCount,
      invalidHandler:function () {
          $("#list-cutter-results").hide();
      }
  };

  function initializeExistingFilter(filter) {
    updateInputsIndex($(filter));
    setFilterBindings($(filter));
  }

  function saveListAndWaitForCount() {
      var buttonClicked = $(this.submitButton),
          url = buttonClicked.data("url"),
          pollUrl = buttonClicked.data("poll-url"),
          listForm = buttonClicked.closest("form");

      view.showButton().attr('disabled', 'disabled');
      view.saveButton().attr('disabled', 'disabled');

      $.post(url, listForm.serialize(),function (data) {
          var completeAction = buttonClicked.attr("id") == view.showButton().attr("id") ? renderListCutterResult : renderListCutterResultOnSave;
          view.listId().val(data.list_id);

          periodicalUpdater({
              url:pollUrl,
              resultId:data.intermediate_result_id,
              complete:completeAction
          });

      }, "json").error(renderError);

      view.html().animate({"scrollTop":view.listCutterResult().offset().top + 200 }, 1200);
      view.loadingIndicator().show();
      return false;
  }

  function renderError(jqxhr) {
    console.log('An error occurred on the list cutter: ' + jqxhr.responseText);
    renderListCutterResult('<p class="error">Oops! Something went wrong! :(</p>');
  }

  function renderListCutterResult(result) {
    var listCutterResult = view.listCutterResult();
    listCutterResult.html(result);
    listCutterResult.show();
    view.loadingIndicator().hide();
    view.showButton().removeAttr('disabled');
    view.saveButton().removeAttr('disabled');
  }

  function renderListCutterResultOnSave(result) {
      renderListCutterResult(result);
      $.get(view.saveButton().data("show-url"), {list_id:view.listId().val()}, function (body) {
          view.savedRecipients().html(body);
      });
  }

  function addFilter(rule) {
    var newFilter = newFromTemplate('filter');
    setFilterBindings(newFilter);
    if (rule) newFilter.find('.filter-by').val(rule).change();
    view.filtersContainer().append(newFilter);
  }

  function newFromTemplate(name) {
    var template = view.allTemplates().filter("[data-name='"+name+"']");
    return template.length ? $(Mustache.to_html(template.html())) : '';
  }

  function setFilterBindings(filter) {
    filter.find('.remove-filter').click(function() {
      filter.remove();
    });

    filter.find('.filter-by').change(function() {
      var rule = $(this).val();
      setFilterRule(filter, rule);
    });

    $.each(filter.find('.filter-by'), function(index, element){
      var ruleSpecificHandler = Purpose.ListCutter[element.value.replace('filter-','').trim()+'_selected'];
      if(ruleSpecificHandler) ruleSpecificHandler.init(filter);
    });
  }

  function attachDatePicker(filter) {
      $(filter).find(".datepicker").datepicker({
          dateFormat:"mm/dd/yy",
          changeMonth:true,
          changeYear:true,
          showOtherMonths:true,
          selectOtherMonths:true,
          maxDate:minimumBlastScheduleTime
      });

  }

  function attachAutoComplete(filter) {
    $(filter).find(".multiselectcheckbox").multiselectcheckbox({
        selectedList: 10,
        close: function(){
            $(this).trigger("focusout");
            if(this.id.indexOf("email_action") != -1){
              var multiSelect = $(this).multiselectcheckbox("widget");
              multiSelect.find(".root-opt-group").removeClass("lvl1");
              multiSelect.find(".ui-multiselectcheckbox-optgroup-label").removeClass("lvl2");
              multiSelect.find("label.ui-corner-all").removeClass("lvl3");
            }
        },
        open: function() {
          if(this.id.indexOf("email_action") != -1 || this.id.indexOf("action_taken") != -1){
            var multiSelect = $(this).multiselectcheckbox("widget");
            multiSelect.find(".root-opt-group").addClass("lvl1");
            multiSelect.find(".ui-multiselectcheckbox-optgroup-label").addClass("lvl2");
            multiSelect.find("label.ui-corner-all").addClass("lvl3");

          }
        }
    }).multiselectcheckboxfilter();
  }

  function setFilterRule(filter, rule) {
    filter.rule = rule;
    var filterType = newFromTemplate(rule);
    filter.find('.list-cutter-filter-value').html(filterType);
    filter.find("input[type='checkbox']").attr("checked", "checked");
    updateInputsIndex(filter);
    attachDatePicker(filter);
    attachAutoComplete(filter);
    var ruleSpecificHandler = Purpose.ListCutter[rule.replace('filter-','').trim()+'_selected'];
    if(ruleSpecificHandler) ruleSpecificHandler.bind(filter);
  }

  function updateInputsIndex(filter) {
    _.each(filter.find("input"), function (element) {
      setElementIndex(element, filtersCount);
    });
    _.each(filter.find("select"), function (element) {
      setElementIndex(element, filtersCount);
    });
    _.each(filter.find("label"), function (element) {
      setElementIndex(element, filtersCount);
    });
    filtersCount += 1;
  }

  function setElementIndex(element, index) {
    var currentName = $(element).attr("name");
    if (currentName) {
      var newName = currentName.replace("$index", index);
      $(element).attr("name", newName);
    }

    var currentId = $(element).attr("id");
    if (currentId) {
      var newId = currentId.replace("$index", index);
      $(element).attr("id", newId);
    }
    var currentFor = $(element).attr("for");
    if (currentFor) {
      var newFor = currentFor.replace("$index", index);
      $(element).attr("for", newFor);
    }
  }

  function periodicalUpdater(options) {
    if (options.resultId) initUpdater(options);
  }

  function initUpdater(options) {
    var pollForResults = function() {
      $.get(options.url, { result_id: options.resultId }, function(body, _, request) {
          if (request.status == 200) return options.complete(body);
          setTimeout(pollForResults, 1000);
      });
    };

    pollForResults();
  }

  return { init: initialize };
})();

Purpose.ListCutter.country_rule_selected = {
  init: function(filter){
    this.bind(filter);
    $(filter).find('.selected_by').change();
  },

  bind: function(filter){
    $(filter).find(".ui-multiselectcheckbox").hide();
    $(filter).find('.selected_by').change(function () {
      var selectTag;
      $(filter).find(".ui-multiselectcheckbox").hide();
      $(filter).find(".country_rule_values").hide();
      $(this).siblings('.country_rule_values').hide().attr('disabled', 'disabled').removeClass('required');
      selectTag = $(this).siblings('select[data-selected-by="' + this.value + '"]').removeAttr('disabled').addClass('required');
      if (selectTag.multiselectcheckbox("widget").hasClass("ui-multiselectcheckbox-menu")) {
        selectTag.next().show();
      } else {
        selectTag.show()
      }
    });
  }
}

Purpose.ListCutter.distance_from_point_rule_selected = {
  init: function(filter){
    this.bind(filter, true);
  },

  bind: function(filter, set_up_existing_filter){
    var map_settings = {
      center: new google.maps.LatLng(10, 1.75),
      zoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      styles: [ 
        { 
          featureType: "poi.business", 
          elementType: "labels", 
          stylers: [ 
            { visibility: "off" } 
          ] 
        },
        { 
          featureType: "poi.place_of_worship", 
          elementType: "labels", 
          stylers: [ 
            { visibility: "off" } 
          ] 
        },
        { 
          featureType: "poi.attraction", 
          elementType: "labels", 
          stylers: [ 
            { visibility: "off" } 
          ] 
        },
        { 
          featureType: "poi.school", 
          elementType: "labels", 
          stylers: [ 
            { visibility: "off" } 
          ] 
        },
        { 
          featureType: "poi.sports_complex", 
          elementType: "labels", 
          stylers: [ 
            { visibility: "off" } 
          ]
        }
      ]
    }

    var gmap, marker, circle;

    var distance_from_point_rule_inputs = $(filter).find('.distance_from_point_rule_inputs');
    var distance_input = $(filter).find('.distance_from_point_rule_number_input');
    var distance_unit_input = $(filter).find('.distance_from_point_distance_unit_select');
    var coordinate_field_lat = $(filter).find('.coordinate_fields input.lat');
    var coordinate_field_lng = $(filter).find('.coordinate_fields input.lng');

    function updateLatLng(event) {
      coordinate_field_lat.val(event.latLng.lat());
      coordinate_field_lng.val(event.latLng.lng());
    }

    function placeMarker(location) {
      if ( marker ) {
        marker.setPosition(location);
      } else {
        marker = new google.maps.Marker({
          position: location,
          map: gmap,
          draggable: true
        });
      }

      google.maps.event.addListener(marker, 'drag', function(event) {
        updateLatLng(event);
      });
    }

    function getRadius() {
      // in metres
      var distance, distance_unit, radius;

      var units_in_meters = {
        miles: 1609.34,
        kilometers: 1000
      }

      distance = parseFloat( distance_input.val() );
      distance_unit = distance_unit_input.val();

      if ( distance ){
        unit_in_meters = units_in_meters[distance_unit];
        radius = (unit_in_meters * distance);
      }

      return radius;
    }

    function setCircle(radius) {
      if ( !circle ) {
        circle = new google.maps.Circle({
          map: gmap,
          radius: radius,
          fillColor: '#AA0000',
          strokeColor: '#555'
        });
      } else {
        circle.setRadius(radius);
        circle.setMap(gmap);
      }

      if ( marker ) {
        circle.bindTo('center', marker, 'position');
      }
    }

    function unsetCircle() {
      if ( circle ) { circle.setMap(null) };
    }

    function createMap() {
      gmap = new google.maps.Map($(filter).find('.distance_from_point_rule_map')[0], map_settings);

      google.maps.event.addListener(gmap, 'click', function(event) {
        placeMarker(event.latLng);
        updateLatLng(event);
        unsetCircle();
        displayControls();
      });
    }

    function displayControls() {
      $(filter).find('.distance_from_point_rule_instructions').hide();

      if ( distance_from_point_rule_inputs.hasClass('hidden') ) {
        distance_from_point_rule_inputs.fadeIn(500).removeClass('hidden').effect("highlight", {}, 3000);
      }
    }

    function setupControls() {
      if ( !distance_input.val() ) {
        distance_from_point_rule_inputs.addClass('hidden').hide();
      }

      distance_input.on('input', function() {
        setCircle(getRadius());
      });

      distance_unit_input.change(function() {
        setCircle(getRadius());
      });
    }

    createMap();
    setupControls();

    if ( set_up_existing_filter ) {
      var lat_lng = new google.maps.LatLng(coordinate_field_lat.val(), coordinate_field_lng.val())

      displayControls();
      placeMarker(lat_lng);
      setCircle(getRadius());
      gmap.setCenter(lat_lng);
      gmap.fitBounds(circle.getBounds());
    }
  }
}

$.page("#list_cutter_edit", "#list_cutter_new", function () {
  var view = View({
    allTemplates: "script[type='text/template']",
    ruleTemplates: "script[type='text/template'][data-rule]",
    filtersContainer: ".list-cutter-filters",
    filters: ".list-filter",
    addFilter: ".filter-actions .add-filter",
    resultsContainer: "#list-cutter-results",
    loadingIndicator: ".loading",
    showButton: "#show-count",
    saveButton: "#save-count",
    savedRecipients: "#saved-recipients",
    listCutterResult: ".list-cutter-result",
    listForm: "#listForm",
    listId: "#list_id",
    html: "html"
  });

  Purpose.ListCutter.init(view);
});
