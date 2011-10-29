module DbStore
  class Dataset
    include Mongoid::Document
    include DbStore::RecordMatcher
    embedded_in :store, :class_name => 'DbStore::Store'
    field :values, :type => Hash, :default => Hash.new(0)
    
    def price
      self.store.marker.price
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