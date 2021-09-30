module BugsnagDynamic
  module Loggable
    extend ActiveSupport::Concern

    class_methods do
      def info(options = {})
        new.info(options)
      end

      def warn(options = {})
        new.warn(options)
      end

      def error(options = {})
        new.error(options)
      end
    end

    def log(level, **options)
      @message = options[:message]
      @exception = options[:exception]
      @context = options[:context]

      notify!
    end

    def notify!
      Bugsnag.notify(self) do |event|
        event.add_metadata(:context, metadata_context)
      end
    end

    def info(options = {})
      log(:info, options)
    end

    def warn(options = {})
      log(:warn, options)
    end

    def error(options = {})
      log(:error, options)
    end

    def metadata_context
      ctx = {}

      if @context.present?
        ctx[:context] =
          @context.each.with_object({}) { |(k,v), memo|
            val =
              if v.respond_to?(:attributes)
                v.attributes
              elsif v.respond_to?(:to_h)
                v.to_h
              else
                v
              end

            memo[k] = val
          }
      end

      ctx[:exception] = "#{e.to_s}\n\n#{e.backtrace&.join('\n')}" if @exception.present?

      ctx
    end
  end
end
