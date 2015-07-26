module Excon
  module Middleware
    class Instrumentor < Excon::Middleware::Base
      def error_call(datum)
        if datum.has_key?(:instrumentor)
          datum[:instrumentor].instrument("#{datum[:instrumentor_name]}.error", :error => datum[:error])
        end
        @stack.error_call(datum)
      end

      def request_call(datum)
        if datum.has_key?(:instrumentor)
          if datum[:retries_remaining] < datum[:retry_limit]
            event_name = "#{datum[:instrumentor_name]}.retry"
          else
            event_name = "#{datum[:instrumentor_name]}.request"
          end
          datum[:instrumentor].instrument(event_name, datum) do
            @stack.request_call(datum)
          end
        else
          @stack.request_call(datum)
        end
      end

      def response_call(datum)
        if datum.has_key?(:instrumentor)
          datum[:instrumentor].instrument("#{datum[:instrumentor_name]}.response", datum[:response])
        end
        @stack.response_call(datum)
      end
    end
  end
end
