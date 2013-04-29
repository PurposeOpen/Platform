@group3 @search
Feature: Manage assets
  In order to manage online content
  As a campaigner
  I want to be able to upload assets for users to download
    
  Background:
    Given I run the seed task
    Given I am logged into the platform as a platform admin

  Scenario: Show no files
    Given I have 0 downloadable assets for the movement "Dummy Movement"
    When I am on the admin downloadable assets page for the movement "Dummy Movement"
    Then I should see "Files (0)"

  Scenario: Show one file
    Given I have 1 fixture downloadable assets for the movement "Dummy Movement"
    When I am on the admin downloadable assets page for the movement "Dummy Movement"
    Then I should see "Files (1)"

  Scenario: Show the limit (30) files
    Given I have 35 fixture downloadable assets for the movement "Dummy Movement"
    When I am on the admin downloadable assets page for the movement "Dummy Movement"
    Then I should see "Files (30)"
    And I should see a link labeled "Next →"

  Scenario: Upload a file
    Given I have 0 downloadable assets for the movement "Dummy Movement"
    When I am on the admin downloadable assets page for the movement "Dummy Movement"
    And I upload a fixture downloadable asset
    Then I should see "File uploaded. It may take up to 60 seconds for it to show up in search results."

  Scenario: Uploaded files are not accessible from different movements
    Given I have 0 downloadable assets for the movement "Dummy Movement"
    And I have 0 downloadable assets for the movement "Funny Movement"
    When I am on the admin downloadable assets page for the movement "Dummy Movement"
    And I upload a fixture downloadable asset
    And I go to the admin downloadable assets page for the movement "Funny Movement"
    Then I should see "Files (0)"

  Scenario: Searching for downloadable assets by link text
    Given I have 1 downloadable asset for the movement "Dummy Movement" with link text "Some Test File"
    And I have 1 downloadable asset for the movement "Dummy Movement" with link text "Another Test File"
    And I am on the admin downloadable assets page for the movement "Dummy Movement"
    When I fill in "query" with "Some"
    And I press "search_button"
    Then I should see "Files (1)"

  Scenario: Searching for downloadable assets by filename
    Given I have 1 downloadable asset for the movement "Dummy Movement" with filename "asset_foo.txt"
    And I have 1 downloadable asset for the movement "Dummy Movement" with filename "asset_bar.doc"
    And I am on the admin downloadable assets page for the movement "Dummy Movement"
    When I fill in "query" with "foo"
    Then I press "search_button"
    Then I should see "Files (1)"