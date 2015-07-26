module Excon

  VERSION = '0.45.4'

  CR_NL = "\r\n"

  DEFAULT_CA_FILE = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "data", "cacert.pem"))

  DEFAULT_CHUNK_SIZE = 1048576 # 1 megabyte

  # avoid overwrite if somebody has redefined
  unless const_defined?(:CHUNK_SIZE)
    CHUNK_SIZE = DEFAULT_CHUNK_SIZE
  end

  DEFAULT_RETRY_LIMIT = 4

  FORCE_ENC = CR_NL.respond_to?(:force_encoding)

  HTTP_1_1 = " HTTP/1.1\r\n"

  HTTP_VERBS = %w{connect delete get head options patch post put trace}

  HTTPS = 'https'

  NO_ENTITY = [204, 205, 304].freeze

  REDACTED = 'REDACTED'

  UNIX = 'unix'

  USER_AGENT = 'excon/' << VERSION

  VERSIONS = USER_AGENT + ' (' << RUBY_PLATFORM << ') ruby/' << RUBY_VERSION

  VALID_REQUEST_KEYS = [
    :body,
    :captures,
    :chunk_size,
    :debug_request,
    :debug_response,
    :expects,
    :headers,
    :idempotent,
    :instrumentor,
    :instrumentor_name,
    :method,
    :middlewares,
    :mock,
    :path,
    :persistent,
    :pipeline,
    :query,
    :read_timeout,
    :request_block,
    :response_block,
    :retries_remaining, # used internally
    :retry_limit,
    :versions,
    :write_timeout
  ]

  VALID_CONNECTION_KEYS = VALID_REQUEST_KEYS + [
    :ciphers,
    :client_key,
    :client_key_pass,
    :client_cert,
    :certificate,
    :certificate_path,
    :disable_proxy,
    :private_key,
    :private_key_path,
    :connect_timeout,
    :family,
    :host,
    :hostname,
    :omit_default_port,
    :nonblock,
    :reuseaddr,
    :password,
    :port,
    :proxy,
    :scheme,
    :socket,
    :ssl_ca_file,
    :ssl_ca_path,
    :ssl_cert_store,
    :ssl_verify_callback,
    :ssl_verify_peer,
    :ssl_verify_peer_host,
    :ssl_version,
    :tcp_nodelay,
    :thread_safe_sockets,
    :uri_parser,
    :user
  ]

  unless ::IO.const_defined?(:WaitReadable)
    class ::IO
      module WaitReadable; end
    end
  end

  unless ::IO.const_defined?(:WaitWritable)
    class ::IO
      module WaitWritable; end
    end
  end
  # these come last as they rely on the above
  DEFAULTS = {
    :chunk_size           => CHUNK_SIZE || DEFAULT_CHUNK_SIZE,
    :ciphers              => 'HIGH:!SSLv2:!aNULL:!eNULL:!3DES',
    :connect_timeout      => 60,
    :debug_request        => false,
    :debug_response       => false,
    :headers              => {
      'User-Agent' => USER_AGENT
    },
    :idempotent           => false,
    :instrumentor_name    => 'excon',
    :middlewares          => [
      Excon::Middleware::ResponseParser,
      Excon::Middleware::Expects,
      Excon::Middleware::Idempotent,
      Excon::Middleware::Instrumentor,
      Excon::Middleware::Mock
    ],
    :mock                 => false,
    :nonblock             => true,
    :omit_default_port    => false,
    :persistent           => false,
    :read_timeout         => 60,
    :retry_limit          => DEFAULT_RETRY_LIMIT,
    :ssl_verify_peer      => true,
    :tcp_nodelay          => false,
    :thread_safe_sockets  => true,
    :uri_parser           => URI,
    :versions             => VERSIONS,
    :write_timeout        => 60
  }

end
