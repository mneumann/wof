class State < Hash
  def actions(new_actions=nil)
    self[:actions] = new_actions if new_actions
    self[:actions]
  end

  def get(key, default=nil, &value_conversion)
    if props = self[nil] and props.has_key?(key)
      value = props[key]
      value_conversion ? value_conversion.call(value) : value
    else
      default
    end
  end

  def get_integer(key, default=0)
    get(key, default) {|value| Integer(value)}
  end

  def set(key, value)
    (self[nil] ||= {})[key] = value
  end

  #
  # Returns the substate for the component named
  # <tt>component_name</tt>. The substate is the current state (self) if
  # a component has no name.
  #
  def substate(component_name)
    if component_name
      self[component_name] ||= State.new
    else
      self
    end
  end

  def with
    yield self
  end

  def url_encode(path, arr)
    each_pair do |k, v|
      if k.nil? # properties
        v.each_pair do |prop_name, prop_value|
          arr << [path + "." + prop_name, prop_value].join("=")
        end
      else
        v.url_encode([path, k].join("/"), arr)
      end
    end
    arr
  end
end

if __FILE__ == $0
  s = State.new
  s[nil] = {'value' => '1'}

  p s.get('value')
  p s.get_integer('value2', nil)
end
