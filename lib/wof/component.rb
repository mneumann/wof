module Wof; end

#
# The root class of all components.
#
class Wof::Component

  #
  # Used to separate two id-path components 
  #
  PATH_SEP = '/'.freeze

  attr_accessor :id

  def initialize(parent=nil, id=nil, &block)
    @id = (parent ? [parent.id, id].join(PATH_SEP) : id).freeze
    block.call(self) if block
    on_construct
    parent.add(self) if parent
  end

  def on_construct
  end

  #
  # Load the state of the component and of all subcomponents.
  #
  def on_load(context)
    each {|child| child.on_load(context) }
  end

  #
  # Dump the state of the component and of all subcomponents. 
  #
  def on_dump(context)
    each {|child| child.on_dump(context) }
  end

  def on_action(context)
    each {|child| child.on_action(context) }
  end

  def on_render(context)
    each {|child| child.on_render(context)}
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
    button1 = new(root, 'but1')
    expect(button1.id) == [root.id, 'but1'].join('/')
    expect(root.to_a) == [button1]

    #
    button2 = new(root, 'but2')
    expect(button2.id) == [root.id, 'but2'].join('/')
    expect(root.to_a) == [button1, button2]
  end

end # class Wof::Component
