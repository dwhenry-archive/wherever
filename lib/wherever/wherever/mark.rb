class Wherever
  module Mark
    def mark(name)
      copy_collections("current_identifier", "#{name}_identifier")
      config.key_groups.each do |keys|
        [:identifier, :dataset].each do |db_type|
          db_id = "#{keys.join('_')}_#{db_type}"
          copy_collections("current_#{db_id}", "#{name}_#{db_id}")
        end
      end
      set_price_lookup('price', nil, [{'marker' => name}])
    end
    
    def copy_collections(from_collection, to_collection)
      copy_function = "db.#{from_collection}.find().forEach( function(x){db.#{to_collection}.insert(x)} )"
      if Mongoid::Config.respond_to?(:instance)
        Mongoid::Config.instance.master.eval(copy_function)
      else
        Mongoid::Config.master.eval(copy_function)
      end
    end
  end
end