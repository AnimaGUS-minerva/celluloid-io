require "socket"
require "resolv"

module Celluloid
  module IO
    # DTLSSocket is more like SSLSocket (over TCP) than UDPSocket.
    class DTLSSocket < SSLSocket
      extend Forwardable

      def initialize(io, ctx = OpenSSL::SSL::DTLSContext.new)
        @context = ctx
        socket = OpenSSL::SSL::DTLSSocket.new(::IO.try_convert(io), @context)
        socket.sync_close = true if socket.respond_to?(:sync_close=)
        super(socket)
      end

      def accept
        to_io.accept_nonblock
        self
      rescue ::IO::WaitReadable
        wait_readable
        retry
      rescue ::IO::WaitWritable
        wait_writable
        retry
      end

    end
  end
end
