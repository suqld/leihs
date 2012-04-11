Feature: Add Item during acknowledge process

  In order to add more items to an order
  As a Lending Manager
  I want to have quick adding functionalities as well as adding a model by browsing trough all possible models

  @javascript
  Scenario: Adding a model quickly to an order by just typing in the inventory_number
    Given I am "Pius"
     When I open an order for acknowledgement
      And I add a model by typing in the inventory code of an item of that model to the quick add
     Then this model is added to the order 
    
  @javascript
  Scenario: Autocompletion of the quick add input (by inventory code)
    Given I am "Pius"
     When I open an order for acknowledgement
      And I start to type the inventory code of an item
      And I wait until the autocompletion is loaded
     Then I already see possible matches of models
     When I select one of the matched models
     Then the model is added to the order