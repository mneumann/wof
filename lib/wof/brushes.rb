class Brush
  def initialize(renderer)
    @renderer = renderer
  end
end

class AnchorBrush < Brush
  def action(method)
    @action = method
    self
  end

  def with(inner)
    @renderer << %{<a href="}
    @renderer << @renderer.current_component.id
    @renderer << ".#{@action}" if @action
    state = @renderer.encode_state
    @renderer << "?#{state}" unless state.empty?
    @renderer << %{">#{inner}</a>}
    nil
  end
end
