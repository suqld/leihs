class RenameLocalesToFitRailsStyle < ActiveRecord::Migration
  def up
    
    # The Rails guys are using - to separate locale from region instead of _, so we
    # have to change it too if we don't want to run into clashes with the official
    # I18n .yml files.
    [["en_GB", "en-GB"], ["en_US", "en-US"], ["de_CH", "de-CH"], ["gsw_CH", "gsw-CH"]].each do |langs|
      lang = Language.where(:locale_name => langs[0]).first
      unless lang.nil?
      	lang.locale_name = langs[1]
      	lang.save
      end
    end

  end

  def down
    [["en_GB", "en-GB"], ["en_US", "en-US"], ["de_CH", "de-CH"], ["gsw_CH", "gsw-CH"]].each do |langs|
      lang = Language.where(:locale_name => langs[1])
      unless lang.nil?
      	lang.locale_name = langs[0]
      	lang.save
      end
    end
    
  end
end
