Feature: Login
    As a User
    I want to be able to identify myself
    In order to access the app

@scenario1
Scenario: Successful Login
    Given A valid username
    And A valid password
    When I press Login 
    Then I should be able to access the app

@scenario2
Scenario: Unsuccessful Login with invalid username and valid password
    Given An invalid username
    And A valid password
    When I press Login
    Then I should not be able to access the app

@scenario3
Scenario: Unsuccessful Login with invalid username and invalid password
    Given An invalid username
    And An invalid password
    When I press Login
    Then I should not be able to access the app

@scenario4
Scenario: Unsuccessful Login with valid username and invalid password
    Given A valid username
    And An invalid password
    When I press Login
    Then I should not be able to access the app