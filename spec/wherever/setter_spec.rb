require 'spec_helper'

describe Wherever, 'setting values' do
  let(:wherever) { Wherever.new("keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund"] }
  let(:key_groups) { nil }
  
  context 'data storage' do
    before do
      wherever.create_lookup('price', ["security"])
    end
    
    it 'can save and retrieve version data' do
      record = {"security_id" => 12}
      wherever.set_price('current', {12 => 13.45})
      wherever.get_price('current', record).should == 13.45
    end
    
    it 'can not set the same version name twice' do
      wherever.set_price('current', {12 => 13.45})
      expect { wherever.set_price('current', {12 => 13.45}) }.to raise_error InvalidLookupSetter, "Lookup 'current' for 'price' already set"
    end
  end
end