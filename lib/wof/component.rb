module ComponentStateMixin
  STATES_LOCAL = Hash.new
  STATES = Hash.new
  STATES_COMMITTED = false

  def inherited(subclass)
    STATES_LOCAL[subclass] ||= {}
  end

  def self.included(klass)
    STATES_LOCAL[klass] ||= {}
    case klass
    when Class
    when Module
      def klass.included(klass) ComponentStateMixin.included(klass) end
      klass.extend(ComponentStateMixin)
    end
  end

  def state(name=nil, hash={}) 
    if name
      STATES_LOCAL[self] ||= {}
      hash[:name] ||= name.to_s  
      hash[:ivar] ||= "@#{name}" 
      hash[:external] ||= name.to_s 
      case hash[:type]
      when :integer
        hash[:default] = 0 if not hash.has_key?(:default)
        hash[:get_state] ||= proc {|st| st.get_integer(hash[:external], hash[:default]) }
      else
        hash[:get_state] ||= proc {|st| st.get(hash[:external], hash[:default]) }
      end
      hash[:set_state] ||= proc {|st, val| st.set(hash[:external], val) if val != hash[:default] }

      STATES_LOCAL[self].update(hash[:name] => hash)
    elsif STATES_COMMITTED == false
      commit_states!
    end
    return STATES[self]
  end

  def commit_states!
    #
    # Update all states
    #
    # This doesn't need to be run if name=nil, hash.empty? and
    # !STATE[self].empty?
    #
    STATES_LOCAL.each_key do |klass|
      h = {}
      klass.ancestors.reverse.each {|k| h.update(STATES_LOCAL[k] || {}) }
      STATES[klass] = h
    end
  end
end

class Component
  class << self; include ComponentStateMixin end

  attr_accessor :component_name, :parent_component

  #
  # Load the state of the component and that of all subcomponents
  # from +state+.
  #
  def load_state(state)
    self.class.state.each_value {|hash|
      instance_variable_set(hash[:ivar], hash[:get_state].call(state))
    }
    each_child {|c| c.load_state(state.substate(c.component_name)) }
  end

  #
  # Dump the state of the component and all subcomponents into
  # +state+.
  #
  def dump_state(state)
    self.class.state.each_value {|hash|
      hash[:set_state].call(state, instance_variable_get(hash[:ivar]))
    }
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
