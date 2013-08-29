@group5 @admin @search
Feature: Manage users
  In order to control access to the website
  As an admin
  I want to manage users of the system

  Background:
    Given I run the seed task
    And I am logged into the platform as a platform admin
    And I have a small sample set of platform users

  Scenario: Users option should be listed in root page
    Given I am on the admin root page
    Then I should see "Users"

  Scenario: Show list of users
    Given I am on the admin root page
    And I follow "Users"
    Then I should see "4 users"

  Scenario: Search user on email address
    Given I am on the admin root page
    And I follow "Users"
    Then I fill in "query" with "target1@yourdomain.org"
    Then I press "search_button"
    Then I should see "1 user"

  Scenario: Search users on first name
    Given I am on the admin root page
    And I follow "Users"
    Then I fill in "query" with "first_name1"
    Then I press "search_button"
    Then I should see "1 user"

  Scenario: Search users on last name
    Given I am on the admin root page
    And I follow "Users"
    Then I fill in "query" with "last_name1"
    Then I press "search_button"
    Then I should see "1 user"

  Scenario: Search users on member id
    Given I am on the admin root page
    And I follow "Users"
    Then I fill in "query" with the platform user id of "chrisanthemum@example.com"
    Then I press "search_button"
    Then I should see details for the platform user "chrisanthemum@example.com"

  Scenario: Search users on full name
    Given I am on the admin root page
    And I follow "Users"
    When I fill in "query" with "Chris Anthemum"
    And I press "search_button"
    Then I should see "1 user"
    And I should see "Chris Anthemum"

  Scenario: Create a user with valid details
    Given I am on the admin root page
    And I follow "Users"
    And I follow "New User"
    Then I fill in "user[email]" with "colonelbobson@shangrila.com"
    And I check "user[is_admin]"
    Then I press "Create"
    And I should see "colonelbobson@shangrila.com"

  Scenario: Create a user with invalid details
    Given I am on the admin root page
    And I follow "Users"
    Then I follow "New User"
    Then I fill in "user_first_name" with "Roger"
    Then I fill in "user_last_name" with "Simonson"
    Then I press "Create"
    Then I should have form validation errors

  Scenario: Creating a user and cancelling before saving
    Given I am on the "dummy-movement" users page
    Then I follow "New User"
    Then I fill in "user_email" with "colonelbobson@shangrila.com"
    Then I follow "Cancel"
    Then I should be on the "dummy-movement" users page

  Scenario: Editing the details of a user
    Given I am on the "dummy-movement" users page
    And I follow "target1@yourdomain.org"
    Then I fill in "user_email" with "target_modified@yourdomain.org"
    And I fill in "user_first_name" with "Gherkin"
    And I fill in "user_last_name" with "Clock"
    Then I press "Save"
    Then I should be on the "dummy-movement" users page
    Then I should see "target_modified@yourdomain.org"
    And I should see "Gherkin Clock"

  Scenario: Making someone a Platform Admin
    Given I am on the "dummy-movement" users page
    And I follow "target1@yourdomain.org"
    And I check "user_is_admin"
    Then I press "Save"
    Then I should be on the "dummy-movement" users page
    And I follow "target1@yourdomain.org"
    And the "user_is_admin" checkbox should be checked

  Scenario: Setting user roles for movements
    Given I have the reference languages in the platform
    And I have movements named "Save the Kitties" with the languages "Portuguese,Spanish"
    And I am logged into the platform as a platform admin
    And I follow "Users"
    And I follow "target1@yourdomain.org"
    When I select the following roles:
      | movement         | role       |
      | Save the Kitties | Campaigner |
    And I save my changes
    Then the user "target1@yourdomain.org" should have the following roles:
      | movement         | role       |
      | Save the Kitties | Campaigner |

