module StringHelper
  class << self
    def add_method_to_id(strings)
      return nil unless strings
      strings.each do |string|
        if string.is_a?(Array)
          add_method_to_id(string)
        else
          def string.to_id
            "#{self}_id"
          end
        end
      end
    end 
  end
end