require "loofah"

#
#  McBean can convert documents from one format to another.
#
#  See the README.rdoc for more details and examples.
#
class McBean
  # Current version of McBean
  VERSION = "0.3.0"

  # Minimum required version of Loofah
  REQUIRED_LOOFAH_VERSION = "0.4.7"

  attr_writer :__html__ # :nodoc:

  private_class_method :new, :allocate

  @@__formats__ = ["html"]

  ##
  #  Create a McBean from an HTML fragment string (or IO object)
  #
  #  Please see README.rdoc for more information on HTML fragments and documents.
  #
  def McBean.fragment(string_or_io)
    mcbean = new
    mcbean.__html__ = Loofah.fragment(string_or_io)
    mcbean
  end

  ##
  #  Create a McBean from an HTML document string (or IO object)
  #
  #  Please see README.rdoc for more information on HTML fragments and documents.
  #
  def McBean.document(string_or_io)
    mcbean = new
    mcbean.__html__ = Loofah.document(string_or_io)
    mcbean
  end

  ##
  #  Returns an array of formats that McBean supports.
  #
  def McBean.formats
    @@__formats__
  end

  ##
  #  Generate an HTML string representation of the McBeaned document.
  #
  #  So you can convert documents in other formats to HTML as follows:
  #
  #    McBean.markdown(File.read(path_to_markdown_file)).to_html
  #
  def to_html
    __html__.dup.scrub!(:escape).to_html
  end

  def __html__ # :nodoc:
    @__html__ ||= nil
    unless @__html__
      (McBean.formats - ["html"]).each do |format|
        obj = send("__#{format}__", false)
        if obj
          @__html__ = Loofah.document(obj.to_html)
          break
        end
      end
    end
    @__html__
  end
end
Mcbean = McBean

require "mcbean/markdown"
require "mcbean/textile"
require "mcbean/creole"

if Loofah::VERSION < McBean::REQUIRED_LOOFAH_VERSION
  raise RuntimeError, "McBean requires Loofah #{McBean::REQUIRED_LOOFAH_VERSION} or later (currently #{Loofah::VERSION})"
end
