class Wherever
  module Recalculate
    def recalculate(name)
      keys = get_lookup(name).keys
      
      recalculate_identifier

      groups = config.key_groups
      groups_with_key, groups_without_key = groups.partition do |group|
        group & keys == keys
      end
      
      groups_with_key.each do |group|
        recalculate_with_key(group)
      end
      
      @summing.each do |group, options|
        groups_without_key.delete(group)
        get_key_store(*group).datasets.delete_all
        sum_group_for(StringHelper.add_method_to_id(group, false), options)
      end
      groups_without_key.each do |group|
        get_key_store(*group).datasets.delete_all
        identifier_set.datasets.all.each do |record|
          for_group(group, record.values, record, false)
        end
      end
    end

    def sum_group_for(group, options)
      group_by = options['group_by'] || lambda do |record| 
        group.inject({}) { |r, v| r[v.to_id] = record[v.to_id]; r }
      end
      summer = options['summer'] || raise('Summer must be set.')
      source = options['source'] || ['identifier']
      
      grouped = get_key_store(*source).datasets.all.group_by{|record| group_by.call(record)}
      grouped.map do |key, records|
        get_key_store(*group).datasets.create(key.merge(summer.call(records)))
      end
    end
    
    def recalculate_identifier
      identifier_set.datasets.all.each do |record|
        @grouping.call(record.values, nil, record, config.keys)
        record.save!
      end
    end
    
    def recalculate_with_key(group)
      get_key_store(*group).datasets.all.each do |record|
        @grouping.call(record.values, nil, record, group)
        record.save!
      end
    end
  end
end
