property :api_retries, Integer,
          default: 3,
          desired_state: false

property :read_timeout, Integer,
          default: 60,
          desired_state: false

property :write_timeout, Integer,
          desired_state: false

property :running_wait_time, Integer,
          default: 20,
          desired_state: false

property :tls, [TrueClass, FalseClass, nil],
          default: lazy { ENV['DOCKER_TLS'] },
          desired_state: false

property :tls_verify, [TrueClass, FalseClass, nil],
          default: lazy { ENV['DOCKER_TLS_VERIFY'] },
          desired_state: false

property :tls_ca_cert, [String, nil],
          default: lazy { ENV['DOCKER_CERT_PATH'] ? "#{ENV['DOCKER_CERT_PATH']}/ca.pem" : nil },
          desired_state: false

property :tls_server_cert, String,
          desired_state: false

property :tls_server_key, String,
          desired_state: false

property :tls_client_cert, [String, nil],
          default: lazy { ENV['DOCKER_CERT_PATH'] ? "#{ENV['DOCKER_CERT_PATH']}/cert.pem" : nil },
          desired_state: false

property :tls_client_key, [String, nil],
          default: lazy { ENV['DOCKER_CERT_PATH'] ? "#{ENV['DOCKER_CERT_PATH']}/key.pem" : nil },
          desired_state: false

alias_method :tlscacert, :tls_ca_cert
alias_method :tlscert, :tls_server_cert
alias_method :tlskey, :tls_server_key
alias_method :tlsverify, :tls_verify
