require File.dirname(__FILE__) + "/helper"

describe McBean::Markdownify do
  describe ".markdown" do
    describe "passed a string" do
      it "sets #__markdown__ to be a Markdownify::Antidote" do
        McBean.markdown("hello\n=====\n").__markdown__.must_be_instance_of McBean::Markdownify::Antidote
      end
    end

    describe "passed an IO" do
      it "sets #__markdown__ to be a Markdownify::Antidote" do
        io = StringIO.new "hello\n=====\n"
        McBean.markdown(io).__markdown__.must_be_instance_of McBean::Markdownify::Antidote
      end
    end
  end

  describe "#to_html" do
    attr_accessor :mcbean

    describe "on an instance created by .markdown" do
      before do
        @mcbean = McBean.markdown "ohai!\n=====\n"
      end

      it "returns an html string" do
        html = mcbean.to_html
        html.must_be_instance_of String
        html.must_match %r{<h1>ohai!</h1>}
      end
    end
  end

  describe "#to_markdown" do
    it "add whitespace around block elements" do
      assert_markdown "before<div>inner</div>after", "before\ninner\nafter", false
    end

    it "convert h1 tag" do
      assert_markdown "<h1>Foo</h1>", "\nFoo\n==========\n"
    end

    it "convert h2 tag" do
      assert_markdown "<h2>Foo</h2>", "\nFoo\n----------\n"
    end

    it "convert h3 tag" do
      assert_markdown "<h3>Foo</h3>", "\n### Foo ###\n"
    end

    it "convert h4 tag" do
      assert_markdown "<h4>Foo</h4>", "\n#### Foo ####\n"
    end

    it "convert blockquote tag" do
      assert_markdown "<blockquote><p>Hello\nGoodbye</p></blockquote>",
      "> Hello\n> Goodbye"
    end

    #     it "convert nested blockquote tag" do
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

    it "convert unordered list" do
      assert_markdown "<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>\n",
      "\n* one\n* two\n* three\n"
    end

    it "convert ordered list" do
      assert_markdown "<ol>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ol>\n",
      "\n1. one\n2. two\n3. three\n"
    end

    it "ignore empty unordered list items" do
      assert_markdown "<ul>\n<li>one</li>\n<li></li>\n<li>three</li>\n</ul>\n",
      "\n* one\n* three\n",
      false
    end

    it "ignore empty ordered list items" do
      assert_markdown "<ol>\n<li>one</li>\n<li></li>\n<li>three</li>\n</ol>\n",
      "\n1. one\n3. three\n",
      false
    end

    it "convert code blocks" do
      assert_markdown "<pre><code>This is a code block\ncontinued\n</code></pre>",
      "\n    This is a code block\n    continued\n\n"
    end

    it "convert <br> tags to newlines" do
      assert_markdown "<div>hello<br>there</div>",
      "\nhello\nthere\n",
      false
      assert_markdown "<div>hello<br />there</div>",
      "\nhello\nthere\n",
      false
    end

    describe "anchors" do
      it "convert <a> tags" do
        assert_markdown "<p>Yes, magic helmet. And <a href=\"http://sample.com/\">I'll give you a sample</a>.</p>",
        "\nYes, magic helmet. And [I'll give you a sample](http://sample.com/).\n"
      end

      describe "<a> tags without hrefs" do
        it "be ignored" do
          assert_markdown "<div><a name='link-target'>target title</a></div>",
          "\ntarget title\n",
          false

          assert_markdown "<div><a id='link-target'>target title</a></div>",
          "\ntarget title\n",
          false
        end
      end

      describe "<a> tags with titles" do
        it "convert fq urls to reference-style" do
          assert_markdown2 "<p>Yes, magic helmet. And <a href=\"http://sample.com/\" title=\"Fudd\">I'll give you a sample</a>.</p>",
          "\nYes, magic helmet. And [I'll give you a sample][1].\n\n[1]: http://sample.com/ \"Fudd\"\n"
        end

        it "convert relative urls to reference-style" do
          assert_markdown2 "<p>Yes, magic helmet. And <a href=\"/home\" title=\"Fudd\">I'll give you a sample</a>.</p>",
          "\nYes, magic helmet. And [I'll give you a sample][1].\n\n[1]: /home \"Fudd\"\n"
        end

        it "convert multiple to appear in order at the end of the document" do
          assert_markdown2 "<p>See <a href=\"/prefs\" title=\"Prefs\">Prefs</a> and <a href=\"/home\" title=\"Home\">Home</a>.</p>",
          "\nSee [Prefs][1] and [Home][2].\n\n[1]: /prefs \"Prefs\"\n[2]: /home \"Home\"\n"
        end
      end
    end
  end

  def assert_markdown html, markdown, roundtrip=true
    assert_equal(html, McBean::Markdownify::Antidote.new(markdown).to_html.chomp, "markdown roundtrip failed") if roundtrip
    assert_equal(markdown, McBean.fragment(html).to_markdown, "fragment transformation failed")
    assert_equal(Loofah::Helpers.remove_extraneous_whitespace("\n#{markdown}\n"),
      McBean.document("<div>#{html}</div>").to_markdown, "document transformation failed")
  end

  def assert_markdown2 html, markdown, roundtrip=true
    # note peskily absent newline at end of document. sigh.
    assert_equal(html, McBean::Markdownify::Antidote.new(markdown).to_html.chomp, "markdown roundtrip failed") if roundtrip
    assert_equal(markdown, McBean.fragment(html).to_markdown, "fragment transformation failed")
    assert_equal(Loofah::Helpers.remove_extraneous_whitespace("\n#{markdown}"),
      McBean.document("<div>#{html}</div>").to_markdown, "document transformation failed")
  end
end

describe McBean::Markdownify::Antidote do
  describe "given that RDiscount is already pretty well tested, let's limit ourselves to a token test case" do
    it "convert markdown into html" do
      McBean.markdown("hello\n=====\n").to_html.must_match %r{<body><h1>hello</h1></body>}
    end
  end

  describe "given markdown with an unsafe tag" do
    it "escapes the tag" do
      markdown = "hello\n=====\n\n<script>alert('ohai!');</script>\n\nLOL\n"
      McBean.markdown(markdown).to_html.must_include "<body>\n<h1>hello</h1>\n\n&lt;script&gt;alert('ohai!');&lt;/script&gt;<p>LOL</p>\n</body>"
    end
  end

  describe "given markdown with an invalid tag" do
    it "escapes the tag" do
      markdown = "hello\n=====\n\n<xyzzy>Adventure!</xyzzy>\n\nLOL\n"
      McBean.markdown(markdown).to_html.must_match %r{<body>\n<h1>hello</h1>\n\n<p>&lt;xyzzy&gt;Adventure!&lt;/xyzzy&gt;</p>\n\n<p>LOL</p>\n</body>}
    end
  end
end
