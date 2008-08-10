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

    def self.test
      w = new(out="")
      expect(out).empty?

      w.start_tag(:html)
      w.start_tag("body")
      w.text("abc")
      expect(out) == "<html><body>abc"

      w = new(out="")
      w.start_tag('a', 'href' => 'http://')
      w.encode_text('<>&')
      w.end_tag('a')
      expect(out) == '<a href="http://">&lt;&gt;&amp;</a>'

      w = new(out="")
      w.single_tag('img', 'src' => 'abc')
      expect(out) == '<img src="abc" />'

      w = new(out="")
      w.single_tag('img', 'src' => 'abc', :alt => 'def')
      expect(out).in('<img src="abc" alt="def" />',
                     '<img alt="def" src="abc" />')
    end

  end # class HtmlWriter

end # module Wof
