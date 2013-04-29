@group3 @admin @javascript
Feature: Managing content pages
  As a campaigner
  I want to add content pages
  So that a movement has common pages across the site

  Background:
    Given I am an admin for the movement "All Out"
    And the "All Out" movement has a content page collection called "Jobs"

  Scenario: Create a new content page
    When I create a new content page called "Contact Us!" in the "Jobs" collection
    Then I should see that the "Jobs" collection has a page called "Contact Us!"

  Scenario: Add content modules to a content page
    Given I create a new content page called "Work with us!" in the "Jobs" collection
    When I edit the content page "Work with us!"
    And I add a new HTML module to the header container
    And I fill in the content of the HTML module on the header for "English" with "Come work with us!"
    And I press "Save page"
    Then I wait 3 seconds
    And there should be an HTML module with content "Come work with us!" on the header of the "Work with us!" page in "English"
    And there should be an HTML module for each language on the header of the "Work with us!" page

  Scenario: Delete an existing content page
    Given the "Jobs" content page collection contains a content page named "Work with us!"
    When I edit the content page "Work with us!"
    And I click "OK" after following "Delete"
    Then I should see that the "Jobs" collection does not have a page called "Work with us!"