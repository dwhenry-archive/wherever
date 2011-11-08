class InvalidSelector < StandardError; end
class InvalidLookup <  StandardError; end
class InvalidLookupSetter <  StandardError; end

class Wherever
  include Accessors
  include Adder
  include Getter
  include Lookup
  include Recalculate
  include Mark
  attr_reader :config, :marker
  
  LogMethods = [:add, :get, :get_key_store, :mark]
  
  def initialize(options={}, &grouping)
    @config = Configure.new(options)
    @marker = options[:marker] || 'current'
    if block_given?
      @grouping = grouping
    else
      @grouping = lambda do |values, data, record, keys|
        data.keys.each do  |key|
          values[key] += data[key]
        end
      end
    end
    @summing = {}
    if options['method_logging']
      MethodLogging.add(self.class)
    end
  end
  
  def add_grouping(&grouping)
    @grouping = grouping
  end
  
  def add_summing(key, options)
    @summing[key] = options
  end
end