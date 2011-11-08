class Wherever
  module Adder
    def add(values, options)
      if record = find(identifier_key(options))
        update(record.diff(values), record, options)
      else
        create(values, options)
      end
    end
  
    protected
    def find(key)
      identifier_set.datasets.where(key).first
    end
  
    def create(values, options)
      for_unique(values, options)
      id_record = create_for_identifier(values, options)
      config.key_groups.each do |group|
        for_group(group, values, id_record)
      end
    end

    def update(diff, record, options)
      for_unique(diff, options)
      id_record = update_for_identifier(diff, record, options["unique"]["version"])
      config.key_groups.each do |group|
        for_group(group, diff, id_record)
      end
    end
  
    def create_for_identifier(values, options)
      record = identifier_set.datasets.create(version_key(options))
      update_record(record, values, record)
    end
  
    def update_for_identifier(diff, record, version)
      record["version"] = version
      update_record(record, diff, record)
    end

    def update_record(record, data, id_record, keys=config.keys)
      @grouping.call(record.values, data.clone, id_record, keys)
      record.save!
      record
    end
  
    def for_unique(values, options)
      unique_set.datasets.create(version_key(options).merge("values" => values.clone))
    end
  
    def for_group(group_keys, values, id_record, update_required=true)
      key = {}
      group_keys.each do |key_values|
        key.merge!(key_values.to_id => id_record[key_values.to_id])
      end
      store = get_key_store(*group_keys)
      record = store.datasets.find_or_create_by(key)

      update_record(record, values, id_record, group_keys)
      update_identifier(store, id_record) if update_required
    end
  
    def update_identifier(store, id_record)
      record = store.identifiers.find_or_create_by(config._id => id_record[config._id])
      record["version"] = id_record.version
      record.save
    end
  end
end