module Callback
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    EXCLUDE_LIST = %w{__ initialize}

    def before_action actions
      define_method :__before_actions do
        actions
      end

      @before_actions = actions
    end

    def after_action actions
      define_method :__after_actions do
        actions
      end

      @after_actions = actions
    end

    %w{attr_accessor attr_reader attr_writer}.each do |meth|
      define_method(meth) do |names|
        exclude { super(names) }
      end
    end

    def exclude
      @latch = true
      yield
      @latch = false
    end

    def excluded?(name)
      @latch ||
        EXCLUDE_LIST.any? { |n| name.to_s.match(n) } ||
        name.to_s.match(@before_actions.to_s)
    end

    def method_added(name)
      return if excluded?(name)
      alias_method "__#{name}", name
      remove_method name
    end
  end

  module InstanceMethods
    def method_missing(method, *args, &block)
      method = method.to_s
      raise NoMethodError if method.match __before_actions.to_s
      send_to = method =~ /^__/ ? method : "__#{method}"
      raise NoMethodError unless respond_to?(send_to)
      return unless send(__before_actions)
      send(send_to)
    end
  end
end

__END__
  subject do
    Class.new {

    }
  end
