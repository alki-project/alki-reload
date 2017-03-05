Alki do
  load :settings
  mount :reloader, 'alki/reload', enable: true

  tag :main_loop
  service :main do
    val = settings.val
    -> input, output {
      while input.pop
        output.push val
      end
    }
  end

  service :not_main do
    val = settings.val
    -> input, output {
      while input.pop
        output.push val
      end
    }
  end
end
