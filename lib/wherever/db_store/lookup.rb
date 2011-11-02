module DbStore
  class Lookup
    include Mongoid::Document
    embeds_many :versions, :class_name => 'DbStore::Version'
    field :name, :type => String
    field :keys, :type => Hash
    field :lookups, :type => Hash, :default => {}
  end
  
  class Version
    include Mongoid::Document
    embedded_in :lookup, :inverse_of => :versions, :class_name => 'DbStore::Lookup'
    field :name, :type => String
    field :values, :type => Hash, :default => Hash.new(0)
  end
end