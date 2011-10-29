module DbStore
  class Lookup
    include Mongoid::Document
    embeds_many :versions, :class_name => 'DbStore::Version'
    field :name, :type => String
    field :keys, :type => Hash
  end
  
  class Version
    include Mongoid::Document
    embedded_in :lookup, :class_name => 'DbStore::Lookup'
    field :name, :type => String
    field :values, :type => Hash, :default => Hash.new(0)
  end
end