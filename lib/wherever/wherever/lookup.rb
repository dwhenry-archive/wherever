class Wherever
  module Lookup
    def create_lookup(name, keys)
      lookup = DbStore::Lookup.find_or_create_by(:name => name)
      lookup.keys = keys
      lookup.save

      self.class.class_eval do
        define_method "set_#{name}" do |version, values|
          lookup, record = create_lookup_record(name, version)
          record.values = key_to_string(values)
          record.save
          recalculate if set_price_lookup(name, version)
        end
      end
    
      self.class.class_eval do
        define_method "get_#{name}" do |marker, data|
          lookup, record = get_lookup_record(name, marker)
          value_key = lookup.keys.map{|key| data[key]}.join('_')
          record.values[value_key] || 0
        end
      end
    end
  
    protected
    def key_to_string(values)
      string_values = {}
      values.each {|k, v| string_values[Array[k].join('_')] = v}
      string_values
    end
    
    def set_price_lookup(name, version=nil, keys=[])
      lookup = get_lookup(name)
      return false if lookup.lookups[get_marker] == version
      lookup.lookups[get_marker(keys)] = (version || lookup.lookups['current'])
      lookup.save
    end
    
    def recalculate
      config.key_groups.each do |group|
        get_key_store(*group).datasets.delete_all
      end
      
      identifier_set.datasets.all.each do |record|
        @grouping.call(record.values, nil, record, config.keys)
        record.save!
        config.key_groups.each do |group|
          for_group(group, record.values, record)
        end
      end
    end
    
    def get_lookup_record(name, marker)
      lookup = get_lookup(name)
      return [lookup, lookup.versions.find_or_create_by(:name => lookup.lookups[marker])]
    end
    
    def create_lookup_record(name, version)
      lookup = get_lookup(name)
      records = lookup.versions.where(:name => version)
      raise InvalidLookupSetter, "Lookup '#{version}' for '#{name}' already set" unless records.empty?
      return [lookup, lookup.versions.find_or_create_by(:name => version)]
    end
    
    def get_lookup(name)
      lookup = DbStore::Lookup.where(:name => name).first
      raise InvalidLookup, "Attempt to access invalid lookup: #{name}" unless lookup
      lookup
    end
  end
end