Feature: Health check dashboard
  As a platform administrator
  I want to be able to check the overall systems status

  Background:
    Given I have the reference languages in the platform
    And I have movements named "Shake it!" with the languages "Portuguese,Spanish"
    And I am logged into the platform as a platform admin

  Scenario: Checking the system health
    When I visit the health check dashboard for the movement "Shake it!"
    Then I should see the following services statuses
      | service     | status                 |
      | platform    | WARNING - mail is down |
      | database    | OK                     |
      | mail        | CRITICAL               |
      | delayedJobs | OK                     |