module Wof

  #
  # Base class of all Renderer classes.
  #
  class Renderer
    attr_reader :state
    attr_reader :current_component

    def initialize(state, current_component=nil, &block)
      @state, @current_component = state, current_component
      if block
        begin
          block.call(self)
        ensure
          close
        end
      end
    end

    #
    # Subclass responsibility.
    #
    def close
    end
  end

end
