module Wof

  require 'cgi'

  #
  # A class to ease generation of HTML documents. Example:
  #
  #   w = Wof::HtmlWriter.new(doc='')
  #   w.start_tag('html')
  #   w.start_tag('body')
  #   w.start_tag('a', 'href' => 'http://...')
  #   w.text('link')
  #   w.end_tag('a')
  #   w.end_tag('body')
  #   w.end_tag('html')
  #
  #   p doc
  #   # => '<html><body><a href="http://...">link</a></body></html>'
  #
  class HtmlWriter
    def initialize(out)
      @out = out 
    end

    def start_tag(tag, attributes=nil)
      stag(tag, attributes, false)
    end

    def single_tag(tag, attributes=nil)
      stag(tag, attributes, true)
    end

    def end_tag(tag)
      @out << "</#{ tag }>"
      self
    end

    def text(str)
      @out << str.to_s
      self
    end

    alias << text

    #
    # Emits +str+ as escaped HTML.
    #
    def encode_text(str)
      @out << CGI.escape_html(str.to_s)
      self
    end

    protected

    def stag(tag, attributes, single)
      @out << "<#{ tag }"
      if attributes
        attributes.each {|key, value| 
          if value != nil
            @out << %[ #{ key }="#{ value }"] 
          else
            @out << %[ #{ key }] 
          end
        }
      end
      @out << (single ? " />"  : ">")
      return self
    end

  end # class HtmlWriter

end # module Wof
