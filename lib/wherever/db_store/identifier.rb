module DbStore
  module IdentifierConfig
    def self.included(base)
      base.send :include, Mongoid::Document
      base.send :include, DbStore::RecordMatcher
    
      base.field :_id, :type => Integer
      base.field :version, :type => Integer
    end
  end    
end