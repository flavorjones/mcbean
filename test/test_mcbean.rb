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
end
