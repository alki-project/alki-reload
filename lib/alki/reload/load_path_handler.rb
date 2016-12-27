module Alki
  module Reload
    class LoadPathHandler
      def initialize(root_dir,dirs)
        @dirs = dirs.map{|d| File.join(root_dir,d,'')}.select{|d| Dir.exist? d }
      end

      attr_reader :dirs

      def handle_path(path)
        @dirs.each do |dir|
          if path.start_with? dir
            return path[dir.size..-1].chomp('.rb')
          end
        end
        nil
      end
    end
  end
end
