module DbStore
end

require 'wherever/db_store/record_matcher'
require 'wherever/db_store/dataset'
require 'wherever/db_store/identifier'

require 'wherever/db_store/lookup'

module DbStore
  class << self
    attr_reader :stores
    def new_store(marker, keys)
      @stores ||= {}
      @stores[[marker, keys]] = Container.new(
          get_store(marker, keys, :identifier),
          get_store(marker, keys, :dataset)
      )
    end

    def new_lookup(name, keys=nil)
      @stores ||= {}
      @stores[name] = get_lookup(name, keys)
    end
    
    def get_store(marker, keys, db_type)
      name = "#{marker.upcase}_#{keys.map(&:upcase).join('_')}_#{db_type.to_s.upcase}"
      return "DbStore::#{name}".constantize if DbStore.constants.include?(name)
      build_class(name, "DbStore::#{db_type.to_s.titlecase}Config".constantize, :"#{marker}_#{keys.join('_')}_#{db_type}")
    end
    
    def get_lookup(name, keys)
      DbStore::Lookup.find_or_create_by(:name => name, :keys => keys) if keys
      return "DbStore::Lookup#{name}".constantize if DbStore.constants.include?("Lookup#{name}")
      raise "Missing lookup key from definition" unless keys
      build_class("Lookup#{name}", DbStore::VersionConfig, :"lookup_#{name}")
    end
    
    def build_class(name, module_object, store_in)
      klass = DbStore.const_set(name, Class.new)
      klass.send :include, module_object
      klass.send :store_in, store_in
      klass
    end
    
    class Container
      attr_reader :identifiers, :datasets
      
      def initialize(identifier, dataset)
        @identifiers, @datasets = identifier, dataset
      end
    end
  end
end