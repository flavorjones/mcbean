require "minitest/autorun"
require "mcbean"
require "rr"

class MiniTest::Spec
  include RR::Adapters::TestUnit
end
