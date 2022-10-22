require "./spec_helper.cr"

LENGTH = {1, 0, 0, 0, 0, 0, 0}
TIME = {0, 1, 0, 0, 0, 0, 0}

describe CompileTimeUnit do
  it "should" do
    {% begin %}
    a = CompileTimeUnit(Int32, {{ LENGTH.splat }}).new(2)
    b = CompileTimeUnit(Int32, {{ TIME.splat }}).new(4)
    puts (a * b).inspect
    puts (a / b).inspect
    puts (a * 2).inspect
    puts (a / 2).inspect
    puts ((a / a) + 3).inspect
    {% end %}
  end
end
