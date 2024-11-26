Feature: Check balance in profile
  As a current user
  I want to be able to check the balance in my profile
  So I know how much money I have

  Scenario: User checks their balance
    Given I have an account and logged in
    And I have a balance of $100
    When I go to my profile page
    Then I should see my current balance

