class Wherever
  class Identifier
    include Mongoid::Document
    
    def diff(values)
      result = values.clone
      result.keys.each do |key|
        result[key] -= self[key]
      end
    end
  end
end