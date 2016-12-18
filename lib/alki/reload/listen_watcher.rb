require 'listen'
require 'weakref'

module Alki
  module Reload
    class ListenWatcher
      @listeners = {}

      def initialize(reloader,dirs)
        @reloader = reloader
        @dirs = dirs
      end

      def start!
        start_thread unless @thread
      end

      def stop!
        if @thread && @thread != Thread.current
          @queue.clear
          @queue << :done
          @thread.join
        end
      end

      private

      def self.listener(dir,queue)
        dir = File.join(dir,'')
        unless @listeners[dir]
          qs = []
          @listeners[dir] = [qs,Listen.to(dir) do
            qs.delete_if do |q|
              begin
                q << :reload
                false
              rescue WeakRef::RefError
                true
              end
            end
          end.tap{|l| l.start }]
        end
        @listeners[dir][0] << WeakRef.new(queue)
      end

      def start_thread
        @queue = Queue.new
        @thread = Thread.new do
          @dirs.each{|dir| self.class.listener(dir,@queue) }
          done = false
          until done
            begin
              cmd = @queue.pop
              if cmd == :done
                done = true
              elsif cmd == :reload
                if @reloader.reload
                  done = true
                end
              end
            rescue => e
              $stderr.puts e
              $stderr.puts e.backtrace.join("\n")
            end
          end
          @queue.clear
          @queue = nil
          @thread = nil
        end
      end
    end
  end
end
