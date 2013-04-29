@group3
Feature: Managing campaigns
  In order to manage campaigns
  As a campaigner
  I want to be able to find, create, edit and delete them through the backend

  Background:
    Given I run the seed task
    Given I have a movement named "Conservation" with campaign "Narwhal conservation"
    Given I am logged in as a non-admin "campaigner@yourdomain.com" with the following roles:
      | movement     | role       |
      | Conservation | admin |
    And I am on the "Conservation" movement page

  @javascript
  Scenario: Creating a Campaign
    When I follow "Campaigns"
    And I follow "Create new campaign"
    And I fill in "Name" with "Save the kittens!"
    And I fill in "Description" with "Won't somebody think of the kittens?"
    And I press "Create campaign"
    Then I should see "'Save the kittens!' has been created."
    And I should be on the "Conservation" movement page

  @javascript
  Scenario: Deleting an existing campaign
    When I follow "Campaigns"
    And I follow "Narwhal conservation"
    And I click "No" after following "Delete"
    And I should not see "'Narwhal conservation' has been deleted"
    And I should be on the admin campaign page for "Narwhal conservation"
    When I click "Yes" after following "Delete"
    Then I should be on the "Conservation" movement page
    And I should see "'Narwhal conservation' has been deleted"
    And I follow "Campaigns"
    And I should not see "Narwhal conservation" within "#campaigns_index"
