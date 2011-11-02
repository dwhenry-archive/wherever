module DbStore
  class Identifier
    include Mongoid::Document
    include DbStore::RecordMatcher
    
    field :version, :type => Integer
  end
  
  module IdentifierConfig
    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, DbStore::RecordMatcher
    
      base.field :version, :type => Integer
    end
  end    
end