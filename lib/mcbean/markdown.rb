class McBean

  class Markdownify < Loofah::Scrubber
    def initialize
      @direction = :bottom_up
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
        when "a"
          if node['title']
            link = new_text node, "[#{node.text}][#{node['title']}]"
            ref  = new_text node, "[#{node['title']}]: #{node['href']} \"#{node['title']}\""
            node.document.children.last.add_next_sibling ref
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
  end

  def to_markdown
    Loofah::Helpers.remove_extraneous_whitespace \
      html.dup.scrub!(:prune).scrub!(Markdownify.new).text(:encode_special_chars => false)
  end
end

