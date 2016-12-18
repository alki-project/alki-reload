module Alki
  module Reload
    class Reloader
      attr_reader :hooks

      def initialize(unloader)
        @unloader = unloader
        @hooks = []
      end

      def reload
        unloadable = @unloader.find_unloadable
        if unloadable
          hooks.each &:call
          @unloader.unload unloadable
          true
        else
          false
        end
      end
    end
  end
end
