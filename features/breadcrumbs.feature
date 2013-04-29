@group1
Feature: Breadcrumbs
  In order to see where I am in the platform
  As a platform user
  I want to view breadcrumbs

  Background:
    Given I run the seed task
    Given I am logged into the platform as a platform admin

  Scenario: Viewing movement breadcrumbs
    When I visit the "Dummy movement" movement page
    Then the breadcrumbs should match "Dummy Movement, Home"
    When I follow "Settings"
    Then the breadcrumbs should match "Dummy Movement » Edit Movement"
    When I visit the "Dummy movement" movement page
    And I follow "Campaigns"
    Then the breadcrumbs should match "Dummy Movement » Campaigns"
    When I follow "Content Pages"
    Then the breadcrumbs should match "Dummy Movement » Content Pages"
    When I follow "A page inside Jobs"
    Then the breadcrumbs should match "Dummy Movement » Content Pages » A page inside Jobs"
    When I follow "Featured Items"
    Then the breadcrumbs should match "Dummy Movement » Featured Contents"
    When I follow "Carousel"
    Then the breadcrumbs should match "Dummy Movement » Featured Contents » Carousel"

  @javascript
  Scenario: Viewing breadcrumbs under campaigns
    When I visit the "Dummy movement" movement page
    Then the breadcrumbs should match "Dummy Movement, Home"
    When I follow "Campaigns"
    Then the breadcrumbs should match "Dummy Movement, Campaigns"
    When I follow "Forestry"
    Then the breadcrumbs should match "Dummy Movement, Campaigns, Forestry"
    When I follow "Gunns Petition"
    Then the breadcrumbs should match "Dummy Movement, Campaigns, Forestry, Gunns Petition"
    When I follow "Landing Page for Gunns Petition"
    Then the breadcrumbs should match "Dummy Movement, Campaigns, Forestry, Gunns Petition, Landing Page for Gunns Petition"
    When I follow "Campaigns"
    And I follow "Forestry"
    And I follow "Dummy Push"
    Then the breadcrumbs should match "Dummy Movement, Campaigns, Forestry, Dummy Push"
    When I follow "Recipients"
    Then the breadcrumbs should match "Dummy Movement, Campaigns, Forestry, Dummy Push, Dummy Blast"
