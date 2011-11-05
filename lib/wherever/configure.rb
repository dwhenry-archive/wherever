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
  
    @keys = StringHelper.add_method_to_id(options["keys"], false)
    @key_groups = StringHelper.add_method_to_id(options["key_groups"] || options["keys"])
  end
end
