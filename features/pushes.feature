@group5 @admin @without_transactional_fixtures @no-database-cleaner
Feature: Creating a push for a campaign
  In order to inform users that their assistance is required
  As a campaigner
  I want to create pushes encouraging them to take action on a campaign

  Background:
    Given I run the seed task
    And I am logged into the platform as a platform admin

  Scenario: Create a new push
    Given there is an email "Test Email" for the "Forestry" campaign
    When I visit the "Forestry" campaign page
    And I follow "Add a push"
    And I fill in "Name" with "Test Push"
    And I press "Create push"
    Then I should be on the admin push page for "Test Push"
    When I follow "Add a blast"
    And I fill in "Name" with "Test Blast"
    And I press "Create blast"
    Then I should be on the admin push page for "Test Push"

  @javascript
  Scenario: Renaming a push
    Given there is a push "Push for Renaming" in the "Forestry" campaign
    When I visit the "Forestry" campaign page
    Then I should see "Push for Renaming"
    When I click Rename for the push "Push for Renaming"
    And I enter the new name as Renamed Push for the same push
    And I press Save Push button
    Then I should see "Renamed Push" in the Pushes listing

  Scenario: Add a blast to a push
    Given there is a push "Climate action" for the "Forestry" campaign
    When I visit the admin push page for "Climate action"
    And I follow "Add a blast"
    And I fill in "Name" with "Save the polar bears"
    And I press "Create blast"
    Then I should be on the admin push page for "Climate action"
    And I should see "Save the polar bears" within "#blasts-list"

  @javascript
  Scenario: Add an email to a blast
    When I visit the "Forestry" campaign page
    And I follow "Dummy Push"
    And I expand Add an Email to click New Email
    And I fill in "Name" with "Call for donations"
    And I fill in "Subject" with "We need your help!"
    And I fill in "From" with "Your Name <campaigns@yourdomain.org>"
    And I fill in "Reply to" with "Your Name <reply@yourdomain.org>"
    When I press "Save"
    Then I should see "Body can't be blank"
    When I write in "email_body" with "Please follow the link and take action."
    And I press "Save"
    Then I should be on the admin edit email page for "Call for donations"

  @wip
  Scenario: Add a list to a blast
    Given there are 10 members in the "Dummy Movement" movement
    And there is a push "Climate action" for the "Forestry" campaign
    And there is a blast "Save the polar bears" for the "Climate action" push
    And I am on the admin push page for "Climate action"
    Then I should see "Save the polar bears"
    When I follow "Recipients"
    And I wait 1 seconds
  #Then I should be on the admin new list page for "Climate action"
    When I press "Save List"
    Then I should see "Found 10 members" within ".list-cutter-result"
    When I follow "Back"
    And I wait 1 seconds
  #Then I should be on the admin push page for "Climate action"
    And I should see "Save the polar bears (10 members)"

  @wip
  @javascript
  Scenario: Blast can be sent once proof is sent
    Given there is a push "Climate action" for the "Forestry" campaign
    And there is a blast "Do something about it" for the "Climate action" push
    And there is an email "The ice age cometh" for the "Do something about it" blast
    And I am on the admin push page for "Climate action"
    Then I should not see "Deliver" within "#blasts-list"
    When I follow "The ice age cometh"
    And I fill in "Recipients" with "this.is.not.a.user@yourdomain.org"
    And I press "Send"
    Then I should be on the admin push page for "Climate action"
    And I should see "Test blast sent"
    And I should see "Deliver" within "#blasts-list"

  @wip
  @javascript @delayed-jobs
Scenario: Delivery in progress message is shown
  Given there are 10 members in the system
  And there is a push "Climate action" for the "Forestry" campaign
  And there is a blast "Do something about it" with a non-filtering list for the "Climate action" push
  And there is a blast "Do something else about it" with a non-filtering list for the "Climate action" push
  And there is an email "The ice age cometh" for the "Do something about it" blast
  And there is an email "The ice age still cometh" for the "Do something else about it" blast
  And a proof has been sent for "The ice age cometh"
  And a proof has been sent for "The ice age still cometh"
  And I am on the admin push page for "Climate action"
  Then I should see "Deliver" within "#blasts-list"
  When I fill in "limit" with "5"
  And I press "Send"
  And I wait 1 seconds
  Then I should be on the admin push page for "Climate action"
  And There should be ".in-progress" only once inside "#blasts-list"
  And I should see "This blast can't be sent right now - check that the other blasts have finished first"

@wip
@javascript
  Scenario: Delivered emails are shown against blast
    Given there are 10 members in the system
    And there is a push "Climate action" for the "Forestry" campaign
    And there is a blast "Save the polar bears" with a non-filtering list for the "Climate action" push
    And there is an email "The ice age cometh" for the "Save the polar bears" blast
    And a proof has been sent for "The ice age cometh"
    And "The ice age cometh" has been delivered to 5 members
    And I refresh the push stats aggregation table
    When I am on the admin push page for "Climate action"
    Then I should see "Sent to 5 members at last count"

  @wip
  @javascript @delayed-jobs
Scenario: A delivery can be canceled
  Given there is a push "Climate action" for the "Forestry" campaign
  And there is a blast "Do something about it" for the "Climate action" push
  And there is an email "The ice age cometh" for the "Do something about it" blast
  And a proof has been sent for "The ice age cometh"
  And I am on the admin push page for "Climate action"
  Then I should see "Deliver"
  When I press "Send"
  Then I should be on the admin push page for "Climate action"
  And I should see "Delivery in"
  When I click "OK" after following "undo"
  Then I should be on the admin push page for "Climate action"
  And I should see "Delivery canceled"

@wip
@javascript @delayed-jobs
Scenario: Email that is being delivered has a warning message on edit page
  Given there is a push "Climate action" for the "Forestry" campaign
  And there is a blast "Do something about it" for the "Climate action" push
  And there is an email "The ice age cometh" for the "Do something about it" blast
  And a proof has been sent for "The ice age cometh"
  And I am on the admin push page for "Climate action"
  Then I should see "Deliver"
  When I press "Send"
  And blasts are queued for delivery indefinitely
  And I follow "The ice age cometh"
  Then I should see "This email is scheduled for delivery. Changes made will not apply to blasts already scheduled."
  And blasts are processed again

