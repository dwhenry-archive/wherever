module DbStore
  class Identifier
    include Mongoid::Document
    embedded_in :store, :inverse_of => :identifiers, :class_name => 'DbStore::Store'
    include DbStore::RecordMatcher
    
    field :_id, :type => Integer
    field :version, :type => Integer
  end
end