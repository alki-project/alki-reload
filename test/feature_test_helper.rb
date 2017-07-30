require 'fileutils'

class AlkiReloadExampleSpec < Minitest::Spec
  before do
    @dir = Dir.mktmpdir('alki-reload-test')
    @proj_dir = File.join(@dir,'example')
    FileUtils.copy_entry fixture_path('example'), @proj_dir
    $LOAD_PATH.unshift File.join(@proj_dir,'lib')
    require 'example'
    @instance = Example.new
  end

  after do
    undef_const :Example
    $LOADED_FEATURES.delete_if do |path|
      path.start_with? @dir
    end
    $LOAD_PATH.delete_if do |path|
      path.start_with? @dir
    end
    FileUtils.rmtree @dir
  end

  def undef_const(const)
    if Object.const_defined? const
      Object.send :remove_const, const
    end
  end

  def set_val(val)
    version = @instance.__version__
    path = File.join @proj_dir, 'config', 'settings.rb'
    File.write path, File.read(path).sub(/<<.*?>>/,"<<#{val}>>")

    count = 0
    until @instance.__version__ > version
      sleep 0.1
      count += 1
      count.must_be :<, 5
    end
  end
end

Minitest::Spec.register_spec_type AlkiReloadExampleSpec do |desc|
  desc.is_a? String
end
