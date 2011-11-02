require 'spec_helper'

describe Wherever, 'mark a time point' do
  let(:create_options) { ["keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id"] }
  let(:wherever) { 
    Wherever.new(*create_options) do |values, data, record, keys|
      price = wherever.get_price('current', record)
      if keys.include?("security_id")
        values["position"] += data["position"] if data
        values["price"] =  price
      end
      if data
        values["trade_value"] += data["position"] * price
      else
        values["trade_value"] = values["position"] * price
      end
    end
  }
  let(:keys) { ["fund_id", "security_id"] }
  let(:key_groups) { ["fund", "security", ["fund", "security"]] }
  
  let(:options_one) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
  let(:options_two) { {"unique" => {"trade_id" => 14, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }

  before do
    wherever.create_lookup('price', ["security_id"])
    wherever.set_price('20111029_01', {4 => 12.5})
    wherever.add({"position" => 100}, options_one)
    wherever.mark('COB_20111009')
  end

  it 'can retrieve data via marker name' do
    wherever.get({"fund_id" => 2}, 'COB_20111009').should == {"trade_value" => 1250}
  end
  
  context 'adding new record' do
    it 'does not change marker record' do
      wherever.add({"position" => 100}, options_two)
      wherever.get({"fund_id" => 2}, 'COB_20111009').should == {"trade_value" => 1250}
      wherever.get({"fund_id" => 2}).should == {"trade_value" => 2500}
    end
  end
  
  context 'adding price data' do
    it 'does not change marker record' do
      wherever.set_price('20111029_02', {4 => 13.5})
      wherever.get({"fund_id" => 2}, 'COB_20111009').should == {"trade_value" => 1250}
      wherever.get({"fund_id" => 2}).should == {"trade_value" => 1350}
    end
  end
end