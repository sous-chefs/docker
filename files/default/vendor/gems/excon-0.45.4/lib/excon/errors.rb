module Excon
  module Errors

    class Error < StandardError; end
    class StubNotFound < StandardError; end
    class InvalidStub < StandardError; end

    class SocketError < Error
      attr_reader :socket_error

      def initialize(socket_error=Excon::Error.new)
        if socket_error.message =~ /certificate verify failed/
          super("Unable to verify certificate, please set `Excon.defaults[:ssl_ca_path] = path_to_certs`, `ENV['SSL_CERT_DIR'] = path_to_certs`, `Excon.defaults[:ssl_ca_file] = path_to_file`, `ENV['SSL_CERT_FILE'] = path_to_file`, `Excon.defaults[:ssl_verify_callback] = callback` (see OpenSSL::SSL::SSLContext#verify_callback), or `Excon.defaults[:ssl_verify_peer] = false` (less secure).")
        else
          super("#{socket_error.message} (#{socket_error.class})")
        end
        set_backtrace(socket_error.backtrace)
        @socket_error = socket_error
      end
    end

    class Timeout < Error; end

    class ResponseParseError < Error; end

    class ProxyParseError < Error; end

    class ProxyConnectionError < Error; end

    class HTTPStatusError < Error
      attr_reader :request, :response

      def initialize(msg, request = nil, response = nil)
        super(msg)
        @request = request
        @response = response
      end
    end

    # HTTP Error classes
    class Informational < HTTPStatusError; end
    class Success < HTTPStatusError; end
    class Redirection < HTTPStatusError; end
    class ClientError < HTTPStatusError; end
    class ServerError < HTTPStatusError; end

    class Continue < Informational; end                       # 100
    class SwitchingProtocols < Informational; end             # 101
    class OK < Success; end                                   # 200
    class Created < Success; end                              # 201
    class Accepted < Success; end                             # 202
    class NonAuthoritativeInformation < Success; end          # 203
    class NoContent < Success; end                            # 204
    class ResetContent < Success; end                         # 205
    class PartialContent < Success; end                       # 206
    class MultipleChoices < Redirection; end                  # 300
    class MovedPermanently < Redirection; end                 # 301
    class Found < Redirection; end                            # 302
    class SeeOther < Redirection; end                         # 303
    class NotModified < Redirection; end                      # 304
    class UseProxy < Redirection; end                         # 305
    class TemporaryRedirect < Redirection; end                # 307
    class BadRequest < ClientError; end                       # 400
    class Unauthorized < ClientError; end                     # 401
    class PaymentRequired < ClientError; end                  # 402
    class Forbidden < ClientError; end                        # 403
    class NotFound < ClientError; end                         # 404
    class MethodNotAllowed < ClientError; end                 # 405
    class NotAcceptable < ClientError; end                    # 406
    class ProxyAuthenticationRequired < ClientError; end      # 407
    class RequestTimeout < ClientError; end                   # 408
    class Conflict < ClientError; end                         # 409
    class Gone < ClientError; end                             # 410
    class LengthRequired < ClientError; end                   # 411
    class PreconditionFailed < ClientError; end               # 412
    class RequestEntityTooLarge < ClientError; end            # 413
    class RequestURITooLong < ClientError; end                # 414
    class UnsupportedMediaType < ClientError; end             # 415
    class RequestedRangeNotSatisfiable < ClientError; end     # 416
    class ExpectationFailed < ClientError; end                # 417
    class UnprocessableEntity < ClientError; end              # 422
    class TooManyRequests < ClientError; end                  # 429
    class InternalServerError < ServerError; end              # 500
    class NotImplemented < ServerError; end                   # 501
    class BadGateway < ServerError; end                       # 502
    class ServiceUnavailable < ServerError; end               # 503
    class GatewayTimeout < ServerError; end                   # 504

    # Messages for nicer exceptions, from rfc2616
    def self.status_error(request, response)
      @errors ||= {
        100 => [Excon::Errors::Continue, 'Continue'],
        101 => [Excon::Errors::SwitchingProtocols, 'Switching Protocols'],
        200 => [Excon::Errors::OK, 'OK'],
        201 => [Excon::Errors::Created, 'Created'],
        202 => [Excon::Errors::Accepted, 'Accepted'],
        203 => [Excon::Errors::NonAuthoritativeInformation, 'Non-Authoritative Information'],
        204 => [Excon::Errors::NoContent, 'No Content'],
        205 => [Excon::Errors::ResetContent, 'Reset Content'],
        206 => [Excon::Errors::PartialContent, 'Partial Content'],
        300 => [Excon::Errors::MultipleChoices, 'Multiple Choices'],
        301 => [Excon::Errors::MovedPermanently, 'Moved Permanently'],
        302 => [Excon::Errors::Found, 'Found'],
        303 => [Excon::Errors::SeeOther, 'See Other'],
        304 => [Excon::Errors::NotModified, 'Not Modified'],
        305 => [Excon::Errors::UseProxy, 'Use Proxy'],
        307 => [Excon::Errors::TemporaryRedirect, 'Temporary Redirect'],
        400 => [Excon::Errors::BadRequest, 'Bad Request'],
        401 => [Excon::Errors::Unauthorized, 'Unauthorized'],
        402 => [Excon::Errors::PaymentRequired, 'Payment Required'],
        403 => [Excon::Errors::Forbidden, 'Forbidden'],
        404 => [Excon::Errors::NotFound, 'Not Found'],
        405 => [Excon::Errors::MethodNotAllowed, 'Method Not Allowed'],
        406 => [Excon::Errors::NotAcceptable, 'Not Acceptable'],
        407 => [Excon::Errors::ProxyAuthenticationRequired, 'Proxy Authentication Required'],
        408 => [Excon::Errors::RequestTimeout, 'Request Timeout'],
        409 => [Excon::Errors::Conflict, 'Conflict'],
        410 => [Excon::Errors::Gone, 'Gone'],
        411 => [Excon::Errors::LengthRequired, 'Length Required'],
        412 => [Excon::Errors::PreconditionFailed, 'Precondition Failed'],
        413 => [Excon::Errors::RequestEntityTooLarge, 'Request Entity Too Large'],
        414 => [Excon::Errors::RequestURITooLong, 'Request-URI Too Long'],
        415 => [Excon::Errors::UnsupportedMediaType, 'Unsupported Media Type'],
        416 => [Excon::Errors::RequestedRangeNotSatisfiable, 'Request Range Not Satisfiable'],
        417 => [Excon::Errors::ExpectationFailed, 'Expectation Failed'],
        422 => [Excon::Errors::UnprocessableEntity, 'Unprocessable Entity'],
        429 => [Excon::Errors::TooManyRequests, 'Too Many Requests'],
        500 => [Excon::Errors::InternalServerError, 'InternalServerError'],
        501 => [Excon::Errors::NotImplemented, 'Not Implemented'],
        502 => [Excon::Errors::BadGateway, 'Bad Gateway'],
        503 => [Excon::Errors::ServiceUnavailable, 'Service Unavailable'],
        504 => [Excon::Errors::GatewayTimeout, 'Gateway Timeout']
      }

      error_class, error_message = @errors[response[:status]] || [Excon::Errors::HTTPStatusError, 'Unknown']

      message = StringIO.new
      message.puts("Expected(#{request[:expects].inspect}) <=> Actual(#{response[:status]} #{error_message})")

      if request[:debug_request]
        message.puts('excon.error.request')
        Excon::PrettyPrinter.pp(message, request)
      end

      if request[:debug_response]
        message.puts('excon.error.response')
        Excon::PrettyPrinter.pp(message, response.data)
      end

      message.rewind
      error_class.new(message.read, request, response)
    end

  end
end
