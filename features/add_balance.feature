Feature: Add balance in profile
  As a current user
  I want to be able to add money to the balance in my account
  so I can buy more things

  Scenario: User adds balance
    Given I have an account
    And I have a balance of $0
    When I go to my profile page
    And I buy 10 shards with a credit card
    Then my current balance should have 10 shards