require File.dirname(__FILE__) + "/helper"

describe McBean::Textilify do
  describe ".textile" do
    describe "passed a string" do
      it "sets #__textile__ to be a Textilify::Antidote" do
        McBean.textile("h1. hello").__textile__.must_be_instance_of McBean::Textilify::Antidote
      end
    end

    describe "passed an IO" do
      it "sets #__textile__ to be a Textilify::Antidote" do
        io = StringIO.new "h1. hello"
        McBean.textile(io).__textile__.must_be_instance_of McBean::Textilify::Antidote
      end
    end
  end

  describe "#to_html" do
    attr_accessor :mcbean

    describe "on an instance created by .textile" do
      before do
        @mcbean = McBean.textile "h1. ohai!"
      end

      it "returns an html string" do
        html = mcbean.to_html
        html.must_be_instance_of String
        html.must_match %r{<h1>ohai!</h1>}
      end
    end
  end

  describe "#to_textile" do

  end

end

describe McBean::Textilify::Antidote do
  describe "given that RedCloth is already pretty well tested, let's limit ourselves to a token test case" do
    it "convert textile into html" do
      McBean.textile("h1. hello").to_html.must_match %r{<body><h1>hello</h1></body>}
    end
  end

  describe "given textile with an unsafe tag" do
    it "escapes the tag" do
      textile = "h1. hello\n\n<script>alert('ohai!');</script>\n\nlol\n"
      McBean.textile(textile).to_html.must_include "<body>\n<h1>hello</h1>\n&lt;script&gt;alert('ohai!');&lt;/script&gt;<p>lol</p>\n</body>"
    end
  end

  describe "given textile with an invalid tag" do
    it "escapes the tag" do
      textile = "h1. hello\n\n<xyzzy>Adventure!</xyzzy>\n\nlol\n"
      McBean.textile(textile).to_html.must_match %r{<body>\n<h1>hello</h1>\n&lt;xyzzy&gt;Adventure!&lt;/xyzzy&gt;<p>lol</p>\n</body>}
    end
  end
end
