require 'eventmachine'

module EchoServer
  attr_accessor :name

  def initialize(a, b)
  end

  def post_init
    p "Client connecting"
  end

  def unbind
    p "client disconnecting. Supper #{self.name}"
  end

  def receive_data(data)
    p "receive data #{data} from client"
    send_data ">> Replay to client from data #{data}"
  end
end

class MyDef
  include EM::Deferrable

  def my_work(val)
    p "work with #{val}"
    val ? done : fail
  end

  def fail
    set_deferred_status :failed
  end

  def done
    set_deferred_status :succeded
  end
end

EM.run {
  EM.start_server('0.0.0.0', 3000, EchoServer, 'a', 'b') do |c|
    c.name = "macd0s"
  end

  df = MyDef.new
  df.callback { p "function 1 chay ngon"}
  df.errback { p "function 1 chay loi"}

  p "Server is running on port 3000"
  EM.add_timer(10) {
    p 'boom'
    EM.stop
  }

  EM.defer { p "I'm in a thread "}

  EM.defer {
    sleep(3)
    p "I'm in a thread sleep 3s"
  }
  EM.add_periodic_timer(1) { p "tick" }

  op = Proc.new {
    p "This is operator"
    [1, 2]
  }
  cb = Proc.new { |first, second| p "1: #{first}| 2: #{second}"}
  EM.defer(op, cb)

  EM.add_timer(2) do
    df.my_work(999999)
    df.my_work(false)
  end
}