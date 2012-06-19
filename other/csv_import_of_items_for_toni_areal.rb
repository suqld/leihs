# This is to be run from the Rails console using require:
# ./script/console
# require 'doc/csv_import_of_items'


require 'faster_csv'

import_file = "/tmp/120510_Umzugsgutliste ZHdK_schriftverkehr.csv"

@failures = 0
@successes = 0

def create_item(model_name, inventory_code, serial_number, manufacturer, category, accessory_string, note)
  

  if model_name.blank?
    puts "Can't create item with a blank name."
  else

    m = Model.find_by_name(model_name)
    if m.nil?
      m = create_model(model_name, category, manufacturer, accessory_string)    
    end
    
    ip = InventoryPool.find_by_name("Testpool")
    
    i = Item.new
    i.model = m
    i.inventory_code = inventory_code
    i.serial_number = serial_number
    i.note = note
    i.owner = ip
    i.is_borrowable = true
    i.is_inventory_relevant = true
    i.inventory_pool = ip
    
    if i.save
      puts "Item imported correctly:"
      @successes += 1
      puts i.inspect
    else
      @failures += 1
      puts "Could not import item #{inventory_code}"
    end
    
    puts "-----------------------------------------"
    puts "DONE"
    puts "#{@successes} successes, #{@failures} failures"
    puts "-----------------------------------------"
  end  
end

def create_model(name, category, manufacturer, accessory_string)
  m = Model.create(:name => name, :manufacturer => manufacturer)

  unless category.blank?
    c = Category.find_or_create_by_name(category)
    m.categories << c
  end
  
  unless accessory_string.blank?  
    accessory_string.split(",").each do |string|
      acc = Accessory.create(:name => string.strip)
      m.accessories << acc
    end
  end
  
  m.save

  return m
end

items_to_import = FasterCSV.open(import_file, :headers => true)

# CSV fields:
# 0: Bezeichnung
# 1: Erf.
# 2: Erf.
# 3: Hersteller / Wartung
# 4: Bemerkung vor (= Kategorie)
# 5: Zubehör (comma-separated field)
# 6: Defekt: (-> Notiz)

items_to_import.each do |item|

  create_item(item["Umzugsgut "], 
              item["Erf."],
              item["Erf."],
              item["Hersteller / Wartung"],
              item["Bemerkung vor"],
              "",
              "")
end



