@group1
Feature: Ensure users have the correct access to parts of the application

  Background:
    Given I run the seed task
    And the following users exist:
      | Email                     | Role       |
      | admin@yourdomain.com         | admin      |
      | campaigner@yourdomain.com    | campaigner |
      | mike@example.com          | member     |
      | eviluser@evil.example.com |            |

  @javascript
  Scenario Outline: Roles with access to admin section
    Given I am logged in as "<Email>"
    When I go to the home page
    Then I should see <Login Results>
    When I go to the page with URL "/admin"
    Then I should be on the page with URL <Destination>
    And I should see <Message>

  Examples:
    | Email                     | Login Results               | Destination               | Message                  |
    | admin@yourdomain.com         | "Some"        | "/admin"                  | "Log Out"                |
    | campaigner@yourdomain.com    | "Some"    | "/admin"                  | "Log Out"                |
    | mike@example.com          | ""                          | "/platform_users/sign_in" | "Forgot your password?"  |
    | eviluser@evil.example.com | ""                          | "/platform_users/sign_in" | "Forgot your password?"  |

  @javascript
  Scenario Outline: Viewing left navigation menu links
    Given I have a movement named "Rainforests" with campaign "Save the rainforests"
    And I am logged in as <Role> with "<Email>" on movement "Rainforests"
    And I am on the "Rainforests" movement page
    And I should see <Menu Items> links

  Examples:
    | Role       | Email                  | Menu Items                                         |
    | admin      | admin@yourdomain.com      | Assets, Campaigns, Content Pages, Featured Items, Homepage, Images, Users, Settings, Site Activity, Snapshot |
    | campaigner | campaigner@yourdomain.com | Assets, Campaigns, Content Pages, Featured Items, Images, Site Activity, Snapshot           |


