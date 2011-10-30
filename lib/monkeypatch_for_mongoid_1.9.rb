module Mongoid
  module Associations
    class EmbedsMany
      def find_or_create_by(attr)
        where(attr).first || create(attr)
      end
    end
  end
end

module Mongoid #:nodoc:
  module Attributes
    module InstanceMethods
      def [](field)
        send(field)
      end

      def []=(field, value)
        modify(field, send(field), value)
      end
    end
  end
end