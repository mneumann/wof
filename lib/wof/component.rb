class Component
  attr_accessor :component_name, :parent_component

  def self.state(name=nil, hash=nil)
    @state ||= {}
    if name
      hash ||= {}
      hash[:name] ||= name.to_s  
      hash[:external] ||= name.to_s 

      attr_accessor hash[:name]

      setter = "#{name}="
      getter = "#{name}"

      case hash[:type]
      when :integer
        hash[:default] = 0 if not hash.has_key?(:default)
        hash[:load_state] ||= proc {|obj, st|
          obj.send(setter, st.get_integer(hash[:external], hash[:default]))
        }
      else
        hash[:load_state] ||= proc {|obj, st|
          obj.send(setter, st.get(hash[:external], hash[:default]))
        }
      end
      hash[:dump_state] ||= proc {|obj, st|
        val = obj.send(getter)
        st.set(hash[:external], val) if val != hash[:default]
      }

      @state.update(hash[:name] => hash)
    end
    @state
  end

  #
  # Load the state of the component and that of all subcomponents
  # from +state+.
  #
  def load_state(state)
    self.class.state.each_value {|hash| hash[:load_state].call(self, state) }
    each_child {|c| c.load_state(state.substate(c.component_name)) }
  end

  #
  # Dump the state of the component and all subcomponents into
  # +state+.
  #
  def dump_state(state)
    self.class.state.each_value {|hash| hash[:dump_state].call(self, state) }
    each_child {|c| c.dump_state(state.substate(c.component_name))}
    state
  end 

  def invoke_actions(state)
    if actions = state.actions
      actions.each_pair {|name, args|
        send(name, *args) if name[-1,1] == "!" and respond_to?(name)
      }
    end
    each_child {|c| c.invoke_actions(state.substate(c.component_name)) }
  end

  def component_path
    unless @component_path
      @component_path = []
      @component_path.push(*@parent_component.component_path) if @parent_component
      @component_path.push(@component_name) if @component_name
    end
    @component_path
  end

  def component_url
    "/" + component_path.join("/")
  end

  def render(r)
    each_child {|c| r.render(c)}
  end

  protected

  #
  # If +name+ == nil, then a name is generated automatically.
  # If +name+ == false, then no name is generated.
  #
  def add_child(child, name=nil)
    @children ||= []
    child.component_name = (name || @children.size).to_s if name != false
    child.parent_component = self
    @children << child
    return child
  end

  def each_child(&block)
    @children.each(&block) if @children
  end
end
