require "mqbench/version"
require "mqbench/options"
require "mqbench/client"
require "mqbench/amqp"
require "mqbench/stomp"
require "mqbench/kafka"

module MQBench
  def self.run(args)
    obj = case args[:mode]
    when 'amqp'
      MQBench::AMQP.new(args)
    when 'stomp'
      MQBench::STOMP.new(args)
    when 'kafka'
      MQBench::Kafka.new(args)
    else
      puts "[warning] The specified mode '#{args[:mode]}' is invalid"
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
end
