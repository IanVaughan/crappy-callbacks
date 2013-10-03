module Callback
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    EXCLUDE_LIST = %w{__ initialize}

    def before_action *actions
      raise if actions.count > 2

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
        name.to_s.match(@before_actions.first.to_s)
    end

    def method_added(name)
      return if excluded?(name)
      alias_method "__#{name}", name
      remove_method name
    end
  end

  module InstanceMethods
    def method_missing(method, *args, &block)
      #puts method.id2name
      method = method.to_s
      raise NoMethodError if method.match __before_actions.first.to_s
      send_to = method =~ /^__/ ? method : "__#{method}"
      raise NoMethodError unless respond_to?(send_to)
      return false unless __run_before_actions(method)
      send(send_to)
    end

    def __run_before_actions(method_name)
      if __before_actions.count == 2
        raise unless __before_actions.last.is_a? Hash
        opts = __before_actions.last
        return true if opts.fetch(:except, '').to_s.match(method_name)
      end
      return false unless res = send(__before_actions.first)
      res
    end
  end
end

