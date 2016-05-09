require 'bunny'

module MQBench
  class AMQP < Client
    def initialize(args)
      @port = 5672
      @user = 'guest'
      @pass = 'guest'
  
      super(args)
  
      @broker = Bunny.new(:host => @host, :port => @port, :user => @user, :pass => @pass)
      @broker.start
    end
  
    def send_msg
      ch = @broker.create_channel
      q = ch.queue(QNAME)
    
      (1..@count).each do |_|
        q.publish('a' * @size)
      end
    
      ch.close
    end
    
    def recv_msg
      ch = @broker.create_channel
      q = ch.queue(QNAME)
    
      cnt = 0
      q.subscribe(:block => true) do |delivery_info, _, _|
        cnt += 1
        if cnt >= @count
          delivery_info.consumer.cancel
          break
        end
      end
    
      ch.close
    end
  end
end
