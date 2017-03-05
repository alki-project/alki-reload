require 'delegate'

module Alki
  module Reload
    class AssemblyDelegator < Delegator
      def initialize(obj,watcher,reloader)
        @obj = obj
        @loaded = false
        @watcher = watcher
        @reloader = reloader
      end

      def __unload__
        @reloader.reload
      end

      def __getobj__
        unless @loaded
          @loaded = true
          @watcher.start
        end
        @obj
      end
    end
  end
end
