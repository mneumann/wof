$LOAD_PATH.unshift "../lib"

require 'wof/component'
require 'wof/state'
require 'wof/renderer'

class Root < Component
  def initialize
    10.times { add_child Counter.new }
  end
end

class Counter < Component
  state :value, :type => :integer, :external => 'v'

  def inc!() @value += 1 end
  def dec!() @value -= 1 end

  def render(r)
    r.anchor.action(:dec!).with("--")
    r.text " #{ @value } "
    r.anchor.action(:inc!).with("++")
    r.text "<br/>"
  end
end

#if __FILE__ == $0
  require 'rubygems'
  require 'rack'

  class Handler
    def call(env)
      request = Rack::Request.new(env)

      root = Root.new
      state = State.new

      #
      # Extract state out of params
      #

      expanded = []
      request.params.each do |k,v|
        if k.start_with?("/")
          # absolute path
          expanded << [k, v] 
        else
          expanded << [request.path_info + "/." + k, v]
        end
      end

      expanded.each do |k,v|
        path, attribute = k.split(".", 2)
        paths = path.split("/")

        paths.shift if paths.first.empty?

        cur_state = state
        paths.each do |piece|
          cur_state = state.substate(piece)
        end
        if attribute.end_with?('!')
          cur_state.actions({attribute => []})  # TODO
        else
          cur_state.set(attribute, v)
        end
      end

      root.load_state(state)
      root.invoke_actions(state)
      next_state = root.dump_state(State.new)

      renderer = Renderer.new(next_state)
      renderer.render(root)

      [200, {'Content-type' => ['text/html']}, [renderer.to_s]]
    end
  end

  Rack::Handler::WEBrick.run(Handler.new, :Port => 8082)
#end
