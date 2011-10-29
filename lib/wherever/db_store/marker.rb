module DbStore
  class Marker
    include Mongoid::Document
    embeds_many :stores, :class_name => 'DbStore::Store'
    field :name, :type => String
    field :price, :type => String
    
    def self.find_by_name(name)
      find_or_create_by({:name => name})
    end
  end
end