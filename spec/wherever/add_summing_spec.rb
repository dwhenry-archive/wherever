require 'spec_helper'

describe Wherever, 'with a custom grouping' do
  let(:create_options) { ["keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id"] }
  let(:wherever) { Wherever.new(*create_options) }
  
  before do
    wherever.add_grouping do |values, data, record, keys|
      if data
        values["settled"] += data["settled"]
        values["unsettled"] += data["settled"] * -2.5
      end
    end

    summer = lambda do |records|
      settled = records.sum{|r| r.values['settled']}
      unsettled = records.sum{|r| r.values['unsettled']}
      {'values' => {'settled' => 2 * settled, 'unsettled' => 2 * unsettled } }
    end
    wherever.add_summing(['fund', 'technical_instrument'], 'summer' => summer)
    wherever.add_summing(['fund'], 'summer' => summer)
    wherever.create_lookup('price', ["technical_instrument"])
  end

  context 'add a record' do
    let(:keys) { ["fund"] }
    let(:key_groups) { nil }
    let(:options) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "technical_instrument_id" => 14}} }

    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, options)
      wherever.set_price('current', {4 => 12.5})
    end
    
    it 'the identifier record' do
      wherever.get_key_store("identifier").datasets.all.to_a.should ==
          [DbStore::Dataset.new("values" => {"unsettled" => -250, "settled" => 100}, 
                      "fund_id" => 2, "technical_instrument_id" => 14, "version" => 1, "trade_id" => 12)] 
    end

    it 'the grouped record' do
      wherever.get_key_store("fund").datasets.all.to_a.should ==
          [DbStore::Dataset.new("values" => {"unsettled" => -500, "settled" => 200}, "fund_id" => 2)] 
    end
  end
  
  context 'get a record' do
    let(:keys) { ["fund", "technical_instrument"] }
    let(:key_groups) { ["fund"] }
    let(:options_one) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "technical_instrument_id" => 14}} }
    let(:options_two) { {"unique" => {"trade_id" => 15, "version" => 1}, "keys" => {"fund_id" => 2, "technical_instrument_id" => 14}} }

    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, options_one)
      wherever.set_price('current', {4 => 12.5})
    end
    
    it 'gets the value for a non key field' do
      wherever.get("technical_instrument_id" => 14).should == {"settled" => 100, "unsettled" => -250}
    end
    
    it 'gets the value for a non key field when multiple records' do
      wherever.add({"settled" => 200, "unsettled" => 0}, options_two)
      wherever.get("technical_instrument_id" => 14).should == {"settled" => 300, "unsettled" => -750}
    end
  end
end