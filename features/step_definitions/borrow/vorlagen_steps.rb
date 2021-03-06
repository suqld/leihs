# -*- encoding : utf-8 -*-

When(/^sehe ich unterhalb der Kategorien einen Link zur Liste der Vorlagen$/) do
  first("a[href='#{borrow_templates_path}'][title='#{_("Borrow template")}']")
end

When(/^ich schaue mir die Liste der Vorlagen an$/) do
  visit borrow_templates_path
end

Dann(/^sehe ich die Vorlagen$/) do
  @current_user.templates.each do |template|
    first("a[href='#{borrow_template_path(template)}']", text: template.name)
  end
end

Dann(/^die Vorlagen sind alphabetisch nach Namen sortiert$/) do
  all_names = all(".separated-top > a[href*='#{borrow_templates_path}']").map {|x| x.text.strip }
  all_names.sort.should == all_names
  all_names.count.should == @current_user.templates.count
end

When(/^ich kann eine der Vorlagen detailliert betrachten$/) do
  template = @current_user.templates.sample
  first("a[href='#{borrow_template_path(template)}']", text: template.name).click
  first("nav a[href='#{borrow_template_path(template)}']")
end

When(/^ich sehe mir eine Vorlage an$/) do
  @template = @current_user.templates.sample
  visit borrow_template_path(@template)
  first("nav a[href='#{borrow_template_path(@template)}']")
end

Dann(/^sehe ich alle Modelle, die diese Vorlage beinhaltet$/) do
  @template.models.each do |model|
    first(".row", text: model.name).first("input[name='lines[][model_id]'][value='#{model.id}']")
  end
end

Dann(/^die Modelle in dieser Vorlage sind alphabetisch sortiert$/) do
  all_names = all(".separated-top > .row.line").map {|x| x.text.strip }
  all_names.sort.should == all_names
  all_names.count.should == @template.models.count
end

When(/^ich sehe für jedes Modell die Anzahl Gegenstände dieses Modells, welche die Vorlage vorgibt$/) do
  @template.model_links.each do |model_link|
    first(".row", text: model_link.model.name).first("input[name='lines[][quantity]'][value='#{model_link.quantity}']")
  end
end

When(/^ich kann die Anzahl jedes Modells verändern, bevor ich den Prozess fortsetze$/) do
  @model_link = @template.model_links.sample
  first(".row", text: @model_link.model.name).first("input[name='lines[][quantity]'][value='#{@model_link.quantity}']").set rand(10)
end

When(/^ich kann höchstens die maximale Anzahl an verfügbaren Geräten eingeben$/) do
  max = first(".row", text: @model_link.model.name).first("input[name='lines[][quantity]']")[:max].to_i
  first(".row", text: @model_link.model.name).first("input[name='lines[][quantity]']").set max+1
  first(".row", text: @model_link.model.name).first("input[name='lines[][quantity]']").value.to_i.should == max
end

When(/^sehe ich eine auffällige Warnung sowohl auf der Seite wie bei den betroffenen Modellen$/) do
  first(".emboss.red", text: _("The highlighted entries are not accomplishable for the intended quantity."))
  all(".separated-top .row.line .line-info.red").size.should > 0
end

Dann(/^kann ich Start\- und Enddatum einer potenziellen Bestellung angeben$/) do
  @start_date = Date.tomorrow
  @end_date = Date.tomorrow + 4.days
  first("#start_date").set I18n.localize @start_date
  first("#end_date").set I18n.localize @end_date
end

Dann(/^ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage$/) do
  first(".green[type='submit']").click
end

Dann(/^alle Einträge erhalten das ausgewählte Start\- und Enddatum$/) do
  first(".headline-m").text.should == I18n.localize(@start_date)
  all(".line-col.col1of9.text-align-left").each do |date|
    date = date.text.split(" ").last
    date.should == I18n.localize(@end_date)
  end
end

When(/^in dieser Vorlage hat es Modelle, die nicht genügeng Gegenstände haben, um die in der Vorlage gewünschte Anzahl zu erfüllen$/) do
  @template = @current_user.templates.detect {|t| not t.accomplishable?(@current_user) }
  visit borrow_template_path(@template)
  first("nav a[href='#{borrow_template_path(@template)}']")
end

When(/^ich sehe die Verfügbarkeit einer Vorlage$/) do
  step "ich sehe mir eine Vorlage an"
  step "ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage"
end

When(/^ich sehe die Verfügbarkeit einer nicht verfügbaren Vorlage$/) do
  step "in dieser Vorlage hat es Modelle, die nicht genügeng Gegenstände haben, um die in der Vorlage gewünschte Anzahl zu erfüllen"
  step "ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage"
  first("*[type='submit']").click
end

Angenommen(/^einige Modelle sind nicht verfügbar$/) do
  first(".emboss.red", text: _("Please solve the conflicts for all highlighted lines in order to continue."))
  all(".separated-top .row.line .line-info.red").size.should > 0
