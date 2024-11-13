Feature: Delete account in profile
  As a current user
  I want to be able to delete my account
  So that I remove myself from the game.

  Scenario: User deletes their account
    Given I have an account
    And I go to my profile page
    And I delete my account
    Then my account should be deleted

