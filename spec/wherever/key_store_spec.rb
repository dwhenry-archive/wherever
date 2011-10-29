require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Wherever" do
  let(:wherever) { Wherever.new("keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund_id"] }
  let(:key_groups) { nil }
    
  context 'get the key store' do
    context 'when a single element key' do
      let(:store) { wherever.get_key_store("fund") }
      it 'sets the class name' do
        store.key.should == ["fund"]
      end
    end

    context 'when a multiple element keys' do
      let(:store) { wherever.get_key_store("fund", "security") }
      it 'sets the class name' do
        store.key.should == ["fund", "security"]
      end
    end
  end
end