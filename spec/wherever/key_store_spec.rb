require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Wherever" do
  let(:wherever) { Wherever.new("keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund"] }
  let(:key_groups) { nil }
    
  context 'get the key store' do
    context 'when a single element key' do
      let(:store) { wherever.get_key_store("fund") }
      it 'sets the class name' do
        store.identifiers.to_s.should == "DbStore::CURRENT_FUND_IDENTIFIER"
        store.datasets.to_s.should == "DbStore::CURRENT_FUND_DATASET"
      end

      it 'sets the table' do
        store.identifiers.collection_name.should == "current_fund_identifier"
        store.datasets.collection_name.should == "current_fund_dataset"
      end
    end

    context 'when a multiple element keys' do
      let(:store) { wherever.get_key_store("fund", "security") }
      it 'sets the class name' do
        store.identifiers.to_s.should == "DbStore::CURRENT_FUND_SECURITY_IDENTIFIER"
        store.datasets.to_s.should == "DbStore::CURRENT_FUND_SECURITY_DATASET"
      end

      it 'sets the table' do
        store.identifiers.collection_name.should == "current_fund_security_identifier"
        store.datasets.collection_name.should == "current_fund_security_dataset"
      end
    end
  end
end