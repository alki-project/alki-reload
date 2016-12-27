require 'delegate'

module Alki
  module Reload
    class ReloadableDelegator < Delegator
      def initialize(instance,ref)
        @instance = instance
        @ref = ref
      end

      def __getobj__
        if !@obj || @instance_version != @instance.__version__
          @ref.executor = @instance.assembly_executor
          @obj = @ref.call
          @instance_version = @instance.__version__
        end
        @obj
      end

      def method_missing(method,*args,&blk)
        ref_meth = :"__reference_#{method}__"
        if respond_to?(ref_meth,true)
          ReloadableDelegator.new @instance, super(ref_meth, *args, &blk)
        else
          super
        end
      end
    end
  end
end
