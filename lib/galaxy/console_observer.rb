require 'socket'
require 'json'
require 'ostruct'

module Galaxy
  class ConsoleObserver

    def initialize(observer_host = nil, logger = nil)
      @observer_host = observer_host
      @host, @port = @observer_host.split(':') unless @observer_host.nil?
      @logger = logger
      
      @logger.info("console_observer started with #{@observer_host}")

      @socket = UDPSocket.new
    end

    def changed(key, value = nil)
      @logger.info("console_observer changed info: #{key.to_s}")
      
      unless @observer_host.nil?
        if value.nil?
          value = OpenStruct.new
          value.timestamp = Time.now.to_s
        end

        @logger.info("console_observer trying to send")
        @socket.send(
          { key => to_hash(value) }.to_json,
          0,
          @host,
          @port
        )
        @logger.info("console_observer change sent")
      end
    end

    def to_hash(obj)
      hash = {}
      hash = obj.marshal_dump if obj.respond_to?("marshal_dump")
      hash = obj if obj.class.to_s == "Hash"

      sinfo = hash[:slot_info] || {}
      sinfo = sinfo.marshal_dump if sinfo.respond_to?("marshal_dump")
      hash[:slot_info] = slot_info
      hash
    end
  end
end
