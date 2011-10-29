module DbStore
  module RecordMatcher
    def ==(record)
      self.clean_attributes == record.clean_attributes
    end
    
    protected
    def clean_attributes
      att = self.attributes.clone
      att.delete('_id')
      att
    end

    def clean_attributes_a
      clean_hash(self.attributes)
    end

    def clean_hash(values)
      res = {}
      values.each do |k, v|
        if k == :_id
          res[k.to_s] = v.is_a?(Hash) ? clean_hash(v) : v
        end
      end
      res
    end
  end
end