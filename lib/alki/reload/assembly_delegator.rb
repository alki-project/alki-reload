require 'delegate'

module Alki
  module Reload
    class AssemblyDelegator < Delegator
      def initialize(obj,reloader)
        @obj = obj
        @reloader = reloader
      end

      def __reload__
        if @obj.respond_to? :__reload__
          return false unless @obj.__reload__
        end

        @reloader.reload
      end

      def __getobj__
        @obj
      end
    end
  end
end
