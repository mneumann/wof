class State < Hash
  def get(cid, key, default=nil, &value_conversion)
    if props = self[cid] and props.has_key?(key)
      value = props[key]
      value_conversion ? value_conversion.call(value) : value
    else
      default
    end
  end

  def get_integer(cid, key, default=0)
    get(cid, key, default) {|value| Integer(value)}
  end

  def set(cid, key, value)
    self[cid] ||= {} 
    self[cid][key] = value
  end

  def with
    yield self
  end

  def url_encode
    arr = []
    each_pair do |cid, props|
      props.each_pair do |prop_name, prop_value|
        arr << "#{cid}.#{prop_name}=#{prop_value}"
      end
    end
    arr.join("&")
  end
end

if __FILE__ == $0
  s = State.new
  s.set('c1', 'value', '1')

  p s.get('c1', 'value')
  p s.get_integer('c1', 'value2', nil)
end
