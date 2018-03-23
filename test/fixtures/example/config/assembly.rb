Alki do
  load :settings
  mount :reloader, 'alki/reload', enable: true

  tag :main_loop
  service :main do
    settings.val
  end

  service :not_main do
    settings.val
  end

  tag :main_loop
  service :interface do
    assembly
  end

  #ADD
end
