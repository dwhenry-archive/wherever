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
    
    def get_store(marker, keys, db_type)
      name = "#{marker.upcase}_#{keys.map(&:upcase).join('_')}_#{db_type.to_s.upcase}"
      return "DbStore::#{name}".constantize if DbStore.constants.include?(name)
      klass = DbStore.const_set(name, Class.new)
      klass.send :include, "DbStore::#{db_type.to_s.titlecase}Config".constantize
      klass.send :store_in, :"#{marker}_#{keys.join('_')}_#{db_type}"
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