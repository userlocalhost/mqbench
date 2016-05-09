require 'optparse'

module MQBench
  class Options
    MANDATORY_OPTS = [:mode, :size, :count]

    attr_reader :conf

    def initialize(argv)
      @opt = OptionParser.new
      @conf = {}
      
      @opt.on("-m m", "--mode m",  "[mandatory] broker type {amqp|stomp|kafka}")   {|v| @conf[:mode] = v}
      @opt.on("-s s", "--size s",  "[mandatory] message size (bytes)")             {|v| @conf[:size] = v.to_i}
      @opt.on("-c c", "--count c", "[mandatory] message counts")                   {|v| @conf[:count] = v.to_i}
      @opt.on("-u u", "--user p",  "specify user-id to login broker")              {|v| @conf[:user] = v}
      @opt.on("-w w", "--pass w",  "specify password to login broker")             {|v| @conf[:pass] = v}
      @opt.on("-h h", "--host h",  "specify host where broker is running")         {|v| @conf[:host] = v}
      @opt.on("-p p", "--port p",  "specify TCP port-number which broker listens") {|v| @conf[:port] = v.to_i}
    
      begin
        @opt.parse!(argv)
      rescue OptionParser::MissingArgument => e
        puts @opt.help
        exit 1
      end
    end

    def is_valid?
      not MANDATORY_OPTS.map {|x| @conf.key? x}.include?(false)
    end

    def show_usage
      puts @opt.help
    end
  end
end
