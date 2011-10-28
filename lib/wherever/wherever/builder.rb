class Wherever
  class Builder
    def self.create(*keys)
      Wherever::Store.find_by_name(keys.join('_'))
      # klass = Class.new do
      #   include Mongoid::Document
      #   store_in :"wherever_#{keys.join('_')}_key"
      # end
      # Wherever.add_class("#{keys.map{|key| key.to_s.titlecase}.join()}Key", klass)
      # klass
    end
  end
  
  def self.add_class(name, klass)
    const_set(name, klass)
  end
  
  module RecordMatcher
    def ==(record)
      self.clean_attributes == record.clean_attributes
    end
    
    protected
    def clean_attributes
      att = self.attributes.clone
      att.delete('_id')
      att
    end
  end

  class Dataset
    include Mongoid::Document
    include Wherever::RecordMatcher
    embedded_in :store, :class_name => 'Wherever::Store'
    
    def diff(record)
      res = {}
      record.keys.each do |key|
        res[key] = record[key] - self[key]
      end
      res
    end 
  end

  class Identifier
    include Mongoid::Document
    embedded_in :store, :class_name => 'Wherever::Store'
    include Wherever::RecordMatcher
    
    field :_id, :type => Integer
    field :version, :type => Integer
  end

  class Store
    include Mongoid::Document
    embeds_many :datasets, :class_name => 'Wherever::Dataset'
    embeds_many :identifiers, :class_name => 'Wherever::Identifier'
    
    def self.find_by_name(name)
      find_or_create_by({:name => name})
    end
  end
  
end