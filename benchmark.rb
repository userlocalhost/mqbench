#!/usr/bin/env ruby

require 'bunny'
require 'stomp'
require 'kafka'
require 'optparse'

class Base
  QNAME = "benchmark9-#{(rand * 10000).to_i}"

  def initialize(args = {})
    @size = args[:size] if args.key? :size
    @host = args[:host] if args.key? :host
    @port = args[:port] if args.key? :port
    @user = args[:user] if args.key? :user
    @pass = args[:pass] if args.key? :pass
    @count = args[:count] if args.key? :count
  end
end

class BM_AMQP < Base
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

class BM_STOMP < Base
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

class BM_Kafka < Base
  def initialize(args)
    @port = 9092

    super(args)

    @broker = Kafka.new(seed_brokers: ["#{@host}:#{@port}"])
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
    consumer = @broker.consumer(group_id: "test")

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

def benchmark(args)
  obj = case args[:mode]
  when 'amqp'
    BM_AMQP.new(args)
  when 'stomp'
    BM_STOMP.new(args)
  when 'kafka'
    BM_Kafka.new(args)
  else
    nil
  end

  if obj != nil
    time_started = Time.now

    obj.send_msg

    time_enqueued = Time.now

    obj.recv_msg

    time_dequeued = Time.now

    puts "results: #{time_dequeued - time_started} (enqueue:#{time_enqueued - time_started}, dequeue:#{time_dequeued - time_enqueued})"
  end
end

opt = OptionParser.new
args = {}

opt.on("-m m", "--mode m", "specify benchmark mode ('amqp' or 'stomp')") {|v| args[:mode] = v}
opt.on("-s s", "--size s", "specify message size")                       {|v| args[:size] = v.to_i}
opt.on("-c c", "--count c", "specify message counts")                    {|v| args[:count] = v.to_i}
opt.on("-u u", "--user p", "specify user-id to login broker")            {|v| args[:user] = v}
opt.on("-w w", "--pass w", "specify password to login broker")           {|v| args[:pass] = v}
opt.on("-h h", "--host h", "specify host of server")                     {|v| args[:host] = v}
opt.on("-p p", "--port p", "specify TCP port-number which is listened")  {|v| args[:port] = v.to_i}

opt.parse!(ARGV)

unless args.key?(:mode) and args.key?(:size) and args.key?(:count)
  puts opt.help
else
  benchmark(args)
end
