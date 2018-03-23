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

  def proj_path(*elems)
    File.join(@proj_dir,*elems)
  end

  def set_val(val,timeout=true)
    update_assembly timeout do
      path = proj_path 'config', 'settings.rb'
      File.write path, File.read(path).sub(/<<.*?>>/,"<<#{val}>>")
    end
  end

  def add_new_service
    add_to_assembly <<-END
      service :new_service do
        require 'example/new_service_class'
        Example::NewServiceClass.new
      end
    END
  end

  def write_service_class(val=1)
    write_service_class_file <<-END
      module Example
        class NewServiceClass
          def val
            #{val.inspect}
          end
        end
      end
    END
  end

  def write_service_class_file(str)
    add_file 'lib/example/new_service_class.rb', str
  end

  def write_empty_service_class
    write_service_class_file <<-END
      module Example
        class NewServiceClass
        end
      end
    END
  end

  def write_broken_service_class
    write_service_class_file <<-END
      module Example
        class NewServiceClass
      end
    END
  end

  def delete_service_class
    delete_file 'lib/example/new_service_class.rb'
  end

  def reset_assembly(timeout=true)
    update_assembly timeout do
      path = proj_path 'config', 'assembly.rb'
      file = File.read(path).sub(/#ADD.*/m,"#ADD\nend\n")
      File.write path, file
    end
  end

  def add_to_assembly(str,timeout=true)
    update_assembly timeout do
      path = proj_path 'config', 'assembly.rb'
      File.write path, File.read(path).sub(/#ADD/,"#ADD\n#{str}")
    end
  end

  def add_file(path,str,timeout=true)
    update_assembly timeout do
      full_path = proj_path(path)
      dir = File.dirname(full_path)
      unless Dir.exist? dir
        FileUtils.mkdir_p dir
      end
      File.write full_path, str
    end
  end

  def delete_file(path,timeout=true)
    update_assembly timeout do
      File.delete proj_path(path)
    end
  end

  def update_assembly(timeout=true)
    version = @instance.__version__
    yield
    count = 0
    until @instance.__reloading__ || version < @instance.__version__ || count == 5
      sleep 0.1
      count += 1
    end
    raise "Instance not reloading" if count == 5 && timeout
  end
end

Minitest::Spec.register_spec_type AlkiReloadExampleSpec do |desc|
  desc.is_a? String
end
