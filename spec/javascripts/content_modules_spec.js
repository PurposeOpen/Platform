describe('Content Modules', function() {
  var stubs = {
    html: {
      en: '<div data-lang="en">html module snippet</div>',
      pt: '<div data-lang="pt">pedaco de um modulo html</div>'
    },

    accordion: {
      en: '<div data-lang="en">accordion module snippet</div>',
      pt: '<div data-lang="pt">pedaco de um modulo sanfona</div>'
    }
  };

  stubs.html.full = stubs.html.en + stubs.html.pt;
  stubs.accordion.full = stubs.accordion.en + stubs.accordion.pt;

  beforeEach(function() {
    jasmine.getFixtures().load("edit_petition.html");
    jQuery.fn.tabs = sinon.spy();

    var view = Purpose.ContentModules.createView("#page_root");
    Purpose.ContentModules.init(view);

    this.buttonAddModule = function(language, container, type) {
      return view.layoutTypeContainer(language, container).find(".add-module-link." + type + "_module");
    };

    this.contentsOf = function(language, container) {
      return view.modulesContainer(language, container).html();
    };
  });

  describe("adding a new content module", function() {
    it('should add a new HTML module to the correct language tab', function() {
      this.buttonAddModule('en', 'main_content', 'html').trigger('ajax:success', stubs.html.full);
      expect(this.contentsOf('en', 'main_content')).not.toEqual("");
      expect(this.contentsOf('en', 'main_content')).toEqual(stubs.html.en);
    });

    it('should add a new accordion module to the correct language tab', function() {
      this.buttonAddModule('en', 'main_content', 'accordion').trigger('ajax:success', stubs.accordion.full);
      expect(this.contentsOf('en', 'main_content')).not.toEqual("");
      expect(this.contentsOf('en', 'main_content')).toEqual(stubs.accordion.en);
    });

    describe('with multiple module types and languages', function() {
      it('should add a new module to the sibling .modules_container only', function() {
        this.buttonAddModule('en', 'header_content', 'accordion').trigger('ajax:success', stubs.accordion.full);
        this.buttonAddModule('en', 'main_content', 'html').trigger('ajax:success', stubs.html.full);

        expect(this.contentsOf('en', 'header_content')).toEqual(stubs.accordion.en);
        expect(this.contentsOf('en', 'header_content')).not.toMatch(stubs.html.en);

        expect(this.contentsOf('en', 'main_content')).toMatch(stubs.html.en);
        expect(this.contentsOf('en', 'main_content')).not.toMatch(stubs.accordion.en);
      });

      it('should add a new module to the correspondent module container in every language available', function() {
        this.buttonAddModule('en', 'header_content', 'html').trigger('ajax:success', stubs.html.full);

        expect(this.contentsOf('en', 'header_content')).toMatch(stubs.html.en);
        expect(this.contentsOf('pt', 'header_content')).toMatch(stubs.html.pt);
      });
    });
  });
});