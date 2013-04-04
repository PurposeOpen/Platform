describe("Purpose.ActionSequence", function () {

  function simulateToggle(checkBox) {
    toggleCheckBox(checkBox);
  }

  describe("#init", function () {
    afterEach(function () {
      function restoreSpiedFunctionIfNeeded(f) {
        f.restore && f.restore();
      }
      restoreSpiedFunctionIfNeeded(view.publishedStatusForm().submit);
      restoreSpiedFunctionIfNeeded(view.languageToggleForm().submit);
    });

    it("should submit form to publish an action sequence", function () {
      view = stubView({publishedToggled: false});
      sinon.spy(view.publishedStatusForm(), 'submit');
      Purpose.ActionSequence.init(view);
      
      simulateToggle(view.publishedToggle());

      expect(view.publishedStatusForm().find('[name="published"]').val()).toEqual("true");
      expect(view.publishedStatusForm().submit).toHaveBeenCalled();
    });

    it("should submit form to unpublish an action sequence", function () {
      view = stubView({publishedToggled: true});
      sinon.spy(view.publishedStatusForm(), 'submit');
      Purpose.ActionSequence.init(view);
      
      simulateToggle(view.publishedToggle());
      
      expect(view.publishedStatusForm().find('[name="published"]').val()).toEqual("false");
      expect(view.publishedStatusForm().submit).toHaveBeenCalled();
    });

    it("should submit form to enable a language", function () {
      view = stubView({publishedToggled: false, portugueseToggled: false});
      sinon.spy(view.languageToggleForm(), 'submit');
      Purpose.ActionSequence.init(view);

      simulateToggle(view.toggleForLanguage("pt"));

      expect(view.languageToggleForm().find('[name="iso_code"]').val()).toEqual("pt");
      expect(view.languageToggleForm().find('[name="enabled"]').val()).toEqual("true");
      expect(view.languageToggleForm().submit).toHaveBeenCalled();
    });

    it("should submit form to disable a language", function () {
      view = stubView({publishedToggled: true});
      sinon.spy(view.languageToggleForm(), 'submit');
      Purpose.ActionSequence.init(view);

      simulateToggle(view.toggleForLanguage("en"));

      expect(view.languageToggleForm().find('[name="iso_code"]').val()).toEqual("en");
      expect(view.languageToggleForm().find('[name="enabled"]').val()).toEqual("false");
      expect(view.languageToggleForm().submit).toHaveBeenCalled();
    });

    it("should automatically unpublish the action sequence when the last enabled language is disabled", function () {
      view = stubView({publishedToggled: true, englishToggled: true, portugueseToggled: false});
      sinon.spy(view.languageToggleForm(), 'submit');
      sinon.spy(view.publishedStatusForm(), 'submit');
      Purpose.ActionSequence.init(view);

      simulateToggle(view.toggleForLanguage("en"));

      expect(view.publishedToggle().attr("checked")).toBeUndefined();
      expect(view.publishedStatusForm().find('[name="published"]').val()).toEqual("false");
      expect(view.publishedStatusForm().submit).toHaveBeenCalled();
    });

    it("should not automatically publish the action sequence when the last enabled language is disabled", function () {
      view = stubView({publishedToggled: false, englishToggled: true, portugueseToggled: false});
      sinon.spy(view.languageToggleForm(), 'submit');
      sinon.spy(view.publishedStatusForm(), 'submit');
      Purpose.ActionSequence.init(view);

      simulateToggle(view.toggleForLanguage("en"));

      expect(view.publishedToggle().attr("checked")).toBeUndefined();
      expect(view.publishedStatusForm().submit).not.toHaveBeenCalled();
    });
  });

  it("should show the published message when the action sequence is published is on", function () {
    view = stubView({publishedToggled: false});
    Purpose.ActionSequence.init(view);

    simulateToggle(view.publishedToggle());

    expect(view.publishedMessage().css("display")).not.toEqual("none");
    expect(view.unpublishedMessage().css("display")).toEqual("none");
  });

  it("should show the unpublished message when the action sequence is unpublished", function () {
    view = stubView({publishedToggled: true});
    Purpose.ActionSequence.init(view);

    simulateToggle(view.publishedToggle());

    expect(view.unpublishedMessage().css("display")).not.toEqual("none");
    expect(view.publishedMessage().css("display")).toEqual("none");
  });
  
  function stubView(toggleState) {
    toggleState = $.extend({}, {
      publishedToggled: true,
      englishToggled: true,
      portugueseToggled: true
    }, toggleState);

    var view = FakeView.stub({
      publishedStatusForm: FakeView.form({
        contains: [FakeView.hidden({name: "published"})]
      }),
      publishedToggle: FakeView.checkBox({checked: toggleState.publishedToggled}),
      publishedMessage: FakeView.p({classes: ["published_message"], css: {display: "block"}}),
      unpublishedMessage: FakeView.p({classes: ["unpublished_message"], css: {display: "none"}}),

      languageToggleForm: FakeView.form({
        contains: [
          FakeView.hidden({name: "iso_code"}),
          FakeView.hidden({name: "enabled"})
        ]
      }),
      languageToggles: [
        FakeView.checkBox({id: "enabled_languages_en", value: "en", checked: toggleState.englishToggled}),
        FakeView.checkBox({id: "enabled_languages_pt", value: "pt", checked: toggleState.portugueseToggled})
      ]
    });
    
    view.toggleForLanguage = function (isoCode) {
      switch (isoCode) {
        case "en": return $(view.languageToggles()[0]);
        case "pt": return $(view.languageToggles()[1]);
      }
    };

    return view;
  }
});