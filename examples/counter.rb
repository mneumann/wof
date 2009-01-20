require 'rubygems'

$LOAD_PATH.unshift "../lib"
require 'wof/component'
require 'wof/context'
require 'wof/handler'

class Page < Wof::Component
  def render(context)
    context << "<html><body>"
    super
    context << "</body></html>"
  end
end

class Main < Page
  def initialize
    10.times {|i| add Counter.new(i.to_s) }
  end
end

class Counter < Wof::Component
  def load(context)
    @value = Integer(context[@id, nil] || 0)
    @open = (context[@id, 'open'] == '1')
    super
  end

  def dump(context)
    context[@id, nil] = @value.to_s if @value and @value != 0 
    context[@id, 'open'] = '1' if @open
    super
  end

  def invoke(context)
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

  def render(context)
    context << %{<a href="#{context.action_url(@id, 'dec')}">--</a>}
    context << " "
    if @open
      context << %{
        <form method="POST">
          <input type="hidden" name="#{@id}.action" value="toggle" />
          <input type="text" name="#{@id}" value="#{@value}" />
          <input type="submit" name="Close" value="close" />
        </form>
      }
    else
      context << %{<a href="#{context.action_url(@id, 'toggle')}">#{ @value }</a>}
    end
    context << " "
    context << %{<a href="#{context.action_url(@id, 'inc')}">++</a>}
    context << "<br/>"
  end
end