end

Dann(/^kann ich diejenigen Modelle, die verfügbar sind, gesamthaft einer Bestellung hinzufügen$/) do
  page.should have_selector ".separated-top .row.line .line-info.red"
  @unavailable_model_ids = all(".separated-top .row.line .line-info.red").map {|x| x.first(:xpath, "./..").first("input[name='lines[][model_id]']", visible: false).value.to_i}
  @unavailable_model_ids -= @current_user.contracts.unsubmitted.flat_map(&:lines).map(&:model_id).uniq
  first(".button.green.dropdown-toggle").click
  page.should have_content _("Continue with available models only")
  first("*[name='force_continue']", :text => _("Continue with available models only")).click
end

Dann(/^die restlichen Modelle werden verworfen$/) do
  (@unavailable_model_ids - @current_user.contracts.unsubmitted.reload.flat_map(&:lines).map(&:model_id).uniq).should == @unavailable_model_ids
end

Dann(/^die Modelle sind innerhalb eine Gruppe alphabetisch sortiert$/) do
  all(".row.line .col6of10").map(&:text).should eq @template.models.sort.map(&:name)
end

Dann(/^sind diejenigen Modelle hervorgehoben, die zu diesem Zeitpunkt nicht verfügbar sind$/) do
  all(".row.line").each_with_index do |line, i|
    all(".row.line")[i].first(".line-info.red")
  end
end

Dann(/^ich kann Modelle aus der Ansicht entfernen$/) do
  if first(".row.line").all(".multibutton .dropdown-toggle").length > 0
    first(".row.line").first(".multibutton .dropdown-toggle").hover
  end
  find(".red", :match => :first, :text => _("Delete")).click
  sleep(0.6)
  page.driver.browser.switch_to.alert.accept rescue nil
end

Dann(/^ich kann die Anzahl der Modelle ändern$/) do
  @model = Model.find_by_name find(".row.line .col6of10").text
  find(".line .button", match: :first).click
  page.should have_selector "#booking-calendar .fc-day-content"
  find("#booking-calendar-quantity").set 1
end

Dann(/^ich kann das Zeitfenster für die Verfügbarkeitsberechnung einzelner Modelle ändern$/) do
  current_date = Date.today
  while all(".available:not(.closed)[data-date='#{current_date.to_s}']").empty? do
    before_date = current_date
    current_date += 1.day
    find(".fc-button-next").click if before_date.month < current_date.month
  end
  step "ich setze das Startdatum im Kalendar auf '#{I18n::l(current_date)}'"
  step "ich setze das Enddatum im Kalendar auf '#{I18n::l(current_date)}'"
  find(".modal .button.green", match: :first).click
  page.has_no_selector?("#booking-calendar").should be_true
end

Wenn(/^ich sämtliche Verfügbarkeitsprobleme gelöst habe$/) do
  page.should_not have_selector ".line-info.red"
end

Dann(/^kann ich im Prozess weiterfahren und alle Modelle gesamthaft zu einer Bestellung hinzufügen$/) do
  first(".button.green", text: _("Add to order")).click
  find("#current-order-show", match: :first)
  @current_user.contracts.unsubmitted.flat_map(&:models).should eq [@model]
end

Angenommen(/^ich sehe die Verfügbarkeit einer Vorlage, die nicht verfügbare Modelle enthält$/) do
  step "ich sehe mir eine Vorlage an"
  first("*[type='submit']").click
  date = Date.today
  while @template.inventory_pools.first.is_open_on?(date) do
   date += 1.day 
  end
  first("#start_date").set I18n::localize(date)
  first("#end_date").set I18n::localize(date)
  step "ich kann im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage"
end

Dann(/^ich muss den Prozess zur Datumseingabe fortsetzen$/) do
  first("*[type='submit']").click
  first("*[name='start_date']")
  first("*[name='end_date']")
end

Angenommen(/^ich habe die Mengen in der Vorlage gewählt$/) do
  step "ich sehe mir eine Vorlage an"
  first("*[type='submit']").click
end

Dann(/^ist das Startdatum heute und das Enddatum morgen$/) do
  first("#start_date").value.should == I18n.localize(Date.today)
  first("#end_date").value.should == I18n.localize(Date.tomorrow)
end

Dann(/^ich kann das Start\- und Enddatum einer potenziellen Bestellung ändern$/) do
  @start_date = Date.tomorrow
  @end_date = Date.tomorrow + 4.days
  first("#start_date").set I18n.localize @start_date
  first("#end_date").set I18n.localize @end_date
end

Dann(/^ich muss im Prozess weiterfahren zur Verfügbarkeitsanzeige der Vorlage$/) do
  first("*[type='submit']").click
  current_path.should == borrow_template_availability_path(@template)
end
