@wip @admin @search
Feature: Managing user roles
  In order to put someone in charge of a movement
  As an admin
  I want to add role(s) for a platform user

  Background:
    Given I run the seed task
    Given I have a small sample set of platform users

  Scenario: Selecting a role as a platform admin
    Given I have the reference languages in the platform
    And I have movements named "Save the Kitties" with the languages "Portuguese,Spanish"
    And I am logged into the platform as a platform admin
    And I am on the edit admin user page for "target1@yourdomain.org"
    When I select the following roles:
      | movement         | role       |
      | Save the Kitties | Campaigner |
    And I save my changes
    Then the user "target1@yourdomain.org" should have the following roles:
      | movement         | role       |
      | Save the Kitties | Campaigner |

  @javascript
  Scenario: Selecting a role as a movement admin
    Given I have the reference languages in the platform
    And I have movements named "Save the Kitties" with the languages "Portuguese,Spanish"
    And "target2@yourdomain.org" is a movement administrator for "Save the Kitties"
    And "target2@yourdomain.org" is logged into the platform as a platform user
    And I am on the edit admin user page for "target1@yourdomain.org" in "Save the Kitties"
    When I select the following roles:
      | movement         | role       |
      | Save the Kitties | Campaigner |
    And I save my changes
    Then the user "target1@yourdomain.org" should have the following roles:
      | movement         | role       |
      | Save the Kitties | Campaigner |


  Scenario: Movement admin attempting to assign the platform admin role
    Given I have the reference languages in the platform
    And I have movements named "Save the Kitties" with the languages "Portuguese,Spanish"
    And "target2@yourdomain.org" is a movement administrator for "Save the Kitties"
    And "target2@yourdomain.org" is logged into the platform as a platform user
    And I am on the edit admin user page for "target1@yourdomain.org"
    Then I should not be able to set the platform admin role
