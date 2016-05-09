require 'stomp'

module MQBench
  class STOMP < Client
    def initialize(args)
      @port = 61613
      @user = 'guest'
      @pass = 'guest'
  
      super(args)
  
      @broker = Stomp::Connection.open(@user, @pass, @host, @port)
    end
  
    def send_msg
      (1..@count).each do |x|
        @broker.publish(QNAME, 'a' * @size)
      end
    end
  
    def recv_msg
      @broker.subscribe(QNAME, {:ack => 'client'})
      cnt = 0
      loop do
        @broker.receive
      
        cnt += 1
        if cnt >= @count
          break
        end
      end
    end
  end
end
