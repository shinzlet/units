require "./spec_helper.cr"

TIME = {1, 0, 0, 0, 0, 0, 0}
LENGTH = {0, 1, 0, 0, 0, 0, 0}

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
    puts (Units.from_feet(3) + a).inspect
    puts (Units.from_feet(3) + a)
    puts (CompileTimeUnit.from_meters(3) + RuntimeUnit.from_yards(2))
    {% end %}
  end
end
