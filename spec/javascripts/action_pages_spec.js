describe('Action Pages', function() {

	beforeEach(function() {
		jasmine.getFixtures().load("action_page_autofire_email.html");
		this.checkbox = $('.autofire_email_enabled');
		this.details = $('.autofire_email_details');
	});

	describe('When initializing', function() {
		it('should hide the email fields when the autofire option is not selected', function() {
			this.checkbox.removeAttr('checked');
			$(this.checkbox).toggleFields(this.details);
			expect(this.details.is(':visible')).toBe(false);
		});

		it('should show the email fields when the autofire option is selected', function() {
			this.checkbox.attr('checked', true);
			$(this.checkbox).toggleFields(this.details);
			expect(this.details.is(':visible')).toBe(true);
		});
	});

	describe('On change', function() {
		it('should hide the email fields when the autofire option is deselected', function() {
			this.checkbox.attr('checked', true);
			$(this.checkbox).toggleFields(this.details);

			this.checkbox.removeAttr('checked').change();
			expect(this.details.is(':visible')).toBe(false);
		});

		it('should show the email fields when the autofire option is selected', function() {
			this.checkbox.removeAttr('checked');
			$(this.checkbox).toggleFields(this.details);

			this.checkbox.attr('checked', true).change();
			expect(this.details.is(':visible')).toBe(true);
		});
	});

});