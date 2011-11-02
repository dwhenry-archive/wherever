class Wherever
  module Mark
    def mark(name)
      (['identifier'] + config.key_groups).each do |key|
        keys = Array(key)
        current_db = get_key_store(*keys)
        new_db = get_key_store(*(keys + [{'marker' => name}]))
        current_db.datasets.all.each do |record|
          new_db.datasets.create!(record.attributes)
        end
        current_db.identifiers.all.each do |record|
          new_db.identifiers.create!(record.attributes)
        end
      end
      set_price_lookup('price', nil, [{'marker' => name}])
    end
  end
end