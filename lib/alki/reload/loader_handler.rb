require 'alki/loader'

module Alki
  module Reload
    class LoaderHandler
      def initialize(root_dir)
        @root_dir = File.join(root_dir,'')
      end

      def handle_path(path)
        dirs.each do |dir|
          dir = File.join(dir,'')
          if path.start_with? dir
            name = Alki::Loader.lookup_name path
            return name if name
          end
        end
        nil
      end

      def dirs
        Alki::Loader.registered_paths.select do |d|
          d.start_with?(@root_dir)
        end
      end
    end
  end
end
