#Feature: Grid Expansion
#  As a user
#  I want to expand my grid
#  So that I can explore more areas
#
#  Background:
#    Given a grid named "Test Grid" exists
#    And I am logged in as "testuser"
#
#  Scenario: User expands the grid successfully
#    Given my grid visibility is 6
#    When I am on the grid page for "Test Grid"
#    And I click the "Expand " button
#    Then I should see a grid of size 7x7
#    And my grid visibility should be 7
#    And I should see a success message "Grid expanded successfully"
#
#  Scenario: User reaches maximum grid size
#    Given my grid visibility is 12
#    When I am on the grid page for "Test Grid"
#    Then I should not see the "Expand" button
#    And I should see a message "Maximum grid size reached."
#
##  Scenario: Unauthorized user cannot expand another user's grid
##    Given another user "otheruser" exists
##    And "otheruser" has a grid visibility of 6 for "Test Grid"
##    When I visit the grid page for "Test Grid" as "otheruser"
##    Then I should see an authorization error
##    And I should be redirected to the home page
