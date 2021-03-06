require 'spec_helper'

describe Wherever, 'run file test' do
  let(:wherever) { Wherever.new("keys" => keys, "database" => 'wherever_test',
               "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund", "technical_instrument"] }
  let(:key_groups) { [["fund"], ["fund", "technical_instrument"]] }
    
  before do
    wherever.add_grouping do |values, data, record, keys|
      price = wherever.get_price('current', record)
      values["price"] =  price
      if data
        values["position"] ||= 0
        values["position"] += data["position"] 
        values["trade_value"] ||= 0
        values["trade_value"] += data["position"] * price 
      else
        values["trade_value"] = values["position"] * price 
      end
    end

    summer = lambda do |records|
      trade_value = records.sum{|r| r.values['trade_value']}
      {'values' => {'trade_value' => trade_value } }
    end
    wherever.add_summing(['fund'], 'summer' => summer, 'source' => ['fund', 'technical_instrument'])
    wherever.create_lookup('price', ["technical_instrument"])
  end
  
  it 'processes a script file' do
    file = File.expand_path(File.dirname(__FILE__) + '/../data/test_file_1.script')
    File.open(file) do |f|
      while !f.eof do
        eval(f.readline)
      end
    end

    data = wherever.get_key_store('fund').datasets.all.to_a.sort_by(&:fund_id)
    data.should == [
      DbStore::Dataset.new("values" => {"trade_value" => 1078574.78347554}, "fund_id" => 2),
      DbStore::Dataset.new("values" => {"trade_value" => 10110445.4601847}, "fund_id" => 3),
      DbStore::Dataset.new("values" => {"trade_value" => 3882339.86299649}, "fund_id" => 4),
      DbStore::Dataset.new("values" => {"trade_value" => 37136876.9682663}, "fund_id" => 5),
      DbStore::Dataset.new("values" => {"trade_value" => 12371476.6074616}, "fund_id" => 6),
      DbStore::Dataset.new("values" => {"trade_value" => 12928015.20472},   "fund_id" => 7),
      DbStore::Dataset.new("values" => {"trade_value" => 5529137.63911313}, "fund_id" => 8),
      DbStore::Dataset.new("values" => {"trade_value" => 961021.11258642},  "fund_id" => 9),
      DbStore::Dataset.new("values" => {"trade_value" => 7433216.25251049}, "fund_id" => 10),
      DbStore::Dataset.new("values" => {"trade_value" => 939194.3717994},   "fund_id" => 11)
      ]
  end
end