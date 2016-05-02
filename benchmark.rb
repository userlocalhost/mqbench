#!/usr/bin/env ruby

require 'bunny'
require 'stomp'
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

class AMQP < Base
  def initialize(args)
    @port = 5672
    @user = 'guest'
    @pass = 'guest'

    super(args)
  end

  def send_msg
    c = Bunny.new(:host => @host, :port => @port, :user => @user, :pass => @pass)
    c.start
    
    ch = c.create_channel
    q = ch.queue(QNAME)
  
    (1..@count).each do |c|
      q.publish('a' * @size)
    end
  
    ch.close
    c.close
  end
  
  def recv_msg
    c = Bunny.new(:host => @host, :port => @port, :user => @user, :pass => @pass)
    c.start
    
    ch = c.create_channel
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
    c.close
  end
end

class STOMP < Base
  def initialize(args)
    @port = 61613
    @user = 'guest'
    @pass = 'guest'

    super(args)
  end

  def send_msg
    conn = Stomp::Connection.open(@user, @pass, @host, @port)
    
    (1..@count).each do |_x|
      conn.publish(QNAME, 'a' * @size)
    end
  end

  def recv_msg
    conn = Stomp::Connection.open(@user, @pass, @host, @port)
    
    conn.subscribe(QNAME, {:ack => 'client'})
    cnt = 0
    loop do
      conn.receive
    
      cnt += 1
      if cnt >= @count
        break
      end
    end
  end
end

def benchmark(args)
  obj = case args[:mode]
  when 'amqp'
    AMQP.new(args)
  when 'stomp'
    STOMP.new(args)
  else
    nil
  end

  if obj != nil
    time_started = Time.now

    obj.send_msg

    time_enqueued = Time.now

    obj.recv_msg

    time_dequeued = Time.now

    puts "time_enqueued : #{time_enqueued - time_started}"
    puts "time_dequeued : #{time_dequeued - time_enqueued}"
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
