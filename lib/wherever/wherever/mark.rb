class Wherever
  module Mark
    def mark(name)
      configuration = if Mongoid::Config.respond_to?(:master) 
        Mongoid::Config
      else
        Mongoid::Config.instance
      end
      configuration.master.eval("db.current_identifier.find().forEach( function(x){db.#{name}_identifier.insert(x)} )")
      config.key_groups.each do |keys|
        [:identifier, :dataset].each do |db_type|
          db_id = "#{keys.join('_')}_#{db_type}"
          configuration.master.eval("db.current_#{db_id}.find().forEach( function(x){db.#{name}_#{db_id}.insert(x)} )")
        end
      end
      set_price_lookup('price', nil, [{'marker' => name}])
    end
  end
end