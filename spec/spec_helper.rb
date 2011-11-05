$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'wherever'
require 'ruby-debug'
require 'database_cleaner'

Wherever.new("keys" => ["fund"], "database" => 'wherever_test')

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
#  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.before(:each) do
    DatabaseCleaner.orm = "mongoid" 
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
