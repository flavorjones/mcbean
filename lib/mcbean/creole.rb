require 'creole'

class McBean
  attr_writer :__creole__ # :nodoc:

  @@__formats__ << "creole"

  ##
  #  Create a McBean from a Creole document string (or IO object)
  #
  def McBean.creole string_or_io
    mcbean = new
    mcbean.__creole__ = McBean::Creolize::Antidote.new(string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io)
    mcbean
  end

  ##
  #  Generate a Creole string representation of the McBeaned document.
  #
  #  So you can convert documents in other formats to Creole as follows:
  #
  #    McBean.fragment(File.read(path_to_html_file)).to_creole
  #
  def to_creole
    __creole__.to_s
  end

  def __creole__ generate_from_html_if_necessary=true # :nodoc:
    @__creole__ ||= nil
    if @__creole__.nil? && generate_from_html_if_necessary
      @__creole__ = McBean::Creolize::Antidote.new(
                       Loofah::Helpers.remove_extraneous_whitespace(
                         __html__.dup.scrub!(:escape).scrub!(Creolize.new).text(:encode_special_chars => false)
                     ))
    end
    @__creole__
  end

  # :stopdoc:
  class Creolize < Loofah::Scrubber
    class Antidote
      attr_accessor :string
      def initialize string
        @string = string
      end

      def to_html
        # interesting (or not) that the Creole authors use 'creolize'
        # in the opposite sense that I do.
        Creole.creolize string, :extensions => false
      end

      def to_s
        string
      end
    end

    def initialize
      @direction = :bottom_up
      @link_references = nil
      @link_reference_count = 0
    end

    def scrub(node)
      return CONTINUE if node.text?
      replacement_killer = \
        case node.name
        when "h1"
          new_text node, "\n= #{node.content.gsub("\n"," ")} =\n"
        when "h2"
          new_text node, "\n== #{node.content.gsub("\n"," ")} ==\n"
        when "h3"
          new_text node, "\n=== #{node.content.gsub("\n"," ")} ===\n"
        when "h4"
          new_text node, "\n==== #{node.content.gsub("\n"," ")} ====\n"
        # when "blockquote"
        #   new_text node, "\nbq. #{node.content.gsub(/\n\n/, "\n").sub(/^\n/,'')}"
        when "li"
          nil # handled by parent list tag
        when "ul"
          fragment = []
          node.xpath("./li").each do |li|
            fragment << "* #{li.text}" if li.text =~ /\S/
          end
          new_text node, "\n#{fragment.join("\n")}\n"
        when "ol"
          fragment = []
          node.xpath("./li").each do |li|
            fragment << "# #{li.text}" if li.text =~ /\S/
          end
          new_text node, "\n#{fragment.join("\n")}\n"
        when "tt"
          new_text node, "{{{#{node.content}}}}"
        when "code"
          if node.parent.name == "pre"
            new_text node, node.content
          else
            new_text node, "{{{#{node.content}}}}"
          end
        when "pre"
          new_text node, "\n{{{\n#{node.content}\n}}}\n"
        when "br"
          new_text node, "\\\\"
        when "a"
          if node['href'].nil?
            new_text node, node.content
          else
            new_text node, %Q{[[#{node['href']}|#{node.text}]]}
          end
        else
          if Loofah::HashedElements::BLOCK_LEVEL[node.name]
            new_text node, "\n#{node.content}\n"
          else
            nil
          end
        end
      node.replace(replacement_killer) if replacement_killer
    end

    private

    def new_text(node, text)
      Nokogiri::XML::Text.new(text, node.document)
    end
  end
  # :startdoc:
end
