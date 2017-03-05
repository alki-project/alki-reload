Alki do
  func :reload do
    root.assembly_instance.__reload__
  end

  set :enable, false

  set :main_loops do
    enable
  end

  set :watch do
    enable
  end

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

  reference_overlay '%main_loop', :reloadable_reference

  factory :reloadable_reference do
    require 'alki/reload/reloadable_delegator'
    -> (ref) {
      if main_loops
        Alki::Reload::ReloadableDelegator.new(root.assembly_instance,ref)
      else
        ref.call
      end
    }
  end

  service :handlers do
    [loader_handler,load_path_handler]
  end

  service :loader_handler do
    require 'alki/reload/loader_handler'
    Alki::Reload::LoaderHandler.new root_dir
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
    if watch
      require 'alki/reload/listen_watcher'
      Alki::Reload::ListenWatcher.new assembly, watch_dirs
    else
      require 'alki/reload/null_watcher'
      Alki::Reload::NullWatcher.new
    end
  end

  overlay :watcher, :on_reload, :stop

  overlay 'root.assembly_instance', :assembly_delegator

  factory :assembly_delegator do
    require 'alki/reload/assembly_delegator'
    -> obj {
      Alki::Reload::AssemblyDelegator.new obj, watcher, reloader
    }
  end

  set :root_dir do
    File.expand_path('..',parent.config_dir)
  end
end
