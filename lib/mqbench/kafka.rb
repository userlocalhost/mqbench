require 'kafka'

module MQBench
  class Kafka < Client
    def initialize(args)
      @port = 9092
      @host = 'localhost'
  
      super(args)
  
      @broker = ::Kafka.new(seed_brokers: ["#{@host}:#{@port}"])
    end
  
    def send_msg
      producer = @broker.producer(:required_acks => 0,
                                  :max_buffer_size => (@count * @size),
                                  :max_buffer_bytesize => (@count * (@size + 100)))

      (1..@count).each do |x|
        producer.produce('a' * @size, topic: QNAME)
        producer.deliver_messages
      end

      producer.shutdown
    end
  
    def recv_msg
      consumer = @broker.consumer(group_id: 'test')
  
      # It's possible to subscribe to multiple topics by calling `subscribe`
      # repeatedly.
      consumer.subscribe(QNAME)
  
      # This will loop indefinitely, yielding each message in turn.
      current = 1
      consumer.each_message do |message|
        current += 1
        if(current >= @count)
          break
        end
      end
    end
  end
end
