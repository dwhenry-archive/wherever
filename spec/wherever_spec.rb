require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Wherever" do
  let(:wherever) { Wherever.new(:keys => keys, :database => 'wherever_test', :key_groups => key_groups, :key => :trade_id) }
  let(:keys) { [:fund_id] }
  let(:key_groups) { nil }
  
  before do
    Wherever::Store.delete_all
  end
  
  context 'get the key store' do
    context 'when a single element key' do
      let(:store) { Wherever.get_key_store(:fund) }
      it 'sets teh class name' do
        store.name.should == 'fund'
      end
      
      it 'sets the collection name' do
        store.collection.name.should == 'wherever_stores'
      end
    end

    context 'when a multiple element keys' do
      let(:store) { Wherever.get_key_store(:fund, :security) }
      it 'sets teh class name' do
        store.name.should == 'fund_security'
      end
      
      it 'sets the collection name' do
        store.collection.name.should == 'wherever_stores'
      end
    end
  end
  
  context 'adding the first record' do
    let(:options) { {:unique => {:trade_id => 12, :version => 1}, :keys => {:fund_id => 2}, :unsettled => false} }
    context 'the unique dataset' do
      it 'inserts a record' do
        wherever.add({:settled => 100, :unsettled => 0}, options)
        Wherever.get_key_store(:unique).datasets.should == 
              [Wherever::Dataset.new(:trade_id => 12, :unsettled => 0, :settled => 100, :version => 1, :fund_id => 2)] 
      end
    end
    
    context 'the id dataset' do
      it 'inserts a record' do
        wherever.add({:settled => 100, :unsettled => 0}, options)
        Wherever.get_key_store(:identifier).datasets.should ==
            [Wherever::Dataset.new(:trade_id => 12, :unsettled => 0, :settled => 100, :version => 1, :fund_id => 2)] 
      end
    end

    context 'the key datasets' do
      context 'with a single key' do
        it 'inserts a record' do
          wherever.add({:settled => 100, :unsettled => 0}, options)
          Wherever.get_key_store(:fund).datasets.should ==
              [Wherever::Dataset.new(:unsettled => 0, :settled => 100, :fund_id => 2)] 
          Wherever.get_key_store(:fund).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 1)] 
        end
      end

      context 'with a multiple keys' do
        let(:keys) { [:fund_id, :security_id] }
        let(:options) { {:unique => {:trade_id => 12, :version => 1}, :keys => {:fund_id => 2, :security_id => 4}, :unsettled => false} }
        
        it 'inserts a record for each key combination' do
          wherever.add({:settled => 100, :unsettled => 0}, options)

          Wherever.get_key_store(:fund).datasets.should ==
              [Wherever::Dataset.new(:unsettled => 0, :settled => 100, :fund_id => 2)] 
          Wherever.get_key_store(:fund).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 1)] 

          Wherever.get_key_store(:security).datasets.should ==
              [Wherever::Dataset.new(:unsettled => 0, :settled => 100, :security_id => 4)] 
          Wherever.get_key_store(:security).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 1)] 
        end
      end

      context 'with a multiple keys and grouping configured' do
        let(:keys) { [:fund_id, :security_id] }
        let(:key_groups) { [:fund, :security, [:fund, :security]] }
        let(:options) { {:unique => {:trade_id => 12, :version => 1}, :keys => {:fund_id => 2, :security_id => 4}, :unsettled => false} }
        
        it 'inserts a record for each key combination' do
          wherever.add({:settled => 100, :unsettled => 0}, options)

          Wherever.get_key_store(:fund).datasets.should ==
              [Wherever::Dataset.new(:unsettled => 0, :settled => 100, :fund_id => 2)] 
          Wherever.get_key_store(:fund).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 1)] 

          Wherever.get_key_store(:security).datasets.should ==
              [Wherever::Dataset.new(:unsettled => 0, :settled => 100, :security_id => 4)] 
          Wherever.get_key_store(:security).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 1)] 


          Wherever.get_key_store(:fund, :security).datasets.should ==
              [Wherever::Dataset.new(:fund_id => 2, :security_id => 4, :unsettled => 0, :settled => 100)] 
          Wherever.get_key_store(:fund, :security).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 1)] 
        end
      end
    end
  end
  
  context 'adding subsequent records' do
    let(:options_first) { {:unique => {:trade_id => 12, :version => 1}, :keys => {:fund_id => 2}, :unsettled => false} }
    let(:options_second) { {:unique => {:trade_id => 12, :version => 2}, :keys => {:fund_id => 2}, :unsettled => false} }
    before do
      wherever.add({:settled => 100, :unsettled => 0}, options_first)
    end
    
    context 'the unique dataset' do
      it 'add the change' do
        wherever.add({:settled => 110, :unsettled => 0}, options_second)

        Wherever.get_key_store(:unique).datasets.should ==
            [Wherever::Dataset.new(:fund_id => 2, :trade_id => 12, :version => 1, :unsettled => 0, :settled => 100),
             Wherever::Dataset.new(:fund_id => 2, :trade_id => 12, :version => 2, :unsettled => 0, :settled => 10)] 
      end
    end

    context 'the identifier dataset' do
      let(:datasets) { mock(:datasets, :find_or_create_by => record) }
      let(:store) { mock(:store, :datasets => datasets) }
      it 'updates the record' do
        wherever.add({:settled => 110, :unsettled => 0}, options_second)

        Wherever.get_key_store(:identifier).datasets.should ==
            [Wherever::Dataset.new(:fund_id => 2, :trade_id => 12, :version => 2, :unsettled => 0, :settled => 110)]
      end
    end

    context 'the key datasets' do
      context 'with a single key' do
        it 'inserts a record' do
          wherever.add({:settled => 110, :unsettled => 0}, options_second)
          Wherever.get_key_store(:fund).datasets.should ==
              [Wherever::Dataset.new(:unsettled => 0, :settled => 110, :fund_id => 2)] 
          Wherever.get_key_store(:fund).identifiers.should ==
              [Wherever::Identifier.new(:trade_id => 12, :version => 2)] 
        end
      end
    end
  end
end
