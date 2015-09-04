# This class represents a Docker Event.
class Docker::Event
  include Docker::Error

  attr_accessor :status, :id, :from, :time

  def initialize(status, id, from, time)
    @status, @id, @from, @time = status, id, from, time
  end

  def to_s
    "Docker::Event { :status => #{self.status}, :id => #{self.id}, "\
      ":from => #{self.from}, :time => #{self.time} }"
  end

  class << self
    include Docker::Error

    def stream(opts = {}, conn = Docker.connection, &block)
      conn.get('/events', opts, :response_block => lambda { |b, r, t|
        block.call(new_event(b, r, t))
      })
    end

    def since(since, opts = {}, conn = Docker.connection, &block)
      stream(opts.merge(:since => since), conn, &block)
    end

    def new_event(body, remaining, total)
      return if body.nil? || body.empty?
      json = Docker::Util.parse_json(body)
      Docker::Event.new(
        json['status'],
        json['id'],
        json['from'],
        json['time']
      )
    end
  end
end
