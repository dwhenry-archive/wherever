class Wherever
  module Mark
    def mark(name)
      marker = collection(name)
      marker.price = collection.price
      collection.stores.all.each do |store|
        marker.stores.create(:key => store.key, :datasets => store.datasets.clone) unless store.key == ["unique"]
      end
    end
  end
end