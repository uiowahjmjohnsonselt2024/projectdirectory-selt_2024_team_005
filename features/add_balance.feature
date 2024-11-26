Feature: Add balance in profile
  As a current user
  I want to be able to add money to the balance in my account
  so I can buy more things

  Scenario: User adds dollar
    Given I have an account and logged in
    And I have a balance of $0
    When I go to my profile page
    And I buy 10 USD worth of shards with a credit card
    Then my current balance should have 10 shards

  Scenario: User adds euros
    Given I have an account and logged in
    And I have a balance of $0
    When I go to my profile page
    And I buy 10 EUR worth of shards with a credit card
    Then my current balance should have at least 1 shards

  Scenario: User adds negative
    Given I have an account and logged in
    And I have a balance of $0
    When I go to my profile page
    And I buy -10 EUR worth of shards with a credit card
    Then I should see an error message