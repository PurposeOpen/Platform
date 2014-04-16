Feature: 
  In order to authenticate access to accounts
  As a Platform Administrator
  I want to login

  Scenario:
    Given I am a platform administrator with a primary movement
    When I sign into the platform
    Then I am taken to my primary movement dashboard

