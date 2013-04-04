
describe("dirty form", function() {

  describe("show message", function() {

    beforeEach(function () {
      $("body").append("<form id='the-form' style='visibility:hidden' onsubmit='return false'><input id='some-form-input' type='text' value='initial'><input type='submit' id='form-submit'><span id='notify'>should not be default</span></form>");
    });

    afterEach(function () {
      $("#the-form").remove();
    });

    it("should show message indicating form is dirty when appropriate", function () {

      $("#the-form").dirty_form({
        notify: {
          selector: "#notify",
          message: "This form is dirty"
        },
        unless: {
          action: "click",
          selector: "input[type=submit]"
        }
      });


      $("#some-form-input").val("not the initial value");
      $("#some-form-input").change();

      expect($("#notify").html()).toBe("This form is dirty");

      $("#the-form input[type=submit]").click();
      expect($("#notify").html()).toBe("");

    });

    it("should use the appropriate callbacks when form is clean or dirty", function () {
        var dirty_form_opts = {
            notify: {
              selector: "#notify",
              message: "This form is dirty"
            },
            unless: {
              action: "click",
              selector: "input[type=submit]"
            },
	    callback: function (dirty) {}
          };

      $("#the-form").dirty_form(dirty_form_opts);

      sinon.spy(dirty_form_opts, "callback");

      $("#some-form-input").val("not the initial value");
      $("#some-form-input").change();

      expect(dirty_form_opts.callback).toHaveBeenCalledWith(true);

      $("#the-form input[type=submit]").click();
      expect(dirty_form_opts.callback).toHaveBeenCalledWith(false);

    });


  });
});
