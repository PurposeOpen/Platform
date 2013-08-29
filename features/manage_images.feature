@group4 @search @javascript
Feature: Manage images
  In order to manage online content
  As a campaigner
  I want to be able to upload and resize images

  Background:
    Given I run the seed task
    Given I am logged into the platform as a platform admin

  Scenario: Show no images
    Given I have 0 fixture images for the movement "Dummy Movement"
    And I am on the admin images page for the movement "Dummy Movement"
    Then I should see "Images (0)"

  Scenario: Show one image
    Given I have 1 fixture image for the movement "Dummy Movement"
    And I am on the admin images page for the movement "Dummy Movement"
    Then I should see "Images (1)"

  Scenario: Show the limit (30) images
    Given I have 35 fixture images for the movement "Dummy Movement"
    And I am on the admin images page for the movement "Dummy Movement"
    Then I should see "Images (30)"
    And I should see a link labeled "Next →"

  Scenario: Upload an image
    Given I have 0 images for the movement "Dummy Movement"
    And I am on the admin images page for the movement "Dummy Movement"
    And I upload a fixture image file
    Then I should see "Image Preview"

  Scenario: Uploaded images are not accessible from different movements
    Given I have 0 images for the movement "Dummy Movement"
    And I have 0 images for the movement "Funny Movement"
    When I am on the admin images page for the movement "Dummy Movement"
    And I upload a fixture image file
    And I go to the admin images page for the movement "Funny Movement"
    Then I should see "Images (0)"

  Scenario: Searching for images by description
    Given I have 1 fixture image for the movement "Dummy Movement" with description "Some Test Image"
    And I have 1 fixture image for the movement "Dummy Movement" with description "Another Test Image"
    And I am on the admin images page for the movement "Dummy Movement"
    When I fill in "query" with "Some"
    And I press submit button
    Then I should see "Images (1)"

  Scenario: Searching for images by filename
    Given I have 1 fixture image for the movement "Dummy Movement" with filename "image_foo.jpg"
    And I have 1 fixture image for the movement "Dummy Movement" with filename "image_bar.jpg"
    And I am on the admin images page for the movement "Dummy Movement"
    When I fill in "query" with "foo"
    And I press submit button
    Then I should see "Images (1)"
