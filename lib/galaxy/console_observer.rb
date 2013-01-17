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
      if obj.respond_to?("marshal_dump")
        hash = obj.marshal_dump
        
        hash[:slot_info] = hash[:slot_info].marshal_dump if hash.has_key?(:slot_info) and hash[:slot_info].respond_to?("marshal_dump")
      end
      
      hash
    end
  end
end
