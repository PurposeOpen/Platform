@group5
Feature: Smoke test to quickly check that main features are working

  Background:
    Given I run the seed task
    And a default Email
    And I am logged into the platform as a platform admin

  @javascript
  Scenario: Create a new movement and add a new campaign to it with a blast
    When I visit the "Forestry" campaign page
    And I create a Blast Campaign Automation campaign
    And I add a Blast Sequence Automation action sequence
    And I create a new page action with Join named Automation Join Module
    When I enter details for creating a join module Automation Join Module
    And I go back to the campaign Blast Campaign Automation
    When I add create a Automation Push push
    And I add a Automation Blast blast
    And I add new email Automation Email to the blast
    When I enter the details of the email
    And I send the mail for proofing to abc@yourdomain.com
    And I follow "Campaigns"
    And I search for Campaign Blast Campaign Automation
    And I select the Campaign Blast Campaign Automation from results
    Then I goto the push Automation Push
    And I select recipients
    When I select Country by Name
    And I select Country Name as Afghanistan
    And I save count and go to blast
    And I send email and schedule it for next day

    @javascript
    Scenario: Navigation through all pages on the platform side
     Then I check if I am logged into the platform
     When I navigate to Dummy Movement
     Then I check if I am on the movement home page for Dummy Movement
     And I follow "Settings"
     When I check for New User Emails button
     And I check for Email Footers button
     When I check for Cancel button
     And I follow "Campaigns"
     And I search for Campaign Forestry
     And I press submit button
     When I visit the "Forestry" campaign page
     Then I check for Delete button
     Then I check for Add an action sequence button
     Then I check for Add a push button
     Then I check for the statistics table
     And I check for TAF statistics table

  @javascript
  Scenario: Create a campaign, add Petition, add a TAF and an unsubscribe module and finally publish the campaign
    When I visit the "Forestry" campaign page
    And I add a Test Sequence Automation action sequence
    And I create a new page action with Petition named Automation Petition
    And I enter the details required for creating the petition page Automation Petition
    And I Save Page
    And I go back to the sequence Test Sequence Automation
    When I create a new page action with Tell A Friend named Automation Tell A Friend
    Then I go select Automation Tell A Friend
    And I wait for the page Automation Tell A Friend
    And I enter details required for creating the TAF page Automation Tell A Friend
    And I go back to the sequence Test Sequence Automation
    When I create a new page action with Unsubscribe named Automation Unsubscribe
    And I enter details required for creating the  Unsubscribe page Automation Unsubscribe
    And I go back to the sequence Test Sequence Automation
    And I publish the sequence
    And I enable languages English






















