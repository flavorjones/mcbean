require File.dirname(__FILE__) + "/helper"

describe McBean::Creolize do
  describe ".creole" do
    describe "passed a string" do
      it "sets #__creole__ to be a Creolize::Antidote" do
        McBean.creole("= hello =").__creole__.must_be_instance_of McBean::Creolize::Antidote
      end
    end

    describe "passed an IO" do
      it "sets #__creole__ to be a Creolize::Antidote" do
        io = StringIO.new "= hello ="
        McBean.creole(io).__creole__.must_be_instance_of McBean::Creolize::Antidote
      end
    end
  end

  describe "#to_html" do
    attr_accessor :mcbean

    describe "on an instance created by .creole" do
      before do
        @mcbean = McBean.creole "= ohai! =\n\n"
      end

      it "returns an html string" do
        html = mcbean.to_html
        html.must_be_instance_of String
        html.must_match %r{<h1>ohai!</h1>}
      end
    end
  end

  describe "#to_creole" do
    it "adds whitespace around block elements" do
      assert_creole "before<div>inner</div>after", "before\ninner\nafter", false
    end

    it "converts h1 tag" do
      assert_creole "<h1>Foo</h1>", "\n= Foo =\n"
    end

    it "removes newlines from header tags" do
      assert_creole "<h1>Foo\nBar</h1>", "\n= Foo Bar =\n", false
    end

    it "converts h2 tag" do
      assert_creole "<h2>Foo</h2>", "\n== Foo ==\n"
    end

    it "converts h3 tag" do
      assert_creole "<h3>Foo</h3>", "\n=== Foo ===\n"
    end

    it "converts h4 tag" do
      assert_creole "<h4>Foo</h4>", "\n==== Foo ====\n"
    end

    # it "converts blockquote tag" do
    #   assert_creole "<blockquote>\n<p>foo fazz<br />\nbizz buzz<br />\nwang wong</p>\n</blockquote>", "\n foo fazz\n bizz buzz\n wang wong\n"
    # end

    it "converts ul lists" do
      html = "<ul><li>foo</li><li>wuxx</li></ul>"
      creole = "\n* foo\n* wuxx\n"
      assert_creole html, creole
    end

    it "converts ol lists" do
      html = "<ol><li>foo</li><li>wuxx</li></ol>"
      creole = "\n# foo\n# wuxx\n"
      assert_creole html, creole
    end

    it "ignores empty unordered list items" do
      assert_creole "<ul>\n<li>one</li>\n<li></li>\n<li>three</li>\n</ul>\n",
        "\n* one\n* three\n",
        false
    end

    it "ignores empty ordered list items" do
      assert_creole "<ol>\n<li>one</li>\n<li></li>\n<li>three</li>\n</ol>\n",
        "\n# one\n# three\n",
        false
    end

    it "converts pre/code blocks" do
      assert_creole "<pre><code>This is a code block\ncontinued</code></pre>",
        "\n{{{\nThis is a code block\ncontinued\n}}}\n", false
    end

    it "converts code blocks" do
      assert_creole "<code>This is code</code>",
        "{{{This is code}}}", false
    end

    it "converts tt blocks" do
      assert_creole "<p>hello <tt>This is tt</tt> goodbye</p>",
        "\nhello {{{This is tt}}} goodbye\n"
    end

    it "converts pre blocks" do
      assert_creole "<pre>This is a pre block\ncontinued</pre>",
        "\n{{{\nThis is a pre block\ncontinued\n}}}\n"
    end

    it "converts <br> tags to '\\'" do
      assert_creole "<p>hello<br>there</p>", "\nhello\\\\there\n", false
      assert_creole "<p>hello<br/>there</p>", "\nhello\\\\there\n"
    end

    describe "anchors" do
      it "converts <a> tags" do
        assert_creole "<p>Yes, magic helmet. And <a href=\"http://sample.com/\">I will give you a sample</a>.</p>",
          %Q{\nYes, magic helmet. And [[http://sample.com/|I will give you a sample]].\n}
      end

      describe "<a> tags without hrefs" do
        it "ignores them" do
          assert_creole "<div><a name='link-target'>target title</a></div>",
            "\ntarget title\n",
            false

          assert_creole "<div><a id='link-target'>target title</a></div>",
            "\ntarget title\n",
            false
        end
      end

      describe "<a> tags with titles" do
        it "ignores the title" do
          assert_creole %Q{<p>Yes, magic helmet. And <a href="http://sample.com/" title="Fudd">I will give you a sample</a>.</p>},
          %Q{\nYes, magic helmet. And [[http://sample.com/|I will give you a sample]].\n}, false
        end
      end
    end
  end

  def assert_creole html, creole, roundtrip=true
    assert_equal(html, McBean::Creolize::Antidote.new(creole).to_html, "creole roundtrip failed") if roundtrip
    assert_equal(creole, McBean.fragment(html).to_creole, "fragment transformation failed")
    assert_equal(Loofah::Helpers.remove_extraneous_whitespace("\n#{creole}\n"),
      McBean.document("<div>#{html}</div>").to_creole, "document transformation failed")
  end

end

describe McBean::Creolize::Antidote do
  describe "given that creole is already pretty well tested, let's limit ourselves to a token test case" do
    it "convert creole into html" do
      McBean.creole("= hello =\n").to_html.must_match %r{<body><h1>hello</h1></body>}
    end
  end

  describe "given creole with an unsafe tag" do
    it "escapes the tag" do
      creole = "= hello =\n\n<script>alert('ohai!');</script>\n\nlol\n"
      McBean.creole(creole).to_html.must_include "&lt;script&gt;alert('ohai!');&lt;/script&gt;"
    end
  end

  describe "given creole with an invalid tag" do
    it "escapes the tag" do
      creole = "= hello =\n\n<xyzzy>Adventure!</xyzzy>\n\nlol\n"
      McBean.creole(creole).to_html.must_match %r{&lt;xyzzy&gt;Adventure!&lt;/xyzzy&gt;}
    end
  end
end
