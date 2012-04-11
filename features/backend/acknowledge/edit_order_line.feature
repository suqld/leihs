Feature: Edit order line during acknowledge process

  In order to edit an order line
  As an Lending Manager
  I want to have functionalities to change an order lines time range and quantity

  @javascript
  Scenario: Change the time range of a single order line
    Given I am "Pius"
     When I open an order for acknowledgement
      And I change a lines time range
     Then the time range of that order line is changed
     
  @javascript
  Scenario: Change the quantity of a single order line
    Given I am "Pius"
     When I open an order for acknowledgement
      And I change a lines quantity
     Then the quantity of that order line is changed
     
  @javascript
  Scenario: Change the time range of multiple order lines
    Given I am "Pius"
     When I open an order for acknowledgement with more then one line
      And I change the time range for multiple lines
     Then the time range for that order lines is changed