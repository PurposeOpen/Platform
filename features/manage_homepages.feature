@group3 @admin
Feature: Managing homepages
  In order to keep the members informed
  As a movement admin
  I want to edit the homepage content

  Background:
    Given I run the seed task
    And I have the reference languages in the platform
    And I have movements named "Save the Wholphins" with the languages "English,Spanish"
    And the default language for "Save the Wholphins" is "English"
    And I am logged in as a non-admin "homepages@yourdomain.com" with the following roles:
      | movement           | role  |
      | Save the Wholphins | admin |

  @wip
  Scenario: Homepages available in all movement languages
    When I visit the "Save the Wholphins" homepage form
    Then I should see "English"
    And I should see "Spanish"

  @javascript
  Scenario: Creating a new homepage
    When I visit the "Save the Wholphins" homepage for "Spanish"
    And I fill in the "es" homepage form with:
      | banner_text | banner_image |
      | Banner!     | image.jpg    |
    And I save my changes
    Then I should see "Success"

  @javascript
  Scenario: Editing follow the movement links
    When I visit the "Save the Wholphins" homepage for "Spanish"
    And I fill in the "es" homepage form with:
      | follow_links_facebook | follow_links_twitter | follow_links_youtube |
      | http://facebook.com   | http://twitter.com   | http://youtube.com   |
    And I save my changes
    Then I should see "Success"
    And I follow "homepage_es_link"
    And the "Facebook" field should contain "http://facebook.com"
    And the "Twitter" field should contain "http://twitter.com"
    And the "YouTube" field should contain "http://youtube.com"
  