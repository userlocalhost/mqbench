module MQBench
  class Client
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
end
