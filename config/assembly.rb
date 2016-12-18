Alki do
  func :reload do
    root.assembly_instance.__reload__
  end

  set :watch, false

  set :dirs do
    ['lib']
  end

  set :whitelist do
    []
  end

  set :watch_dirs do
    handlers.inject([]) do |dirs,h|
      dirs.push *h.dirs
    end
  end

  service :handlers do
    [dsl_handler,load_path_handler]
  end

  service :dsl_handler do
    require 'alki/reload/dsl_handler'
    Alki::Reload::DslHandler.new root_dir
  end

  service :load_path_handler do
    require 'alki/reload/load_path_handler'
    Alki::Reload::LoadPathHandler.new root_dir, dirs
  end

  factory :on_reload do
    -> obj, method {
      reloader.hooks << obj.method(method)
      obj
    }
  end

  service :reloader do
    require 'alki/reload/reloader'
    Alki::Reload::Reloader.new unloader
  end

  service :unloader do
    require 'alki/reload/unloader'
    Alki::Reload::Unloader.new handlers, whitelist
  end

  service :watcher do
    require 'alki/reload/listen_watcher'
    Alki::Reload::ListenWatcher.new assembly, watch_dirs
  end

  overlay :watcher, :on_reload, :stop!

  overlay 'root.assembly_instance', :assembly_delegator

  factory :assembly_delegator do
    require 'alki/reload/assembly_delegator'
    if watch
      self.watcher.start!
    end
    -> obj {
      Alki::Reload::AssemblyDelegator.new obj, reloader
    }
  end

  set :root_dir do
    File.expand_path('..',parent.config_dir)
  end
end
