@group2
Feature: Cut list based on different options

  Background:
    Given I run the seed task
    And a default Email
    And I am logged into the platform as a platform admin
    And I visit the "Forestry" campaign page
    And I follow "Dummy Push"
    And I select recipients

  Scenario: Cut a list by Country name
    Given I select Country by Name
    And I select Country Name as Seychelles
    When I check the member count
    Then I should see "Country Name is any of these: SEYCHELLES"

  Scenario: Cut a list by join date
    Given I filter Join Date by Before
    And I select today's date
    When I check the member count
    Then I should see Join Date is before today

  Scenario: Cut a list by Domain
    Given I select Domain
    And I fill in "rules[email_domain_rule][0][domain]" with "@gmail.com"
    When I check the member count
    Then I should see "Domain is gmail.com"