@group4 @admin
Feature: Manage Movements
  As a platform admin
  I want to be able to manage movements
  So that I can make changes to multiple movements in one place

  Background:
    Given I run the seed task
    And I have a small sample set of platform users

  Scenario: Viewing all movements available to a Platform Admin
    Given I have movements named "Save the Kitties,All Out,The Rules" with the languages "English,Spanish"
    And I am logged into the platform as a platform admin
    Then I should see "Save the Kitties,All Out,The Rules" as available movements

  Scenario: Viewing only movements I am an admin for if I am not a Platform Admin
    Given I have movements named "Save the Kitties,Save the Puppies,All Out,The Rules" with the languages "English,Spanish"
    And I am logged in as a non-admin "theadminuser@yourdomain.org" with the following roles:
      | movement         | role  |
      | Save the Kitties | admin |
    Then I should see "Save the Kitties"
    And I should not be able to view the "All Out" movement page
    And I should not be able to view the "The Rules" movement page

  Scenario: Adding a language
    Given I have the reference languages in the platform
    And I have movements named "Shake it!" with the languages "Portuguese,Spanish"
    And I am logged into the platform as a platform admin
    And I am on the "Shake it!" movement page
    When I follow "Settings"
    And I add "French" to the list of selected languages
    And I add "English" to the list of selected languages
    Then I should see "English,French,Portuguese,Spanish" as options for the default language
    When I remove "French" from the list of selected languages
    Then I should see "English,Portuguese,Spanish" as options for the default language
    And I choose "Portuguese" as the default language
    And I save the movement
    Then I should be on the "Shake it!" movement page
    Then I should see "3 languages: Portuguese (default), English, and Spanish"