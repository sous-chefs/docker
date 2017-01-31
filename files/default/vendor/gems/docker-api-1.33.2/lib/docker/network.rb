# This class represents a Docker Network.
class Docker::Network
  include Docker::Base

  def connect(container, opts = {}, body_opts = {})
    Docker::Util.parse_json(
      connection.post(path_for('connect'), opts,
                      body: { container: container }.merge(body_opts).to_json)
    )
    reload
  end

  def disconnect(container, opts = {})
    Docker::Util.parse_json(
      connection.post(path_for('disconnect'), opts,
                      body: { container: container }.to_json)
    )
    reload
  end

  def remove(opts = {})
    connection.delete(path_for, opts)
    nil
  end
  alias_method :delete, :remove

  def json(opts = {})
    Docker::Util.parse_json(connection.get(path_for, opts))
  end

  def to_s
    "Docker::Network { :id => #{id}, :info => #{info.inspect}, "\
      ":connection => #{connection} }"
  end

  def reload
    network_json = @connection.get("/networks/#{URI.encode(@id)}")
    hash = Docker::Util.parse_json(network_json) || {}
    @info = hash
  end

  class << self
    def create(name, opts = {}, conn = Docker.connection)
      default_opts = {
        'Name' => name,
        'CheckDuplicate' => true
      }
      resp = conn.post('/networks/create', {},
                       body: default_opts.merge(opts).to_json)
      response_hash = Docker::Util.parse_json(resp) || {}
      get(response_hash['Id'], {}, conn) || {}
    end

    def get(id, opts = {}, conn = Docker.connection)
      network_json = conn.get("/networks/#{URI.encode(id)}", opts)
      hash = Docker::Util.parse_json(network_json) || {}
      new(conn, hash)
    end

    def all(opts = {}, conn = Docker.connection)
      hashes = Docker::Util.parse_json(conn.get('/networks', opts)) || []
      hashes.map { |hash| new(conn, hash) }
    end

    def remove(id, opts = {}, conn = Docker.connection)
      conn.delete("/networks/#{URI.encode(id)}", opts)
      nil
    end
    alias_method :delete, :remove
  end

  # Convenience method to return the path for a particular resource.
  def path_for(resource = nil)
    ["/networks/#{id}", resource].compact.join('/')
  end

  private :path_for
end
