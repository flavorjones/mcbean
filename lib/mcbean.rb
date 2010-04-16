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
    # TODO markdown should not be hardcoded here. class variable modified by markdown.rb?
    return html.scrub!(:prune).to_html  if html
    return markdown.to_html             if markdown
  end
end
Mcbean = McBean

require "mcbean/markdown"

if Loofah::VERSION < McBean::REQUIRED_LOOFAH_VERSION
  raise RuntimeError, "McBean requires Loofah #{McBean::REQUIRED_LOOFAH_VERSION} or later (currently #{Loofah::VERSION})"
end
