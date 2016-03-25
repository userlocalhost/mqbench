#!/usr/bin/env ruby

require 'bunny'
require 'stomp'
require 'optparse'

class Base
  QNAME = "benchmark9-#{(rand * 10000).to_i}"

  def initialize(size, count)
    @size = size
    @count = count
  end
end

class AMQP < Base
  def send_msg
    c = Bunny.new()
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
    c = Bunny.new()
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
  def send_msg
    conn = Stomp::Connection.open()
    
    (1..@count).each do |_x|
      conn.publish(QNAME, 'a' * @size)
    end
  end

  def recv_msg
    conn = Stomp::Connection.open()
    
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

def benchmark(mode, size, count)
  puts "size:#{size}, count:#{count}, mode:#{mode}"

  obj = case mode
  when 'amqp'
    AMQP.new(size, count)
  when 'stomp'
    STOMP.new(size, count)
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

msgsize = msgcount = mode = false
opt = OptionParser.new

opt.on("-m m", "--mode m", "specify benchmark mode ('amqp' or 'stomp')") {|v| mode = v }
opt.on("-s s", "--size s", "specify message size") {|v| msgsize = v.to_i }
opt.on("-c c", "--count c", "specify message counts") {|v| msgcount = v.to_i }

opt.parse!(ARGV)

unless msgsize and msgcount and mode
  puts opt.help
else
  benchmark(mode, msgsize, msgcount)
end
