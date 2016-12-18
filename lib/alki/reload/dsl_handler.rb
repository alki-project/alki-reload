require 'alki/dsl/registry'

module Alki
  module Reload
    class DslHandler
      def initialize(root_dir)
        @root_dir = File.join(root_dir,'')
      end

      def handle_path(path)
        dirs.each do |dir|
          dir = File.join(dir,'')
          if path.start_with? dir
            entry = Alki::Dsl::Registry.lookup(path)
            if entry && entry.data[:prefix] && entry.data[:name]
              return [entry.data[:prefix], entry.data[:name]]
            end
          end
        end
        nil
      end

      def dirs
        Alki::Dsl::Registry.registered_dirs.select do |d|
          d.start_with?(@root_dir)
        end
      end
    end
  end
end
