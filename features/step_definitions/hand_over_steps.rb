Given "the list of approved orders contains $total elements" do | total |
  contracts = @inventory_pool.contracts.approved
  user = LeihsFactory.create_user
  total.to_i.times { contracts << FactoryGirl.create(:contract, :user => user, :status => :approved) }
  contracts.size.should == total.to_i
end

When "$who approves the order" do | who |
  post login_path(:login => @last_manager_login_name)
  post manage_approve_contract_path(@inventory_pool, @order, :comment => "test comment")
  @order = assigns(:order)
  @order.should_not be_nil
  @contract = @order.user.reload.approved_contract(@order.inventory_pool)
  @contract.should_not be_nil
end

# OPTIMIZE 0402
When "$who clicks on 'hand_over'" do | who |
  get send("backend_inventory_pool_hand_over_index_path", @inventory_pool)
  @visits = assigns(:visits)
  response.should render_template("backend/hand_over/index")
end

When "he tries to hand over an item to a customer" do
  get manage_hand_over_path(@inventory_pool, @user)
  
  @contract = assigns(:contract)
  @contract.lines.size.should == 0
  
  post add_line_backend_inventory_pool_user_hand_over_path(@inventory_pool, @user, :model_id => Model.first.id, :quantity => 1)
                             
  @contract = assigns(:contract)
  @contract.lines.size.should == 1
end


Then /he sees ([0-9]+) line(s?) with a total quantity of ([0-9]+)$/ do |total, s, quantity |
   @visits.size.should == total.to_i
   s = @visits.sum(:quantity)
   s.should == quantity.to_i 
end

###############################################

Then "line $line has a quantity of $quantity for customer '$who'" do | line, quantity, who |
  @visits[line.to_i - 1].quantity.should == quantity.to_i
  @visits[line.to_i - 1].user.login.should == who
end

###############################################


When "$who chooses one line" do | who |
  visit = @visits.first
  get manage_hand_over_path(@inventory_pool, visit.user)
  response.should render_template('backend/hand_over/show')
  @contract = assigns(:contract)
end

# copied from 'When "$who chooses $name's order"'
When "$who chooses $name's visit" do | who, name |
  @visit = @visits.detect { |c| c.user.login == name }
  get manage_hand_over_path(@inventory_pool, @visit.user)
  response.should render_template('backend/hand_over/show')
  @contract = assigns(:contract)
  @response = response
end

When "$who assigns '$item' to the first line" do | who, item |
  step "#{who} assigns '#{item}' to line 0"
end

When "$who tries to assign '$item' to the first line" do | who,item |
  step "#{who} tries to assign '#{item}' to line 0"
end

When "$who assigns '$item' to line $number" do | who, item, number |
  step "#{who} tries to assign '#{item}' to line #{number}"
  step "#{who} should not see a flash error"
end

When "$who tries to assign '$item' to line $number" do | who, item, number |
  post change_line_backend_inventory_pool_user_hand_over_path(
	 @inventory_pool, @visit.user,
         :contract_line_id => @contract.contract_lines[number.to_i].id, :code => item )
  @flash = flash
end

When "he signs the contract" do
  post sign_contract_backend_inventory_pool_user_hand_over_path(
	 @inventory_pool, @visit.user, :lines => [@contract.contract_lines.first.id] )
end

Then "a new contract is generated" do
  @contract.nil?.should == false
end

Then /^he sees ([0-9]+) contract line(s?) for all approved order lines$/ do | size, s |
  @contract.contract_lines.size.should == size.to_i
end

Then "the total number of contracts is $n_contracts" do |n_contracts|
	Contract.count.should == n_contracts.to_i
end

Then /^the resulting contract lines are invalid$/ do
	  pending # express the regexp above with the code you wish you had
end

Then /^he should (.*)see a flash error$/ do |shouldNot|
  has_error = @flash.has_key?(:error)
  shouldNot == "" ? has_error.should(be_true) : has_error.should_not(be_true)
end

Then "that should check that line since it's from this day on" do
  find_by_label_or_id(:check_box, field).set(true)
  $browser.include
  # This is only a place holder - we don't do the check here but
  # further down on the model
end

Then "that should not check that line since it's not from this day on" do
  # This is only a place holder - we don't do the check here but
  # further down on the model
end

Then "the contract should only contain the item '$item'" do |item|
  @contract.contract_lines.size.should == 1
  @contract.contract_lines.first.item.inventory_code.shoul == item
end

# see http://wiki.github.com/jarib/celerity/ajax
When "I wait for the AJAX call to finish" do
  $browser.wait
end

# More full-stack-ish tests from here

Then /^I choose "([^"]*)" for the order by "([^"]*)"$/ do |button, person|
  all("#list_table tr").each do |row|
    if row.text =~ /#{person.to_s}/
      row.first("td.buttons").find('a', :text => /.*#{button}.*/i).click
    end
  end
#   debugger
#   puts "flarp"
end  
