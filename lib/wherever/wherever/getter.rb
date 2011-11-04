class Wherever
  module Getter
    def get(selector, mark=marker)
      keys = get_keys_from(selector) + [{"marker" => mark}]
      result = Hash.new(0)
      if keys.first == "identifier"
        get_key_store(*keys).datasets.where(selector).all.each do |record|
          @grouping.call(result, record.values, result, keys)
        end
        result
      else
        get_key_store(*keys).datasets.where(selector).first.try(:values) || {}
      end
    end
    
    protected
    def get_keys_from(selector)
      check_keys(selector.keys)
      keys = selector.keys.map{|key| key.gsub(/_id$/, '') }
      config.key_groups.each do |group|
        return group if (group & keys) == group && (keys & group) == keys
      end
      ["identifier"]
    end
    
    def check_keys(keys)
      invalid_keys = (keys - config.keys.map(&:to_id))
      raise InvalidSelector,"Unknown Selector: #{invalid_keys.join(' ')}" unless invalid_keys.empty?
    end
  end
end