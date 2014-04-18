Feature: Creating Movement
  In order to draw attention to an important cause
  As a Platform Administrator
  I want to create a new movement

  Scenario:
    Given I am signed in as a Platform Administrator
    When I create a new movement
    Then I am taken to the movement dashboard page
