require File.dirname(__FILE__) + "/helper"

describe McBean do
  describe "class name" do
    it "sets McBean and Mcbean to be the same thing" do
      assert McBean == Mcbean
    end
  end

  describe "cleanup" do
    it "prunes unsafe tags" do
      result = McBean.fragment("<div>OK</div><script>BAD</script>").to_markdown
      result.must_match /OK/
      result.wont_match /BAD/
    end
  end

  describe "parsing" do
    describe "McBean.fragment" do
      it "sets .html to be a Loofah fragment" do
        McBean.fragment("<h1>hello</h1>\n").html.must_be_instance_of Loofah::HTML::DocumentFragment
      end
    end

    describe "McBean.document" do
      it "sets .html to be a Loofah document" do
        McBean.document("<h1>hello</h1>\n").html.must_be_instance_of Loofah::HTML::Document
      end
    end

    describe "McBean.markdown" do
      describe "passed a string" do
        it "creates a Markdownify::Antidote" do
          mock.proxy(McBean::Markdownify::Antidote).new(anything).once
          McBean.markdown("hello\n=====\n").to_html.must_equal "<h1>hello</h1>\n"
        end
      end

      describe "passed an IO" do
        it "creates a Markdownify::Antidote" do
          io = StringIO.new "hello\n=====\n"
          mock.proxy(McBean::Markdownify::Antidote).new(anything).once
          mock.proxy(io).read.once
          assert_equal "<h1>hello</h1>\n", McBean.markdown(io).to_html
        end
      end
    end
  end
end
