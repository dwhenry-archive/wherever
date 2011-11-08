require 'spec_helper'

describe Wherever, 'using lookup in grouping calculation' do
  let(:create_options) { ["keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id"] }
  let(:wherever) { 
    Wherever.new(*create_options) do |values, data, record, keys|
      price = wherever.get_price('current', record)
      if keys.include?("security")
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
  let(:keys) { ["fund", "security"] }
  let(:key_groups) { ["fund", "security", ["fund", "security"]] }
  
  context 'add record after price' do
    context 'has the correct trade value calculation' do
      let(:options_one) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
      let(:options_two) { {"unique" => {"trade_id" => 12, "version" => 2}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
      let(:options_three) { {"unique" => {"trade_id" => 14, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }

      before do
        wherever.create_lookup('price', ["security"])
        wherever.set_price('current', {4 => 12.5})
        wherever.add({"position" => 100}, options_one)
      end
      
      it 'on identifier record' do
        wherever.get_key_store("identifier").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"position" => 100, "price" => 12.5, "trade_value" => 1250}, 
                "trade_id" => 12, "version" => 1, "fund_id" => 2, "security_id" => 4)] 
      end
      
      it 'on fund record' do
        wherever.get_key_store("fund").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"trade_value" => 1250}, "fund_id" => 2)] 
      end

      it 'on fund record with trade edit' do
        wherever.add({"position" => 110}, options_two)
        wherever.get_key_store("fund").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"trade_value" => 1375}, "fund_id" => 2)] 
      end

      it 'on fund record with two trades' do
        wherever.add({"position" => 200}, options_three)
        wherever.get_key_store("fund").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"trade_value" => 3750}, "fund_id" => 2)] 
      end
    end
  end
  
  context 'add price after record' do
    context 'has the correct trade value calculation' do
      let(:options_one) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
      let(:options_two) { {"unique" => {"trade_id" => 12, "version" => 2}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
      let(:options_three) { {"unique" => {"trade_id" => 14, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }

      before do
        wherever.create_lookup('price', ["security"])
        wherever.add({"position" => 100}, options_one)
      end
      
      it 'on identifier record' do
        wherever.create_lookup('price', ["security"])
        wherever.set_price('current', {4 => 12.5})
        wherever.get_key_store("identifier").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"position" => 100, "price" => 12.5, "trade_value" => 1250}, 
                "trade_id" => 12, "version" => 1, "fund_id" => 2, "security_id" => 4)] 
      end
      
      it 'on fund record' do
        wherever.create_lookup('price', ["security_id"])
        wherever.set_price('current', {4 => 12.5})
        wherever.get_key_store("fund").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"trade_value" => 1250}, "fund_id" => 2)] 
      end

      it 'on fund record with trade edit' do
        wherever.add({"position" => 110}, options_two)
        wherever.create_lookup('price', ["security_id"])
        wherever.set_price('current', {4 => 12.5})
        wherever.get_key_store("fund").datasets.all.should ==
            [DbStore::Dataset.new("values" => {"trade_value" => 1375}, "fund_id" => 2)] 
      end

      it 'on fund record with two trades' do
        wherever.add({"position" => 200}, options_three)
        wherever.set_price('current', {4 => 12.5})
        wherever.get_key_store("fund").datasets.all.to_a.should ==
            [DbStore::Dataset.new("values" => {"trade_value" => 3750}, "fund_id" => 2)] 
      end
    end
  end
end