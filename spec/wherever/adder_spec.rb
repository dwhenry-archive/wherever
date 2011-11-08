require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Wherever" do
  let(:wherever) { Wherever.new("keys" => keys, "database" => 'wherever_test', "key_groups" => key_groups, "key" => "trade_id") }
  let(:keys) { ["fund"] }
  let(:key_groups) { nil }
    
  context 'adding the first record' do
    let(:options) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2}} }
    context 'the unique dataset' do
      it 'inserts a record' do
        wherever.add({"settled" => 100, "unsettled" => 0}, options)
        wherever.get_key_store("unique").datasets.all.should == 
              [DbStore::Dataset.new("trade_id" => 12, "values" => {"unsettled" => 0, "settled" => 100}, "version" => 1, "fund_id" => 2)] 
      end
    end
    
    context 'the id dataset' do
      it 'inserts a record' do
        wherever.add({"settled" => 100, "unsettled" => 0}, options)
        wherever.get_key_store("identifier").datasets.all.should ==
            [DbStore::Dataset.new("trade_id" => 12, "values" => {"unsettled" => 0, "settled" => 100}, "version" => 1, "fund_id" => 2)] 
      end
    end

    context 'the key datasets' do
      context 'with a single key' do
        it 'inserts a record' do
          wherever.add({"settled" => 100, "unsettled" => 0}, options)
          wherever.get_key_store("fund").datasets.all.should ==
              [DbStore::Dataset.new("values" => {"unsettled" => 0, "settled" => 100}, "fund_id" => 2)] 
          wherever.get_key_store("fund").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 1)] 
        end
      end

      context 'with a multiple keys' do
        let(:keys) { ["fund", "security"] }
        let(:options) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
        
        it 'inserts a record for each key combination' do
          wherever.add({"settled" => 100, "unsettled" => 0}, options)

          wherever.get_key_store("fund").datasets.all.should ==
              [DbStore::Dataset.new("values" => {"unsettled" => 0, "settled" => 100}, "fund_id" => 2)] 
          wherever.get_key_store("fund").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 1)] 

          wherever.get_key_store("security").datasets.all.should ==
              [DbStore::Dataset.new("values" => {"unsettled" => 0, "settled" => 100}, "security_id" => 4)] 
          wherever.get_key_store("security").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 1)] 
        end
      end

      context 'with a multiple keys and grouping configured' do
        let(:keys) { ["fund", "security"] }
        let(:key_groups) { ["fund", "security", ["fund", "security"]] }
        let(:options) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2, "security_id" => 4}} }
        
        it 'inserts a record for each key combination' do
          wherever.add({"settled" => 100, "unsettled" => 0}, options)

          wherever.get_key_store("fund").datasets.all.should ==
              [DbStore::Dataset.new("values" => {"unsettled" => 0, "settled" => 100}, "fund_id" => 2)] 
          wherever.get_key_store("fund").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 1)] 

          wherever.get_key_store("security").datasets.all.should ==
              [DbStore::Dataset.new("values" => {"unsettled" => 0, "settled" => 100}, "security_id" => 4)] 
          wherever.get_key_store("security").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 1)] 

          wherever.get_key_store("fund", "security").datasets.all.should ==
              [DbStore::Dataset.new("fund_id" => 2, "security_id" => 4, "values" => {"unsettled" => 0, "settled" => 100})] 
          wherever.get_key_store("fund", "security").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 1)] 
        end
      end
    end
  end
  
  context 'adding subsequent records' do
    let(:options_first) { {"unique" => {"trade_id" => 12, "version" => 1}, "keys" => {"fund_id" => 2}} }
    let(:options_second) { {"unique" => {"trade_id" => 12, "version" => 2}, "keys" => {"fund_id" => 2}} }
    before do
      wherever.add({"settled" => 100, "unsettled" => 0}, options_first)
    end
    
    context 'the unique dataset' do
      it 'add the change' do
        wherever.add({"settled" => 110, "unsettled" => 0}, options_second)

        data = wherever.get_key_store("unique").datasets.all.to_a.sort_by(&:sorter)
        data.should ==
            [DbStore::Dataset.new("fund_id" => 2, "trade_id" => 12, "version" => 1, "values" => {"unsettled" => 0, "settled" => 100}),
             DbStore::Dataset.new("fund_id" => 2, "trade_id" => 12, "version" => 2, "values" => {"unsettled" => 0, "settled" => 10})] 
      end
    end

    context 'the identifier dataset' do
      it 'updates the record' do
        wherever.add({"settled" => 110, "unsettled" => 0}, options_second)

        wherever.get_key_store("identifier").datasets.all.should ==
            [DbStore::Dataset.new("fund_id" => 2, "trade_id" => 12, "version" => 2, "values" => {"unsettled" => 0, "settled" => 110})]
      end
    end

    context 'the key datasets' do
      context 'with a single key' do
        it 'inserts a record' do
          wherever.add({"settled" => 110, "unsettled" => 0}, options_second)
          wherever.get_key_store("fund").datasets.all.should ==
              [DbStore::Dataset.new("values"  => {"unsettled" => 0, "settled" => 110}, "fund_id" => 2)] 
          wherever.get_key_store("fund").identifiers.all.should ==
              [DbStore::Identifier.new("trade_id" => 12, "version" => 2)] 
        end
      end
    end
  end
end
