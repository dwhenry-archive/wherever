class Configure
  attr_accessor :keys, :key_groups, :_id
  def initialize(options)
    host = options["host"] || 'localhost'
    database = options["database"] || 'wherever'
    user = options["user"]
    password = options["password"]
    @_id = options["key"] ||= "unqiue_id"

    Mongoid.config do |config|
      mongo_connection = Mongo::Connection.new(host).db(database)
      mongo_connection.authenticate(user, password) if user
      config.master = mongo_connection
    end
  
    @keys = options["keys"]
    groups = options["key_groups"] || @keys.map{|k| k.gsub(/_id$/,'')}
    @key_groups = groups.map{|g| Array(g)}
  end
end
