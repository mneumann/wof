require 'rubygems'

$LOAD_PATH.unshift "../lib"
require 'wof/component'
require 'wof/context'
require 'wof/handler'

class Page < Wof::Component
  def on_render(context)
    context << "<html><body>"
    super
    context << "</body></html>"
  end
end

class Main < Page
  def on_construct
    10.times {|i| Counter.new(self, i.to_s) }
  end
end

class Counter < Wof::Component
  def on_load(context)
    @value = Integer(context[@id, 'value'] || 0)
    @open = (context[@id, 'open'] == '1')
    super
  end

  def on_dump(context)
    context[@id, 'value'] = @value.to_s if @value and @value != 0
    context[@id, 'open'] = '1' if @open
    super
  end

  def on_action(context)
    case context[@id, 'action']
    when 'inc'
      @value += 1
    when 'dec'
      @value -= 1
    when 'toggle'
      @open = !@open
    end
    super
  end

  def on_render(context)
    context << %{<a href="#{@id}.dec?#{context.url_state}">--</a>}
    context << " "
    if @open
      context << %{
        <form method="POST">
          <input type="hidden" name="#{@id}.action" value="toggle" />
          <input type="text" name="#{@id}.value" value="#{@value}" />
          <input type="submit" name="Close" value="close" />
        </form>
      }
    else
      context << %{<a href="#{@id}.toggle?#{context.url_state}">#{ @value }</a>}
    end
    context << " "
    context << %{<a href="#{@id}.inc?#{context.url_state}">++</a>}
    context << "<br/>"
  end
end
