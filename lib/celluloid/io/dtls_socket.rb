require "socket"
require 'openssl'
require "resolv"

module Celluloid
  module IO
    # DTLSSocket is more like SSLSocket (over TCP) than UDPSocket.
    class DTLSSocket < Socket
      extend Forwardable

      def initialize(io, ctx = OpenSSL::SSL::DTLSContext.new)
        @context = ctx
        socket = OpenSSL::SSL::DTLSSocket.new(::IO.try_convert(io), @context)
        socket.sync_close = true if socket.respond_to?(:sync_close=)
        super(socket)
      end

      # Wait until the socket is readable
      def wait_readable; Celluloid::IO.wait_readable(self); end

      def accept
        newio = to_io.accept_nonblock
        return self.class.new(newio, @context)
      rescue ::IO::WaitReadable
        wait_readable
        retry
      rescue ::IO::WaitWritable
        wait_writable
        retry
      end

      def recvfrom
        to_io.sysread
      end

      def recvfrom_nonblock
        to_io.sysread
      rescue ::IO::WaitReadable
        wait_readable
        retry
      end

    end
  end
end
