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
    @renderer << @renderer.current_component.component_url
    @renderer << "?#{@renderer.encode_state(@action)}"
    @renderer << %{">#{inner}</a>}
    nil
  end
end
