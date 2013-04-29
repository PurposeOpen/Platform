@group4 @admin
Feature: Managing pages and action sequence
  In order to add content to the web site
  As a campaigner
  I want to create action sequence for campaigns

  Background:
    Given I run the seed task
    Given I am logged into the platform as a platform admin

  Scenario: View list of action sequence
    When I visit the "Forestry" campaign page
    Then I should see "Forestry"
    And I should see "Gunns Petition"
    And I should see "Landing Page for Gunns Petition"
    And I should see "Thankyou Page for Gunns Petition"

  Scenario: Add an action sequence
    When I visit the "Forestry" campaign page
    And I follow "Add an action sequence"
    And I fill in "Name" with "Pulp Mill Woes"
    And I press "Create action sequence"
    Then I should be on the admin action sequence page for "Pulp Mill Woes"
    And I should see "Pulp Mill Woes"

  @javascript
  Scenario: Duplicate an action sequence
    When I visit the "Forestry" campaign page
    And I follow "Duplicate" for "Gunns Petition" action sequence
    Then I should see "Gunns Petition(1)"
    Then I should be on the admin campaign page for "Forestry"
    Then I visit the "Gunns Petition(1)" action sequence page
    Then I should be on the admin action sequence page for "Gunns Petition(1)"
    Then I should see "Landing Page for Gunns Petition"
    And I should see "Thankyou Page for Gunns Petition"

  @javascript
  Scenario: Duplicate of a duplicate action sequence
    When I visit the "Forestry" campaign page
    And I follow "Duplicate" for "Gunns Petition" action sequence
    Then I should see "Gunns Petition(1)"
    And I follow "Duplicate" for "Gunns Petition(1)" action sequence
    Then I should see "Gunns Petition(2)"

  @javascript
  Scenario: Duplicating a page when an unrenamed duplicate exists
    When I visit the "Forestry" campaign page
    And I follow "Duplicate" for "Gunns Petition" action sequence
    Then I should see "Gunns Petition(1)"
    And I follow "Duplicate" for "Gunns Petition" action sequence
    Then I should see "Gunns Petition(2)"

  @javascript
  Scenario: Deleting an action sequence
    When I visit the "Forestry" campaign page
    And I follow "Gunns Petition"
    And I click "No" after following "Delete"
    Then I should not see "'Gunns Petition' has been deleted"
    When I click "Yes" after following "Delete"
    Then I should see "'Gunns Petition' has been deleted"
    And "Gunns Petition" should no longer be listed as a action sequence

  @javascript
  Scenario: Add pages to a sequence
    When I visit the "Gunns Petition" action sequence page
    And I follow "Add a page"
    And I fill in "Page Title" with "Petition page for Gunns"
    And I press "Create page"
    Then I should be on the admin action sequence page for "Gunns Petition"
    And I should see "'Petition page for Gunns' has been created."

  @javascript
  Scenario: Deleting a Page
    When I visit the "Forestry" campaign page
    And I follow "Gunns Petition"
    When I follow "Landing Page for Gunns Petition"
    And I click "No" after following "Delete"
    Then I should not see "'Landing Page for Gunns Petition' has been deleted"
    When I click "Yes" after following "Delete"
    Then I should see "'Landing Page for Gunns Petition' has been deleted"
    And I should not see "Landing Page for Gunns Petition" within "#pages_list"

  @javascript
  Scenario: Create a petition page and preview it
    When I visit the "Forestry" campaign page
    And I add a Test Sequence Automation action sequence
    And I create a new page action with Petition named Automation Petition
    And I enter the details required for creating the petition page Automation Petition
    And press "Save"
    And I preview the petition page for Automation Petition page