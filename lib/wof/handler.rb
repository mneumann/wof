module Wof; end

#
# Implements a Rack compatible handler.
#
class Wof::Handler
  require 'rack'

  def initialize(page_class)
    @page_class = page_class
  end

  def call(env)
    request = Rack::Request.new(env)
    context = Wof::Context.new

    cid, action = request.path_info.split(".", 2)
    context[cid, 'action'] = action if action
    request.params.each {|k,v| context.state[k] = v }

    page = @page_class.new
    page.on_load(context)
    page.on_action(context)

    # use a new context for dumping
    context = Wof::Context.new

    page.on_dump(context)

    if action or request.post? 
      redirect_url = "/"
      redirect_url << "?"
      redirect_url << context.url_state
      [303, {'Location' => redirect_url}, []]
    else
      page.on_render(context)
      [200, {'Content-type' => "text/html"}, context.output]
    end
  end
end # class Wof::Handler
