module Wof; end

#
# The root class of all components.
#
class Wof::Component

  attr_accessor :id

  def initialize(id=nil)
    @id = id
  end

  def /(name)
    "#{@id || raise}/#{name}"
  end

  #
  # Load the state of the component and of all subcomponents.
  #
  def load(context)
    each {|child| child.load(context) }
  end

  #
  # Dump the state of the component and of all subcomponents. 
  #
  def dump(context)
    each {|child| child.dump(context) }
  end

  def invoke(context)
    each {|child| child.invoke(context) }
  end

  def render(context)
    each {|child| child.render(context)}
  end

  # --------------------------------------------------------
  
  def add(child)
    (@children ||= []) << child
  end

  alias << add

  include Enumerable

  def each(&block)
    @children.each(&block) if @children
  end

  # --------------------------------------------------------
  # Testing
  # --------------------------------------------------------

  def self.test
    #
    root = new()
    expect(root.id).nil?
    expect(root.to_a).empty?

    root.id = 'root'
    expect(root.id) == 'root' 

    #
    button1 = root.add new(root / 'but1')
    expect(button1.id) == [root.id, 'but1'].join('/')
    expect(root.to_a) == [button1]

    #
    button2 = root.add new(root / 'but2')
    expect(button2.id) == [root.id, 'but2'].join('/')
    expect(root.to_a) == [button1, button2]
  end

end # class Wof::Component
