class Wherever
  module Accessors
    def get_key_store(*keys)
      mark = keys.last.is_a?(Hash) ? keys.pop["marker"] : marker
      collection(mark).stores.find_or_create_by(:key => keys)
    rescue => e
      p e.inspect
      p mark
      p keys
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
    
    def identifier_key
      key = version_key
      key.delete("version")
      key
    end
    
    def version_key
      {}.merge(@options["unique"]).merge(@options["keys"])
    end
  end
end