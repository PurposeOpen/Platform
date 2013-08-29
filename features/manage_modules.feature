@group4 @admin
Feature: Managing modules
  In order to add content to the web site
  As a campaigner
  I want to manage modules for a page

Background:
  Given I run the seed task
  Given I am logged into the platform as a platform admin
  And I visit the admin "Landing Page for Blank Slate" page

@javascript
Scenario: Adding an HTML module to the main content
  When I follow "+ HTML" inside the container "MAIN CONTENT"
  And I wait 5 seconds
  Then I should see "Html Module"
  When I fill the added html module with some content
  And I press "Save page"
  Then I should see "Success"

@javascript
Scenario: Adding an HTML module to the header section
  When I follow "+ HTML" inside the container "HEADER CONTENT"
  And I wait 5 seconds
  Then I should see "Html Module"
  When I fill the added html module with some content
  And I press "Save page"
  Then I should see "Success"

@wip @javascript
Scenario: Removing an HTML Module
  When I follow "Add HTML"
  When I fill in "Content" with "Down with this sort of thing!"
  And I press "Save page"
  When I visit the admin "Landing Page for Blank Slate" page
  And I follow "Remove module" for the module "Down with this sort of thing!" and click "Cancel"
  Then I should see "Down with this sort of thing!"
  When I follow "Remove module" for the module "Down with this sort of thing!" and click "OK"
  Then I should not see "Save the kittens!"

@wip @javascript
Scenario: Moving a module between containers
  When I follow "Add HTML" inside the container "MAIN CONTENT"
  When I fill in "Content" with "Careful now."
  And I press "Save page"
  When I visit the admin "Landing Page for Blank Slate" page
  Then I should see "Careful now." inside the container "MAIN CONTENT"
  When I follow "Move to sidebar" for the HTML module "Careful now."
  Then I should see "Careful now." inside the container "SIDEBAR"
  Then I visit the admin "Landing Page for Blank Slate" page
  Then I should see "Careful now." inside the container "SIDEBAR"

@wip @javascript
Scenario: Moving module between containers and saving
  When I follow "Add accordion" within the container "SIDEBAR"
  Then I follow "Add HTML" within the container "MAIN CONTENT"
  Then I fill in "Title" with "Test Title"
  When I fill in "Content" with "Careful now."
  And I press "Save page"
  When I visit the admin "Landing Page for Blank Slate" page
  When I follow "Move to main content" for the Accordion module "Careful now."
  Then I should see "Careful now." within the container "SIDEBAR"
  And I press "Save page"
  Then I visit the admin "Landing Page for Blank Slate" page


@wip @javascript
Scenario: Adding a petition
  When I follow "Add a petition"
  And I fill in "Title" with "petition contre Sarkozy"
  And I fill in "Petition statement" with "Monsieur le President blablablabla ..."
  And I fill in "Target number" with "100"
  And I fill in "Show progress at" with "50"
  And I fill in "Button text" with "Virez le!"
  And I press "Save page"
  Then I should see "'Landing Page for Blank Slate' has been updated."
  When I visit the admin "Landing Page for Blank Slate" page
  Then the "Title" field should contain "petition contre Sarkozy"
  And the "Petition statement" field should contain "Monsieur le President blablablabla ..."
  And the "Target number" field should contain "100"
  And the "Show progress at" field should contain "50"
  And the "Button text" field should contain "Virez le!"

@wip @javascript
Scenario: Adding a donation
  When I follow "Add a donation"
  And I fill in "Title" with "Give us money for catfood"
  And I fill in "Suggested amounts" with "25, 50.75, 99.99"
  And I fill in "Default amount" with "50.75"
  And I fill in "Show progress at" with "10"
  And I select "Quarterly" from "Receipt frequency"
  And I press "Save page"
  Then I should see "'Landing Page for Blank Slate' has been updated."
  When I visit the admin "Landing Page for Blank Slate" page
  Then the "Title" field should contain "Give us money for catfood"
  And the "Suggested amounts" field should contain "25, 50.75, 99.99"
  And the "Default amount" field should contain "50.75"
  And the "Show progress at" field should contain "10"
  And the "Receipt frequency" field should contain "quarterly"

@wip @javascript
Scenario: Validation failures
  When I follow "Add a petition"
  Then I should see "Petition Module"
  And I press "Save page"
  Then I should not see "Success"
  And I should see "Title is too short (minimum is 3 characters)"