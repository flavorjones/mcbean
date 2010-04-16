require "loofah"

class McBean
  VERSION = "0.2.0"
  REQUIRED_LOOFAH_VERSION = "0.4.7"

  attr_accessor :html

  private_class_method :new, :allocate

  def McBean.fragment(string_or_io)
    mcbean = allocate
    mcbean.html = Loofah.fragment(string_or_io)
    mcbean
  end

  def McBean.document(string_or_io)
    mcbean = allocate
    mcbean.html = Loofah.document(string_or_io)
    mcbean
  end

  def to_html
    return html.scrub!(:escape).to_html if html

    # TODO markdown should not be hardcoded here. class variable modified by markdown.rb?
    if markdown
      self.html = Loofah.document(markdown.to_html)
      return to_html
    end
  end
end
Mcbean = McBean

require "mcbean/markdown"

if Loofah::VERSION < McBean::REQUIRED_LOOFAH_VERSION
  raise RuntimeError, "McBean requires Loofah #{McBean::REQUIRED_LOOFAH_VERSION} or later (currently #{Loofah::VERSION})"
end
