module BugsnagDynamic
  class Error
    class << self
      def const_missing(dyhnamic_name)
        klass = Class.new(BugsnagDynamic)
        klass.send(:include, BugsnagDynamic::Loggable)
        Object.const_set(dynamic_name, klass)
      end
    end
  end
end
