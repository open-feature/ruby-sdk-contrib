require "net/http"

class HttpUnix < Net::HTTP
  BufferedIO = ::Net::BufferedIO
  UNIX_REGEXP = %r{^unix://}i

  def initialize(address, port = nil)
    super(address, port)
    @socket_type = "unix"
    @socket_path = address.sub(UNIX_REGEXP, "")

    @host = "localhost"
    @port = 1031
  end

  def connect
    s = UNIXSocket.open(@socket_path)
    @socket = BufferedIO.new(s,
      read_timeout: @read_timeout,
      continue_timeout: @continue_timeout,
      debug_output: @debug_output)
    on_connect
  end

  def post(url, body, headers)
    request = Net::HTTP::Post.new(url, headers)
    request["host"] = "localhost" # required to form correct HTTP request
    request.body = body.to_json
    request(request)
  end
end
