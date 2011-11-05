module StringHelper
  class << self
    def add_method_to_id(strings, as_array=true)
      return nil unless strings
      strings.map do |string|
        if string.is_a?(Array)
          add_method_to_id(string, false)
        else
          def string.to_id
            "#{self}_id"
          end
          as_array ? [string] : string
        end
      end
    end 
  end
end