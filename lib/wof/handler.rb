module Wof; end

#
# Implements a Rack compatible handler.
#
class Wof::Handler
  require 'rack'

  def initialize(page_class, mount_point='/')
    @page_class = page_class
    @mount_point = mount_point
  end

  def call(env)
    request = Rack::Request.new(env)
    context = Wof::Context.new

    if i=request.path_info.index(@mount_point)
      path = request.path_info[(i+@mount_point.size)..-1] || ''
    else
      raise
    end

    cid, action = path.split(".", 2)
    context[cid, 'action'] = action if action
    request.params.each {|k,v| context.state[k] = v }

    page = @page_class.new
    page.load(context)
    page.invoke(context)

    # use a new context for dumping
    context = Wof::Context.new

    page.dump(context)

    if action or request.post? 
      redirect_url = "/"
      if u = context.url_state
        redirect_url << "?"
        redirect_url << u
      end
      [303, {'Location' => redirect_url}, []]
    else
      page.render(context)
      [200, {'Content-type' => "text/html"}, context.output]
    end
  end
end # class Wof::Handler
