
describe("list cutter", function() {

  describe("list cutter maybe definition list", function () {

    beforeEach(function() {
      jasmine.getFixtures().fixturesPath = "/__spec__/fixtures/";
      jasmine.getFixtures().load("list_cutter.html");
      scope = $(".list-cutter-filters");

      var view = View({
        allTemplates: "script[type='text/template']",
        ruleTemplates: "script[type='text/template'][data-rule]",
        filtersContainer: ".list-cutter-filters",
        filters: ".list-filter",
        addFilter: ".filter-actions .add-filter",
        resultsContainer: "#list-cutter-results",
        loadingIndicator: ".loading",
        showButton: "#show-count",
        listCutterResult: ".list-cutter-result",
        listForm: "#listForm",
        listId: "#list_id",
        html: "html"
      });

      Purpose.ListCutter.init(view);
    });	 

    describe("adding filters", function () {
      beforeEach(function() {
        add_filter_button = $(".filter-actions .add-filter");
      });

      it("should add a new empty filter when new is clicked", function () {
      	expect(scope.find("div.list-filter").size()).toBe(1);
      	add_filter_button.click();
      	add_filter_button.click();
        add_filter_button.click();
        expect(scope.find("div.list-filter").size()).toBe(4);  
      });

      it("should append the correct fieldset based on the selected filter type", function () {
        add_filter_button.click();
        add_filter_button.click();

      	var filter_elem = scope.find(">div.list-filter:first > li");
      	expect(scope.size()).toBe(1);
       	filter_elem.find("option[value=filter-email_domain_rule]").prop("selected", true);
      	filter_elem.find("option[value=filter-postcode_within_rule]").prop("selected", true);
        expect(filter_elem.find("option[value=filter-postcode_within_rule]").prop("selected")).toBe(true);
      	// and trigger the change event
      	filter_elem.find("select").change();
      	var filter_elem_choice = filter_elem.find("ul.list-cutter-filter-value div.list-filter > li");
        expect(scope.find(".choose-postcode_within_rule").size()).toBe(1);
      	expect(filter_elem_choice.attr("class")).toBe("choose-postcode_within_rule");
      	expect(filter_elem_choice.find("input[type='text']").hasClass("required")).toBeTruthy();
      });

      it("should delete current row when selection changed to new option", function () {
        add_filter_button.click();
        add_filter_button.click();
        first_li = scope.find(">li:first");
        first_li.find("option[value=filter-email_domain_rule]").prop("selected", true);
        first_li.find("select").change();
        $("input#email_domain").val("test value");
        first_li.find("option[value=filter-postcode_within_rule]").prop("selected", true);
        first_li.find("select").change();
        expect($(".choose-email_domain_rule .required-if-present").hasClass("required")).toBeFalsy();
        expect($("input#rules_email_domain_rule_domain").val()).toBeUndefined();
      });

      it("should delete a row when delete button clicked", function () {
          add_filter_button.click();
          add_filter_button.click();
          
          first_li = scope.find(">div.list-filter:first > li");
          first_li.find("option[value=filter-email_domain_rule]").prop("selected", true);
          first_li.find("select").change();
          $("input#email_domain").val("this is a test");
          first_li.find("span.remove-filter").click();
          expect(scope.find(">div.list-filter > li").size()).toBe(2);
          
          scope.find(">div.list-filter > li:first span.remove-filter").click();
          expect($(".choose-email_domain_rule .required-if-present").hasClass("required")).toBeFalsy();
          expect($("input#rules_email_domain_rule_domain").val()).toBeUndefined();
      });

      it("should allow multiple filters of the same type to be selected", function () {
        add_filter_button.click();
	      add_filter_button.click();
        add_filter_button.click();
        var filter_elem_email = $($("ul.list-cutter-filters > div.list-filter > li").get(0));
        var filter_elem_a = $($("ul.list-cutter-filters > div.list-filter > li").get(1));
        var filter_elem_b = $($("ul.list-cutter-filters > div.list-filter > li").get(2));

        filter_elem_b.find("option[value=filter-postcode_within_rule]").prop("selected",true);
        filter_elem_b.find("select").change();
        filter_elem_email.find("option[value=filter-email_domain_rule]").prop("selected", true);
        filter_elem_email.find("select").change();

        expect(filter_elem_a.find("option[value=filter-postcode_within_rule]").prop("disabled")).toBe(false);
        expect(filter_elem_b.find("option[value=filter-email_domain_rule]").prop("disabled")).toBe(false);
      });

      it("should check the 'activated' checkbox for each filter added", function () { 
        add_filter_button.click();
        var filter_elem = $($("ul.list-cutter-filters > div.list-filter > li").get(0));
        filter_elem.find("option[value=filter-postcode_within_rule]").prop("selected", true);
        filter_elem.find("select").change();
        expect(filter_elem.find("input[id='rules_postcode_within_rule_0_activate']").prop("checked")).toBe(true);
      });

      describe("the added filter is the only one of its type", function () {
        it("should ensure the filter's inputs have index set to zero", function () {
          add_filter_button.click();
          
          var filter_elem = $($("ul.list-cutter-filters > div.list-filter > li").get(0));
          filter_elem.find("option[value=filter-email_domain_rule]").prop("selected", true);
          filter_elem.find("select").change();
          
          var domain_input_field = filter_elem.find("input[name='rules[email_domain_rule][0][domain]']");
          expect(domain_input_field.length).toEqual(1);

          var negate_select_field = filter_elem.find("select[name='rules[email_domain_rule][0][not]']");
          expect(negate_select_field.length).toEqual(1);

          var activated_hidden_field = filter_elem.find("input[name='rules[email_domain_rule][0][activate]']");
          expect(activated_hidden_field.length).toBeGreaterThan(0);
        });
      });

      describe("the added filter is the second one of its type", function () {
        it("should ensure the filter's inputs have index set to one", function () {
          add_filter_button.click();
          add_filter_button.click();
          
          var first_filter_elem = $($("ul.list-cutter-filters > div.list-filter > li").get(0));
          var second_filter_elem = $($("ul.list-cutter-filters > div.list-filter > li").get(1));
          
          first_filter_elem.find("option[value=filter-email_domain_rule]").prop("selected", true);
          first_filter_elem.find("select").change();

          second_filter_elem.find("option[value=filter-email_domain_rule]").prop("selected", true);
          second_filter_elem.find("select").change();
          
          var domain_input_field = second_filter_elem.find("input[name='rules[email_domain_rule][1][domain]']");
          expect(domain_input_field.length).toEqual(1);

          var negate_select_field = second_filter_elem.find("select[name='rules[email_domain_rule][1][not]']");
          expect(negate_select_field.length).toEqual(1);

          var activated_hidden_field = second_filter_elem.find("input[name='rules[email_domain_rule][1][activate]']");
          expect(activated_hidden_field.length).toBeGreaterThan(0);
        });
      });
    });
  });
});
