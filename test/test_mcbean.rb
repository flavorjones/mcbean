require File.dirname(__FILE__) + "/helper"

class TestMcBean < Test::Unit::TestCase
  context "class name" do
    should "set McBean and Mcbean to be the same thing" do
      assert McBean == Mcbean
    end
  end

  context "cleanup" do
    should "prune unsafe tags" do
      result = McBean.fragment("<div>OK</div><script>BAD</script>").to_markdown
      assert_match(    /OK/,  result)
      assert_no_match( /BAD/, result)
    end
  end

  context "parsing" do
    context "McBean.fragment" do
      should "call Loofah.fragment" do
        html = "<h1>hello</h1>\n"
        mock.proxy(Loofah).fragment(html).once
        McBean.fragment html
      end
    end

    context "McBean.document" do
      should "call Loofah.document" do
        html = "<h1>hello</h1>\n"
        mock.proxy(Loofah).document(html).once
        McBean.document html
      end
    end

    context "McBean.markdown" do
      context "passed a string" do
        should "create a Markdownify::Antidote" do
          mock.proxy(McBean::Markdownify::Antidote).new(anything).once
          assert_equal "<h1>hello</h1>\n", McBean.markdown("hello\n=====\n").to_html
        end
      end

      context "passed an IO" do
        should "create a Markdownify::Antidote" do
          io = StringIO.new "hello\n=====\n"
          mock.proxy(McBean::Markdownify::Antidote).new(anything).once
          mock.proxy(io).read.once
          assert_equal "<h1>hello</h1>\n", McBean.markdown(io).to_html
        end
      end
    end
  end
end
