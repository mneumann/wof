module Wof; end

#
# Contains information about the request
# as well as the response.
#
class Wof::Context
  attr_reader :output, :state

  def initialize
    @output = [] 
    @state = {}
  end

  def <<(output)
    @output << output
  end

  def [](id, attr_id=nil)
    if attr_id
      @state["#{id}.#{attr_id}"]
    else
      @state[id]
    end
  end

  def []=(id, attr_id, value)
    if attr_id 
      @state["#{id}.#{attr_id}"] = value
    else
      @state[id] = value
    end
  end

  def url_state
    arr = []
    @state.each_pair do |cid, val|
      arr << "#{cid}=#{val}"
    end
    return nil if arr.empty?
    arr.join("&")
  end

  def action_url(id, action_id)
    str = "#{id}.#{action_id}"
    if u = url_state()
      str << "?"
      str << u
    end
    str
  end

end # class Wof::Context
