class Wherever
  module Adder
    def add(values, options)
      @options = options
      if record = find
        update(record.diff(values), record)
      else
        create(values)
      end
    end
  
    protected
    def find
      identifier_set.datasets.where(identifier_key).first
    end
  
    def create(values)
      for_unique(values)
      id_record = create_for_identifier(values)
      config.key_groups.each do |group|
        for_group(group, values, id_record)
      end
    end

    def update(diff, record)
      for_unique(diff)
      id_record = update_for_identifier(diff, record)
      config.key_groups.each do |group|
        for_group(group, diff, id_record)
      end
    end
  
    def create_for_identifier(values)
      record = identifier_set.datasets.create(version_key)
      update_record(record, values, record)
    end
  
    def update_for_identifier(diff, record)
      record["version"] = @options["unique"]["version"]
      update_record(record, diff, record)
    end

    def update_record(record, data, id_record, keys=config.keys)
      @grouping.call(record.values, data.clone, id_record, keys)
      record.save!
      record
    end
  
    def for_unique(values)
      unique_set.datasets.create(version_key.merge("values" => values.clone))
    end
  
    def for_group(group_keys, values, id_record)
      key = {}
      group_keys.each do |key_values|
        key.merge!(key_values.to_id => @options["keys"][key_values.to_id])
      end
      store = get_key_store(*group_keys)
      record = store.datasets.find_or_create_by(key)

      update_record(record, values, id_record, group_keys)
      update_identifier(store, @options["unique"])
    end
  
    def update_identifier(store, unique)
      record = store.identifiers.find_or_create_by(config._id => unique[config._id])
      record["version"] = unique["version"]
      record.save
    end
  end
end