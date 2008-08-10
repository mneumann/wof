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
  def load_state(state)
    @value = state.get_integer('value', 0)
    super
  end

  def dump_state(state)
    state.set('value', @value) if @value != 0
    super
  end

  def inc!() @value += 1 end
  def dec!() @value -= 1 end

  def render(r)
    r.anchor.action(:dec!).with("--")
    r.text " #{ @value } "
    r.anchor.action(:inc!).with("++")
  end
end

if __FILE__ == $0
  require 'pp'

  root = Root.new
  pp root

  state = State.new
  state.substate('1').with {|s|
    s.set('value', "2")
    s.actions({'inc!' => []})
  }

  root.load_state(state)
  pp root

  root.invoke_actions(state)
  pp root

  new_state = root.dump_state(State.new)
  pp new_state

  renderer = Renderer.new(new_state)
  renderer.render(root)
  puts renderer.to_s
end
