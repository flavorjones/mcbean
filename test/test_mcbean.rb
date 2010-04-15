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
      result.must_match %r{OK}
      result.wont_match %r{BAD}
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
        it "sets .markdown to be a Markdownify::Antidote" do
          McBean.markdown("hello\n=====\n").markdown.must_be_instance_of McBean::Markdownify::Antidote
        end
      end

      describe "passed an IO" do
        it "sets .markdown to be a Markdownify::Antidote" do
          io = StringIO.new "hello\n=====\n"
          McBean.markdown(io).markdown.must_be_instance_of McBean::Markdownify::Antidote
        end
      end
    end
  end

  describe "#to_html" do
    attr_accessor :mcbean

    describe "on an instance created by .fragment" do
      before do
        @mcbean = McBean.fragment "<div>ohai!</div>"
      end

      it "returns an html string" do
        html = mcbean.to_html
        html.must_be_instance_of String
        html.must_match %r{<div>ohai!</div>}
      end
    end

    describe "on an instance created by .fragment" do
      before do
        @mcbean = McBean.document "<div>ohai!</div>"
      end

      it "returns an html string" do
        html = mcbean.to_html
        html.must_be_instance_of String
        html.must_match %r{<div>ohai!</div>}
      end
    end

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
end
