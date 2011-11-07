module MethodLogging
  class << self
    def add(klass)
      klass::LogMethods.each do |method|;
        unless klass.instance_methods.include?("#{method}_without_logging")
          add_method(klass, method)
        end
      end
    end

    def add_method(klass, method)
      klass.send :alias_method, :"#{method}_without_logging", method
      klass.class_eval <<-END
        def #{method}_with_logging(*args)
          MethodLogging.log("Called #{Time.now}: #{method}(\#{MethodLogging.strify(*args)})")
          #{method}_without_logging(*args)
        end
      END
      klass.send :alias_method, method, :"#{method}_with_logging"
    end
    
    def log(string)
      path = Class.constants.include?('RAILS_ROOT') ? RAILS_ROOT : File.expand_path(File.dirname(__FILE__) + '/..')
      FileUtils.mkdir_p("#{path}/log") if File.exists?("#{path}/log")
      File.open("#{path}/log/method.log", 'a') do |f|
        f.puts string
      end
    end
    
    def strify(*args)
      args.map do |arg|
        case arg.class.to_s
        when "String"
          %Q{"#{arg}"}
        when "Fixnum", "Integer", "Float"
          arg.to_s
        when "Hash"
          string = arg.map do |k, v|
            "#{strify(k)} => #{strify(v)}"
          end.join(', ')
          "{#{string}}"
        when "Array"
          string = arg.map do |v|
            string(v)
          end.join(', ')
          "[#{string}]"
        else
          "(#{arg.class} - #{arg})"
        end
      end.join(', ')
    end
  end
end