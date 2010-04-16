require "loofah"

class McBean
  VERSION = "0.2.0"
  REQUIRED_LOOFAH_VERSION = "0.4.7"

  attr_writer :__html__

  private_class_method :new, :allocate

  def McBean.fragment(string_or_io)
    mcbean = new
    mcbean.__html__ = Loofah.fragment(string_or_io)
    mcbean
  end

  def McBean.document(string_or_io)
    mcbean = new
    mcbean.__html__ = Loofah.document(string_or_io)
    mcbean
  end

  def to_html
    __html__.dup.scrub!(:escape).to_html
  end

  def __html__ # :nodoc:
    @__html__ ||= nil
    unless @__html__
      # TODO markdown should not be hardcoded here. class variable modified by markdown.rb?
      if __markdown__(false)
        @__html__ = Loofah.document(__markdown__.to_html)
      elsif __textile__(false)
        @__html__ = Loofah.document(__textile__.to_html)
      else
        raise RuntimeError
      end
    end
    @__html__
  end
end
Mcbean = McBean

require "mcbean/markdown"
require "mcbean/textile"

if Loofah::VERSION < McBean::REQUIRED_LOOFAH_VERSION
  raise RuntimeError, "McBean requires Loofah #{McBean::REQUIRED_LOOFAH_VERSION} or later (currently #{Loofah::VERSION})"
end
