describe("Editing a movement", function () {
    beforeEach(function () {
        jasmine.getFixtures().fixturesPath = "/__spec__/fixtures/";
        jasmine.getFixtures().load("edit_movement.html");

        Purpose.movements.initLanguagesMultiselectList({
            selectSelector:".multiselect",
            enableSelectedList:false
        });
    });

    it("should disable the list of selected languages", function () {
        expect($('div.ui-multiselect ul.selected a').length).toBe(0);
    });

    it("should update list in default language when selected languages change", function() {
        Purpose.movements.updateDefaultLanguages({
            element: '#movement_default_language',
            sourceElement: '#movement_languages',
            targetElements: '#languages-container ul.selected a, #languages-container ul.available a'
        });

        expect($('#movement_default_language option').length).toBe(2);

        $('ul.available li[title="French"] a').click();
        expect($('#movement_default_language option').length).toBe(3);
    });
});
