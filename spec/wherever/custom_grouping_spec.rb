require 'spec_helper'

describe Wherever, 'with a custom grouping' do
  let(:create_options) { ["keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id"] }
  let(:wherever) { 
    Wherever.new(*create_options) do |values, data, record, keys|
      values["settled"] += data["settled"]
      values["unsettled"] += data["settled"] * -2.5
    end
  }

  context 'add a record' do
    let(:keys) { ["fund"] }
    let(:key_groups) { nil }
    let(:options) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2}} }

    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, options)
    end
    
    it 'the identifier record' do
      wherever.get_key_store("identifier").datasets.all.should ==
          [DbStore::Dataset.new("values" => {"unsettled" => -250, "settled" => 100}, "fund_id" => 2, "version" => 1, "trade_id" => 12)] 
    end

    it 'the grouped record' do
      wherever.get_key_store("fund").datasets.all.should ==
          [DbStore::Dataset.new("values" => {"unsettled" => -250, "settled" => 100}, "fund_id" => 2)] 
    end
  end
  
  context 'get a record' do
    let(:keys) { ["fund", "security"] }
    let(:key_groups) { ["fund"] }
    let(:options_one) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 14}} }
    let(:options_two) { {"unique" => {"trade_id" => 15, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 14}} }

    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, options_one)
    end
    
    it 'gets the value for a non key field' do
      wherever.get("security_id" => 14).should == {"settled" => 100, "unsettled" => -250}
    end
    
    it 'gets the value for a non key field when multiple records' do
      wherever.add({"settled" => 200, "unsettled" => 0}, options_two)
      wherever.get("security_id" => 14).should == {"settled" => 300, "unsettled" => -750}
    end
  end
end