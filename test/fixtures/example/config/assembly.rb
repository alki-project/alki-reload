Alki do
  load :settings
  mount :reloader, 'alki/reload', enable: true

  tag :main_loop
  service :main do
    val = settings.val
    -> {
      val
    }
  end
end
