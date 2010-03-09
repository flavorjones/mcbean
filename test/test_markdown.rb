require File.dirname(__FILE__) + "/helper"

class TestMcBeanMarkdown < Test::Unit::TestCase
  context "markdown" do
    should "add whitespace around block elements" do
      assert_markdown "before<div>inner</div>after", "before\ninner\nafter", false
    end

    should "convert h1 tag" do
      assert_markdown "<h1>Foo</h1>", "\nFoo\n==========\n"
    end

    should "convert h2 tag" do
      assert_markdown "<h2>Foo</h2>", "\nFoo\n----------\n"
    end

    should "convert h3 tag" do
      assert_markdown "<h3>Foo</h3>", "\n### Foo ###\n"
    end

    should "convert h4 tag" do
      assert_markdown "<h4>Foo</h4>", "\n#### Foo ####\n"
    end

    should "convert blockquote tag" do
      assert_markdown "<blockquote><p>Hello\nGoodbye</p></blockquote>",
                      "> Hello\n> Goodbye\n"
    end

#     should "convert nested blockquote tag" do
#       assert_markdown(
#         "<blockquote><p>Hello</p>\n\n<blockquote><p>Nested</p></blockquote>\n\n<p>Goodbye</p></blockquote>",
# <<-EOM
# > Hello
# >
# > > Nested
# >
# > Goodbye
# EOM
#         )
#     end

    should "convert unordered list" do
      assert_markdown "<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>\n",
                      "\n* one\n* two\n* three\n"
    end

    should "convert ordered list" do
      assert_markdown "<ol>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ol>\n",
                      "\n1. one\n2. two\n3. three\n"
    end

    should "ignore empty unordered list items" do
      assert_markdown "<ul>\n<li>one</li>\n<li></li>\n<li>three</li>\n</ul>\n",
                      "\n* one\n* three\n",
                      false
    end

    should "ignore empty ordered list items" do
      assert_markdown "<ol>\n<li>one</li>\n<li></li>\n<li>three</li>\n</ol>\n",
                      "\n1. one\n3. three\n",
                      false
    end

    should "convert code blocks" do
      assert_markdown "<pre><code>This is a code block\ncontinued\n</code></pre>",
                      "\n    This is a code block\n    continued\n\n"
    end

    context "anchors" do
      should "convert <a> tags" do
        assert_markdown "<p>Yes, magic helmet. And <a href=\"http://sample.com/\">I'll give you a sample</a>.</p>",
          "\nYes, magic helmet. And [I'll give you a sample](http://sample.com/).\n"
      end

      should "convert <a> tags with titles to reference-style" do
        html     = "<p>Yes, magic helmet. And <a href=\"http://sample.com/\" title=\"Fudd\">I'll give you a sample</a>.</p>"
        markdown = "\nYes, magic helmet. And [I'll give you a sample][Fudd].\n\n[Fudd]: http://sample.com/ \"Fudd\"\n"

        # note peskily absent newline at end of document. sigh.
        assert_equal(html, BlueCloth.new(markdown).to_html, "markdown roundtrip failed")
        assert_equal(markdown, McBean.fragment(html).to_markdown, "fragment transformation failed")
        assert_equal(Loofah::Helpers.remove_extraneous_whitespace("\n#{markdown}"),
          McBean.document("<div>#{html}</div>").to_markdown, "document transformation failed")
      end
    end
  end

  private

  def assert_markdown html, markdown, roundtrip=true
    assert_equal(html, BlueCloth.new(markdown).to_html, "markdown roundtrip failed") if roundtrip
    assert_equal(markdown, McBean.fragment(html).to_markdown, "fragment transformation failed")
    assert_equal(Loofah::Helpers.remove_extraneous_whitespace("\n#{markdown}\n"),
      McBean.document("<div>#{html}</div>").to_markdown, "document transformation failed")
  end
end
