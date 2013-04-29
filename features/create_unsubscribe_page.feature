@group1
Feature: Add an unsubscribe action sequence in a campaign so that the user can stop receiving emails.

  Background:
    Given I run the seed task
    And I am logged into the platform as a platform admin

  Scenario: Add an unsubscribe page
    Given I am in "Dummy Movement" homepage
    And I follow "Campaigns"
    And I follow "Walruses"
    And I follow "Walrus MP Call"
    And I create a new page action with Unsubscribe named "UnsubscribePage"
    And I goto action Page  UnsubscribePage
    And I enter button name as Unsubscribe Button
    And I add HTML for Header content
    And I enter my information for the header content as This is header content
    And I add HTML for Main content
    And I enter my information for the Main content as This is main content
    And I Save Page
    And then I go to "Dummy Movement" homepage
    And I follow "Campaigns"
    Then I should see "UnsubscribePage"