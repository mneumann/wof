$LOAD_PATH.unshift "../lib"

require 'wof/component'
require 'wof/state'
require 'wof/renderer'

class Page < Component
  def initialize
    super()
  end

  def render(r)
    r << "<html><body>"
    super
    r << "</body></html>"
  end
end

class Root < Page
  def on_setup
    10.times {|i| Counter.new(self, i.to_s) }
  end
end

class Counter < Component
  def on_load(state)
    @value = state.get_integer(@id, 'value', 0) 
    super
  end

  def on_dump(state)
    state.set(@id, 'value', @value) if @value != 0
    super
  end

  def on_action(state)
    inc() if state.get(@id, 'inc', :no_action) != :no_action
    dec() if state.get(@id, 'dec', :no_action) != :no_action
  end

  def inc() @value += 1 end
  def dec() @value -= 1 end

  def render(r)
    r.anchor.action(:dec).with("--")
    r.text " #{ @value } "
    r.anchor.action(:inc).with("++")
    r.text "<br/>"
  end
end


  def component_attr(state, path, value)
    component_path, action_path = path.split(".", 2)
    if action_path
      state[component_path] ||= {}
      state[component_path][action_path] = value
    end
    return component_path, action_path
  end 

  require 'webrick'

  s = WEBrick::HTTPServer.new(:Port => 2000, :Logger => WEBrick::Log.new('/dev/null'),
                             :AccessLog => WEBrick::Log.new('/dev/null'))
  s.mount_proc("/") {|req, res|

    state = State.new

    _, action = component_attr(state, req.path_info, nil)
    req.query.each {|k,v| component_attr(state, k, v) }

    root = Root.new
    root.on_load(state)
    root.on_action(state)

    state.clear
    root.on_dump(state)

    if action
      redirect_url = "/"
      redirect_url << "?"
      redirect_url << state.url_encode
      res.status = 303
      res['location'] = redirect_url
    else
      renderer = Renderer.new(state)
      renderer.render(root)

      res.status = 200
      res.body = renderer.to_s
      res['Content-Type'] = "text/html"
    end
  }
  trap('INT') { s.shutdown }
  s.start
