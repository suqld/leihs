# -*- encoding : utf-8 -*-

Wenn(/^Julie in einer Delegation ist$/) do
  @user = Persona.get :julie
  @user.delegations.should_not be_empty
end

Dann(/^werden mir im alle Suchresultate von Julie oder Delegation mit Namen Julie angezeigt$/) do
  q = "%Julie%"
  delegations = @current_inventory_pool.users.as_delegations.where(User.arel_table[:firstname].matches(q))
  ([@user] + delegations).each do |u|
    find("#users .list-of-lines .line", match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Dann(/^mir werden alle Delegationen angezeigt, den Julie zugeteilt ist$/) do
  (@user.delegations & @current_inventory_pool.users).each do |u|
    find("#users .list-of-lines .line", match: :prefer_exact, text: u.to_s)
  end
  # TODO also check contracts matches, etc...
end

Dann(/^kann ich in der Benutzerliste nach Delegationen einschränken$/) do
  find("#user-index-view form#list-filters select#type").select _("Delegations")
  find("#user-list.list-of-lines .line", match: :first)
  ids = all("#user-list.list-of-lines .line [data-type='user-cell']").map {|user_data| user_data["data-id"] }
  User.find(ids).all?(&:is_delegation).should be_true
end

Dann(/^ich kann in der Benutzerliste nach Benutzer einschränken$/) do
  find("#user-index-view form#list-filters select#type").select _("Users")
  find("#user-list.list-of-lines .line", match: :first)
  ids = all("#user-list.list-of-lines .line [data-type='user-cell']").map {|user_data| user_data["data-id"] }
  User.find(ids).any?(&:is_delegation).should be_false
end

Angenommen(/^ich befinde mich im Reiter '(.*)'$/) do |arg1|
  find("nav ul li a.navigation-tab-item", text: arg1).click
  find("nav ul li a.navigation-tab-item.active", text: arg1)
  find("#user-index-view ")
end

Wenn(/^ich eine neue Delegation erstelle$/) do
  within(".multibutton", text: _("New User")) do
    find(".dropdown-toggle").hover
    find(".dropdown-item", text: _("New Delegation")).click
  end
  pending
end

Wenn(/^ich der Delegation Zugriff für diesen Pool gebe$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich dieser Delegation einen Namen gebe$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich dieser Delegation keinen, einen oder mehrere Personen zuteile$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich kann dieser Delegation keine Delegation zuteile$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich genau einen Verantwortlichen eintrage$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich die Delegation speichere$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^ist die Delegation mit den aktuellen Informationen gespeichert$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich nach einer Delegation suche$/) do
  @delegation = @current_inventory_pool.users.as_delegations.sample
  step "ich suche '%s'" % @delegation.firstname
end

Wenn(/^ich über den Delegationname fahre$/) do
  find("#users .list-of-lines .line", match: :prefer_exact, text: @delegation.to_s).find("[data-type='user-cell']").hover
end

Dann(/^werden mir im Tooltipp der Name und der Verantwortliche der Delegation angezeigt$/) do
  find("body > .tooltipster-base", text: @delegation.delegator_user.to_s)
end

Angenommen(/^es wurde für eine Delegation eine Bestellung erstellt$/) do
  @contract = @current_inventory_pool.contracts.submitted.find {|c| c.user.is_delegation }
  @contract.should_not be_nil
end

Angenommen(/^ich befinde mich in dieser Bestellung$/) do
  visit manage_edit_contract_path @current_inventory_pool, @contract
end

Dann(/^sehe ich den Namen der Delegation$/) do
  page.has_content? @contract.user.name
end

Dann(/^ich sehe die Kontaktperson$/) do
  page.has_content? @contract.delegated_user.name
end

Angenommen(/^es existiert eine persönliche Bestellung$/) do
  @contract = @current_inventory_pool.contracts.submitted.find {|c| not c.user.is_delegation }
  @contract.should_not be_nil
end

Dann(/^ist in der Bestellung der Name des Benutzers aufgeführt$/) do
  page.has_content? @contract.user.name
end

Dann(/^ich sehe keine Kontatkperson$/) do
  all("h2", text: @contract.user.name).size.should == 1
end

Angenommen(/^es existiert eine Aushändigung für eine Delegation$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find {|v| v.user.is_delegation }
  @hand_over.should_not be_nil
end

Angenommen(/^ich öffne diese Aushändigung$/) do
  visit manage_hand_over_path @current_inventory_pool, @hand_over.user
end

Wenn(/^ich die Delegation wechsle$/) do
  page.has_selector?("input[data-select-lines]", match: :first)
  all("input[data-select-lines]").select{|el| !el.checked?}.map(&:click)
  multibutton = find(".multibutton", text: _("Hand Over Selection"))
  multibutton.find(".dropdown-toggle").hover
  find("#swap-user", match: :first).click
  find(".modal", match: :first)
  @old_delegation = @hand_over.user
  @new_delegation = @current_inventory_pool.users.find {|u| u.is_delegation and u.firstname != @old_delegation.firstname}
  find("input#user-id", match: :first).set @new_delegation.name
  find(".ui-menu-item a", match: :first).click
  find(".modal .button[type='submit']", match: :first).click
  find(".content-wrapper", :text => @new_delegation.name, match: :first)
  @hand_over.lines.reload.map(&:contracts).uniq.all? {|c| c.user == @new_delegation }
end

Dann(/^lautet die Aushändigung auf diese neu gewählte Delegation$/) do
  page.has_content? @new_delegation.name
  page.has_no_content? @old_delegation.name
end

Wenn(/^ich die Kontaktperson wechsle$/) do
  page.has_selector?("input[data-select-lines]", match: :first)
  all("input[data-select-lines]").select{|el| !el.checked?}.map(&:click)
  find("button", text: _("Hand Over Selection")).click
  find("#user-id", match: :first).click
  find(".modal", match: :first)
  @old_delegation = @hand_over.user
  @new_delegation = @current_inventory_pool.users.find {|u| u.is_delegation and u.firstname != @old_delegation.firstname}
  find("input#user-id", match: :first).set @new_delegation.name
  find(".ui-menu-item a", match: :first).click
  find(".modal .button[type='submit']", match: :first).click
  find(".content-wrapper", :text => @new_delegation.name, match: :first)
  @hand_over.lines.reload.map(&:contracts).uniq.all? {|c| c.user == @new_delegation }
end

Dann(/^kann ich nur diejenigen Personen wählen, die zur Delegationsgruppe gehören$/) do
  pending # express the regexp above with the code you wish you had
end
