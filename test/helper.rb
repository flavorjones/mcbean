require "test/unit"
require "mcbean"
require "shoulda"
require "rr"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
