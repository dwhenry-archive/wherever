module DbStore
  class Lookup
    include Mongoid::Document
    field :name, :type => String
    field :keys, :type => Hash
    field :lookups, :type => Hash, :default => {}
    field :current, :type => String
  end
  
  class Version
    include Mongoid::Document
    embedded_in :lookup, :inverse_of => :versions, :class_name => 'DbStore::Lookup'
    field :name, :type => String
    field :values, :type => Hash, :default => Hash.new(0)
  end

  module VersionConfig
    def self.included(base)
      base.send :include, Mongoid::Document
      base.field :name, :type => String
      base.field :values, :type => Hash, :default => Hash.new(0)
    end
  end
end