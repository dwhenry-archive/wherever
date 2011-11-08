class Wherever
  module Lookup
    def create_lookup(name, keys)
      lookup_class = DbStore.new_lookup(name, keys)

      self.class.class_eval do
        define_method "set_#{name}" do |version, values|
          new_version?(name, version)
          lookup_class.create(:name => version, :values => key_to_string(values))
          recalculate(name) if set_price_lookup(name, version)
        end
      end
    
      self.class.class_eval do
        define_method "get_#{name}" do |marker, data|
          lookup = get_lookup(name)
          lookup_data = lookup_class.where(:name => lookup.lookups[marker]).first
          return 0 unless lookup_data 
          value_key = lookup.keys.map{|key| data[key.to_id]}.join('_')
          lookup_data.values[value_key] || 0
        end
      end
      MethodLogging.add_method(self.class, "set_#{name}")
      MethodLogging.add_method(self.class, "get_#{name}")
    end
  
    protected
    def key_to_string(values)
      string_values = {}
      values.each {|k, v| string_values[Array[k].join('_')] = v}
      string_values
    end
    
    def set_price_lookup(name, version=nil, keys=[])
      lookup = get_lookup(name)
      return false if lookup.current == version
      lookup.lookups[get_marker(keys)] = (version || lookup.current)
      lookup.save
    end
    
    def recalculate(name)
      keys = get_lookup(name).keys
      config.key_groups.each do |group|
        if keys & group != keys
          get_key_store(*group).datasets.delete_all
        end
      end
      
      identifier_set.datasets.all.each do |record|
        @grouping.call(record.values, nil, record, config.keys)
        record.save!
        config.key_groups.each do |group|
          if keys & group != keys
            for_group(group, record.values, record, false)
          end
        end
      end
      config.key_groups.each do |group|
        if keys & group == keys
          get_key_store(*group).datasets.all.each do |record|
            @grouping.call(record.values, nil, record, group)
            record.save!
          end
        end
      end
    end
    
    def get_lookup_record(name, marker)
      lookup = get_lookup(name)
      return [lookup, lookup.versions.find_or_create_by(:name => lookup.lookups[marker])]
    end
    
    def new_version?(name, version)
      lookup = get_lookup(name)
      raise InvalidLookupSetter, "Lookup '#{version}' for '#{name}' already set" if lookup.lookups.values.include?(version)
    end
    
    def get_lookup(name)
      lookup = DbStore::Lookup.where(:name => name).first
      raise InvalidLookup, "Attempt to access invalid lookup: #{name}" unless lookup
      lookup
    end
  end
end