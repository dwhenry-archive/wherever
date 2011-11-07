require 'spec_helper'

describe "Wherever", 'method logging' do
  let(:wherever) { Wherever.new("method_logging" => true, "keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund"] }
  let(:key_groups) { nil }
  let(:options) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2}} }
  let(:file) { mock(:file_io) }
  before do
    MethodLogging.stub(:log => true)
  end
  context 'the add method' do
    
    it 'is logged to file' do
      call_string = %Q{Called: add({"unsettled" => 0, "settled" => 100}, {"keys" => {"fund_id" => 2}, "unique" => {"trade_id" => 12, "version" => 1}})}
      MethodLogging.should_receive(:log).with(call_string)
      wherever.add({"settled" => 100, "unsettled" => 0}, options)
    end
  end
  
  context 'the get key method' do
    it 'is logged to file' do
      call_string = %Q{Called: get_key_store("identifier")}
      MethodLogging.should_receive(:log).with(call_string)
      wherever.get_key_store("identifier").datasets.all
    end
  end
end
