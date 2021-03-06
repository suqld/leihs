Feature: Sign Contract

  In order to hand things over and sign a contract
  As a lending manager
  I want to be able to hand selected things over and generate a contract

  Background:
    Given personas existing
      And I am "Pius"

  @javascript
  Scenario: Hand over an not complete quantity of an option line
     When I open a hand over
      And I select an option line
      And I set the quantity for that option
      And I click hand over
     Then I see a summary of the things I selected for hand over
      And I see the settet quantity for this option
     When I click hand over inside the dialog
     Then the quantity of options is handed over

  @javascript
  Scenario: Hand over lines which start in the history
     When I open a hand over with overdue lines
      And I select an overdue item line and assign an inventory code
      And I click hand over
     Then I see that the time range in the summary starts today
     When I click hand over inside the dialog
     Then the lines start date is today 
