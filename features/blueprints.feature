Feature: blueprints
  In order to use blueprints with cucumber
  As a developer
  I should be able build blueprints with correct data

  Scenario: build cherry
    Given I have apple
    Then apple should be available
    And apple should be a fruit
    And apple species should be "apple"

  Scenario: no cherry
    Then apple should NOT be available

  Scenario: big cherry prebuild
    When big_cherry size is 10
    Then I set big_cherry size to 15

  Scenario: big cherry another prebuild
    When big_cherry size is 10
    Then I set big_cherry size to 15
