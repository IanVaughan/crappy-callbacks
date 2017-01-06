module Callback
  EXCLUDE_LIST = %w{__ initialize}

  def self.included(base)
    base.send :include, InstanceMethods

    base.class_eval do
      @@__before_actions = []

      def self.__before_actions
        @@__before_actions
      end

      def self.before_action *actions
        raise if actions.count > 2

        __before_actions = actions
        @before_actions = actions
      end

      %w{attr_accessor attr_reader attr_writer}.each do |meth|
        define_method("self.#{meth}") do |names|
          exclude { super(names) }
        end
      end

      def self.exclude
        @latch = true
        yield
        @latch = false
      end

      def self.excluded?(name)
        @latch ||
          in_exclude_list?(name) ||
          in_action_list?(name)
      end

      def self.in_exclude_list?(name)
        EXCLUDE_LIST.any? { |n| name.to_s.match(n) }
      end

      def self.in_action_list?(name)
        #@before_actions.any? { |ba| name.to_s.match(ba.to_s) }
        name.to_s.match(@before_actions.first.to_s)
      end

      def self.method_added(name)
        return if excluded?(name)
        alias_method "__#{name}", name
        remove_method name
      end
    end
  end

  module InstanceMethods
    def method_missing(method, *args, &block)
      method = method.to_s #method.id2name
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
        #return true if !opts.fetch(:only, '').to_s.match(method_name)
      end
      return false unless res = send(__before_actions.first)
      res
    end
  end
end

