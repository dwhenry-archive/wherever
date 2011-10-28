class Wherever
  class << self
    def get_key_store(*keys)
      #@store ||= {}
      #return @store[keys] if @store[keys]
      #@store[keys] = Builder.create(*keys)
      Builder.create(*keys)
    end
  end
  
  def config
    Configure
  end
  
  def initialize(options={})
    Configure.setup(options)
  end
  
  def add(values, options)
    if record = find(values, options)
      diff = record.diff(values)
      update(record, diff, options)
    else
      create(values, options)
    end
  end
  
  def find(values, options)
    key = {}
    key.merge!(options[:unique])
    key.merge!(options[:keys])
    key.delete(:version)
    
    Wherever.get_key_store(:identifier).datasets.where(key).first
  end
  
  def update(record, diff, options)
    create_for_unique(diff, options)
    update_for_identifier(record, diff, options)
        
    Configure.key_groups.each do |group|
      set_for_group(group, diff, options)
    end
  end
  
  def create(values, options)
    create_for_unique(values, options)
    create_for_identifier(values, options)

    Configure.key_groups.each do |group|
      set_for_group(group, values, options)
    end
  end

  def create_for_identifier(values, options)
    key = {}
    key.merge!(options[:unique])
    key.merge!(options[:keys])
    key.merge!(values)
    Wherever.get_key_store(:identifier).datasets.create(key)
  end
  
  def update_for_identifier(record, diff, options)
    key = {}
    key.merge!(options[:unique])
    key.merge!(options[:keys])
    key.delete(:version)

    diff.keys.each do |key|
      record[key] ||= 0
      record[key] += diff[key]
    end
    record[:version] = options[:unique][:version]
    record.save
  end

  def create_for_unique(values, options)
    key = {}
    key.merge!(options[:unique])
    key.merge!(options[:keys])
    key.merge!(values)
    
    Wherever.get_key_store(:unique).datasets.create(key)
  end
  
  def set_for_group(group_keys, values, options, store=nil)
    key = {}
    group_keys.each do |key_values|
      k_id = :"#{key_values}_id"
      key.merge!(k_id => options[:keys][k_id])
    end
    store ||= Wherever.get_key_store(*group_keys)

    record = store.datasets.find_or_create_by(key)
    
    values.keys.each do |key|
      record[key] ||=  0
      record[key] += values[key]
    end
    record.save

    record = store.identifiers.find_or_create_by(config._id => options[:unique][config._id])
    record[:version] = options[:unique][:version]
    record.save
  end

  module Configure
    class << self
      attr_accessor :keys, :key_groups, :_id
      def setup(options)
        host = options[:host] || 'localhost'
        database = options[:database] || 'wherever'
        user = options[:user]
        password = options[:password]
        @_id = options[:key] ||= :unqiue_id

        Mongoid.config do |config|
          mongo_connection = Mongo::Connection.new(host).db(database)
          mongo_connection.authenticate(user, password) if user
          config.master = mongo_connection
        end
      
        @keys = options[:keys]
        groups = options[:key_groups] || @keys.map{|k| k.to_s.gsub(/_id$/,'').to_sym}
        @key_groups = groups.map{|g| Array(g)}
      end
    end
  end
end