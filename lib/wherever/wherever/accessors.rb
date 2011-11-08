class Wherever
  module Accessors
    def get_key_store(*keys)
      DbStore.new_store(get_marker(keys), keys)
    end
    
    protected
    def get_marker(keys=[])
      keys.last.is_a?(Hash) ? keys.pop["marker"] : marker
    end
    
    def collection(mark=marker)
      DbStore::Marker.find_by_name(mark)
    end
    
    def identifier_set
      get_key_store("identifier")
    end
    
    def unique_set
      get_key_store("unique")
    end
    
    def identifier_key(options)
      key = version_key(options)
      key.delete("version")
      key
    end
    
    def version_key(options)
      {}.merge(options["unique"]).merge(options["keys"])
    end
  end
end