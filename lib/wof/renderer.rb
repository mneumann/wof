require 'wof/brushes'

class Renderer
  attr_reader :current_component

  def initialize(state)
    @buffer = []
    @state = state
    @current_component = nil 
  end

  def anchor
    AnchorBrush.new(self)
  end

  def text(str)
    @buffer << str
  end

  def render(component)
    old = @current_component
    @current_component = component
    begin
      component.render(self)
    ensure
      @current_component = old
    end
    nil
  end

  def <<(str)
    @buffer << str
  end

  def to_s
    @buffer.join
  end

  #
  # TODO: compress using the current_component as current path
  #
  def encode_state(action=nil)
    pieces = @state.url_encode("", [])
    pieces.unshift(action) if action
    pieces.join("&")
  end
end
