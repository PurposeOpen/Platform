Feature: Movement Administrator changes timezone
  In order to send emails according to local time of movement
  As a Movement Administrator
  I want to change the Movement timezone setting

  Scenario: Movement Administrator changes from default to Mid-Atlantic timezone
    Given I am a logged in Movement Admistrator
    When I change my movement's timezone setting to Mid-Atlantic
    Then I see that the timezone setting has been changed
