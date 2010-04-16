require 'rdiscount'

class McBean
  attr_writer :__markdown__ # :nodoc:

  @@__formats__ << "markdown"

  ##
  #  Create a McBean from a Markdown document string (or IO object)
  #
  def McBean.markdown(string_or_io)
    mcbean = new
    mcbean.__markdown__ = McBean::Markdownify::Antidote.new(string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io)
    mcbean
  end

  ##
  #  Generate a Markdown string representation of the McBeaned document.
  #
  #  So you can convert documents in other formats to Markdown as follows:
  #
  #    McBean.fragment(File.read(path_to_html_file)).to_markdown
  #
  def to_markdown
    __markdown__.text
  end

  def __markdown__ generate_from_html_if_necessary=true # :nodoc:
    @__markdown__ ||= nil
    if @__markdown__.nil? && generate_from_html_if_necessary
      @__markdown__ = McBean::Markdownify::Antidote.new(
                        Loofah::Helpers.remove_extraneous_whitespace(
                          __html__.dup.scrub!(:escape).scrub!(Markdownify.new).text(:encode_special_chars => false)
                      ))
    end
    @__markdown__
  end

  # :stopdoc:
  class Markdownify < Loofah::Scrubber
    Antidote = ::RDiscount # could conceivably be BlueCloth

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
          new_text node, "\n#{node.content}\n==========\n"
        when "h2"
          new_text node, "\n#{node.content}\n----------\n"
        when "h3"
          new_text node, "\n### #{node.content} ###\n"
        when "h4"
          new_text node, "\n#### #{node.content} ####\n"
        when "blockquote"
          fragment = node.inner_html
          fragment.gsub!(/\n(.)/, "\n&gt; \\1")
          node.document.fragment(fragment)
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
          node.xpath("./li").each_with_index do |li, j|
            fragment << "#{j+1}. #{li.text}" if li.text =~ /\S/
          end
          new_text node, "\n#{fragment.join("\n")}\n"
        when "code"
          if node.parent.name == "pre"
            new_text node, node.content.gsub(/^/,"    ")
          else
            nil
          end
        when "br"
          new_text node, "\n"
        when "a"
          if node['href'].nil?
            new_text node, node.content
          elsif node['title']
            unless @link_references
              @link_references = node.document.fragment("<div>\n</div>").children.first
              end_of_doc(node).add_next_sibling @link_references
            end
            @link_reference_count += 1
            key = "#{@link_reference_count}"
            link = new_text node, "[#{node.text}][#{key}]"
            ref  = new_text node, "[#{key}]: #{node['href']} \"#{node['title']}\"\n"
            @link_references.add_child ref
            link
          else
            new_text node, "[#{node.text}](#{node['href']})"
          end
        else
          if Loofah::HashedElements::BLOCK_LEVEL[node.name]
            new_text node, "\n#{node.content}\n"
          else
            nil
          end
        end
      if replacement_killer
        node.add_next_sibling replacement_killer
        node.remove
      end
    end

    private

    def new_text(node, text)
      Nokogiri::XML::Text.new(text, node.document)
    end

    def end_of_doc(node)
      (node.document.serialize_root || node.ancestors.last).children.last
    end
  end
  # :startdoc:
end
