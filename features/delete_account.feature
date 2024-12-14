Feature: Delete account in profile
  As a current user
  I want to be able to delete my account
  So that I remove myself from the game.

  Scenario: User deletes their account
    Given I have an account and logged in
    And I go to my profile page
    Then I delete my account
#    Then my account should be deleted

