class Component
  attr_reader :id

  PATH_SEP = '/'.freeze

  def initialize(parent=nil, id=nil)
    pid = parent ? parent.id : PATH_SEP
    @id =
      if id
        if id.start_with?(PATH_SEP) # absolute id
          id
        else # relative id
          if pid.end_with?(PATH_SEP)
            "#{pid}#{id}"
          else
            "#{pid}#{PATH_SEP}#{id}"
          end
        end
      else
        pid
      end

    parent.add_child(self) if parent
    on_setup
  end

  def on_setup
  end

  #
  # Load the state of the component and that of all subcomponents
  # from +state+.
  #
  def on_load(state)
    each_child {|c| c.on_load(state) }
  end

  #
  # Dump the state of the component and all subcomponents into
  # +state+.
  #
  def on_dump(state)
    each_child {|c| c.on_dump(state) }
  end

  def on_action(state)
    each_child {|c| c.on_action(state) }
  end

  def on_render(renderer)
    render(renderer)
  end

  def render(r)
    each_child {|c| r.render(c)}
  end

  def add_child(child)
    (@children ||= []) << child
  end

  def children
    @children ||= []
  end

  protected

  def each_child(&block)
    @children.each(&block) if @children
  end

  # --------------------------------------------------------
  # Testing
  # --------------------------------------------------------
  def self.test
    root = new()
    expect(root.id) == '/'

    # create children
    c1 = new(root, 'c1')
    c2 = new(root, 'c2')
    c3 = new(root, '/absolute')

    expect(root.children).not.empty?
    expect(root.children.size) == 3

    # ordering of chilren
    expect(root.children[0]) == c1
    expect(root.children[1]) == c2
    expect(root.children[2]) == c3

    # test component ids
    expect(c1.id) == '/c1'
    expect(c2.id) == '/c2'
    expect(c3.id) == '/absolute'
  end

end
