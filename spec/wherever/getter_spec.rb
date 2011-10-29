require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Wherever" do
  let(:wherever) { Wherever.new("keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund_id"] }
  let(:key_groups) { nil }

  context 'getting the record data' do
    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, {"unique" => {"trade_id" => 12, "version" => 2}, "keys" => {"fund_id" => 3}})
    end

    it 'for one of the key groups' do
      wherever.get("fund_id" => 3).should == {"settled" => 100, "unsettled" => 0}
    end
    
    it 'get a value that does not exist' do
      wherever.get("fund_id" => 4).should == {}
    end
  end
  
  context 'a more complex example' do
    let(:keys) { ["fund_id", "security_id"] }
    let(:key_groups) { ["fund", ["fund", "security"]] }
    let(:options) { {"unique" => {"trade_id" => 12, "version" => 2}, "keys" => {"fund_id" => 3, "security_id" => 12}} }
    
    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, options)
    end
    
    it 'get by a single value key' do
      wherever.get("fund_id" => 3).should == {"settled" => 100, "unsettled" => 0}
    end

    it 'get by a field that is not a key' do
      wherever.get("security_id" => 12).should == {"settled" => 100, "unsettled" => 0}
    end
    
    it 'get by a multi value key' do
      wherever.get("fund_id" => 3, "security_id" => 12).should == {"settled" => 100, "unsettled" => 0}
    end
    
    it 'invalid selector field' do
      expect { wherever.get("broker_id" => 3) }.to raise_error InvalidSelector, "Unknown Selector: broker_id"
    end
  end
end