# class represents a Docker Volume
class Docker::Volume
  include Docker::Base

  # /volumes/volume_name doesnt return anything
  def remove(opts = {}, conn = Docker.connection)
    conn.delete("/volumes/#{id}")
  end

  def normalize_hash(hash)
    hash['id'] ||= hash['Name']
  end

  class << self

    # get details for a single volume
    def get(name, conn = Docker.connection)
      resp = conn.get("/volumes/#{name}")
      hash = Docker::Util.parse_json(resp) || {}
      new(conn, hash)
    end

    # /volumes endpoint returns an array of hashes incapsulated in an Volumes tag
    def all(opts = {}, conn = Docker.connection)
      resp = conn.get('/volumes')
      hashes = Docker::Util.parse_json(resp) || []
      if hashes.has_key?("Volumes")
         hashes =  hashes['Volumes']
      end
      hashes.map { |hash| new(conn, hash) }
    end

    # creates a volume with an arbitrary name
    def create(name, conn = Docker.connection)
      query = {}
      query['name'] = name if name
      resp = conn.post('/volumes/create', query, :body => query.to_json)
      hash = Docker::Util.parse_json(resp) || {}
      new(conn, hash)
    end
  end
end
