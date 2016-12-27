require 'alki/support'

module Alki
  module Reload
    class Unloader
      def initialize(handlers,whitelist=[])
        @handlers = handlers
        @whitelist = whitelist
      end

      def find_unloadable
        files = []
        consts = []
        $LOADED_FEATURES.each do |path|
          if path.end_with?('.rb')
            result = @handlers.lazy.map{|h| h.handle_path path }.find{|r| r != nil}
            if result
              if add_const consts, result
                files << path
              end
            end
          end
        end
        unless files.empty?
          {files: files, consts: consts}
        end
      end

      def unload(files:, consts:)
        $LOADED_FEATURES.delete_if {|f| files.include? f}
        consts.each {|(parent,const)| parent.send :remove_const, const}
      end

      private

      def add_const(consts,name)
        unless @whitelist.include? name
          md = name.match(%r{(.*)/(.*)})
          if md
            parent = Alki::Support.constantize Alki::Support.classify md[1]
            name = md[2]
          else
            parent = Object
          end
          name = Alki::Support.classify(name).to_sym
          if parent && parent.is_a?(Module) && parent.const_defined?(name,false)
            consts << [parent,name]
            true
          end
        end
      end
    end
  end
end
