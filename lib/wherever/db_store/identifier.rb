module DbStore
  class Identifier
    include Mongoid::Document
    include DbStore::RecordMatcher
    field :_id, :type => Integer
    field :version, :type => Integer
  end
  
  module IdentifierConfig
    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, DbStore::RecordMatcher
    
      base.field :_id, :type => Integer
      base.field :version, :type => Integer
    end
  end    
end