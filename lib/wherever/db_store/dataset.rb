module DbStore
  class Dataset
    include Mongoid::Document
    include DbStore::RecordMatcher
    field :values, :type => Hash, :default => Hash.new(0)
  end
  
  module DatasetConfig
    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, DbStore::RecordMatcher
      base.field :values, :type => Hash, :default => Hash.new(0)
    end
  
    def diff(record)
      res = {}
      record.keys.each do |key|
        res[key] = record[key] - self.values[key]
      end
      res
    end 
  end
end