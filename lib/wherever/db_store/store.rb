module DbStore
  class Store
    include Mongoid::Document
    embedded_in :marker, :class_name => 'DbStore::Marker'
    embeds_many :datasets, :class_name => 'DbStore::Dataset'
    embeds_many :identifiers, :class_name => 'DbStore::Identifier'
    field :key, :type => Array
  end
end