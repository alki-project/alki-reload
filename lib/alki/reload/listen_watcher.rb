require 'listen'
require 'concurrent'

module Alki
  module Reload
    class ListenWatcher
      @listeners = {}

      def self.listener(dirs,reloader)
        @listeners[dirs] ||= Listener.new(dirs,reloader)
      end

      def initialize(reloader,dirs)
        @listener = self.class.listener dirs, reloader
        @started = false
      end

      def start
        unless @started
          @listener.start
          @started = true
        end
      end

      def stop
        if @started
          @listener.stop
          @started = false
        end
      end

      class Listener
        def initialize(dirs,reloader)
          @count = 0
          @listen = Listen.to(*dirs) do |modified, _added, _removed|
            if @count > 0 && modified
              reloader.reload
            end
          end
        end

        def start
          if @count == 0
            @listen.start
          end
          @count += 1
        end

        def stop
          @count -= 1
        end
      end
    end
  end
end
