require 'alki/feature_test'
require 'fileutils'
require 'erb'

describe 'Main loop' do
  before do
    @dir = File.join(Dir.mktmpdir,'')
    @proj_dir = File.join(@dir,'example')
    FileUtils.copy_entry fixture_path('example'), @proj_dir
    $LOAD_PATH.unshift File.join(@proj_dir,'lib')
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
    path = File.join @proj_dir, 'config', 'settings.rb'
    File.write path, File.read(path).sub(/<<.*?>>/,"<<#{val}>>")
  end

  it 'should make dependencies of main_loop services reloadable' do
    set_val 'one'
    require 'example'
    instance = Example.new
    main = instance.main
    main.call.must_equal "<<one>>"
    until instance.__version__ > 1
      set_val 'two'
      sleep 1
    end
    main.call.must_equal "<<two>>"
  end
end
