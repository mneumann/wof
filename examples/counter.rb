$LOAD_PATH.unshift "../lib"

class String
  def start_with?(str)
    self.size >= str.size and self[0, str.size] == str
  end

  def end_with?(str)
    self.size >= str.size and self[self.size-str.size, str.size] == str
  end
end

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
    @state = state.get(@id, 'state', 'closed')
    super
  end

  def on_dump(state)
    state.set(@id, 'value', @value) if @value != 0
    state.set(@id, 'state', 'open') if @state == 'open'
    super
  end

  def on_action(state)
    %w(inc dec open submit).each {|action|
      send(action) if state.get(@id, action, :no) != :no
    }
  end

  def inc() @value += 1 end
  def dec() @value -= 1 end
  def open()
    @state = if @state == 'closed' then 'open' else 'closed' end
  end

  def submit
    open
  end

  def render(r)
    r.anchor.action(:dec).with("--")
    r.text " "
    if @state == 'open'
      r << %{
        <form method="POST">
          <input type="hidden" name="#{@id}.submit" value="ok" />
          <input type="text" name="#{@id}.value" value="#{@value}" />
          <input type="submit" name="Close" value="close" />
        </form>
      }
    else
      r.anchor.action(:open).with(@value.to_s)
    end
    r.text " "
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

require 'rubygems'
require 'rack'
require 'pp'

class Handler

  def call(env)
    request = Rack::Request.new(env)

    state = State.new

    _, action = component_attr(state, request.path_info, nil)
    request.params.each {|k,v| component_attr(state, k, v) }

    root = Root.new
    root.on_load(state)
    root.on_action(state)

    state.clear
    root.on_dump(state)

    if action or request.post? 
      redirect_url = "/"
      redirect_url << "?"
      redirect_url << state.url_encode
      [303, {'Location' => redirect_url}, []]
    else
      renderer = Renderer.new(state)
      renderer.render(root)

      [200, {'Content-type' => "text/html"}, [renderer.to_s]]
    end
  end
end

Rack::Handler::WEBrick.run(Handler.new, :Port => 8082)
