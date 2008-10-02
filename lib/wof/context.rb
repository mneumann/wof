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

  def [](id, attr_id)
    @state["#{id}.#{attr_id}"]
  end

  def []=(id, attr_id, value)
    @state["#{id}.#{attr_id}"] = value
  end

  def url_state
    arr = []
    @state.each_pair do |cid, val|
      arr << "#{cid}=#{val}"
    end
    arr.join("&")
  end

end # class Wof::Context
