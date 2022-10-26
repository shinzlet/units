require "./spec_helper.cr"

TIME = {1, 0, 0, 0, 0, 0, 0}
LENGTH = {0, 1, 0, 0, 0, 0, 0}

# Units::Formatting.use_superscript = false

describe CompileTimeUnit do
  it "should" do
    {% begin %}
    a = CompileTimeUnit(Int32, {{ LENGTH.splat }}).new(2)
    b = CompileTimeUnit(Int32, {{ TIME.splat }}).new(4)
    puts (a * b)
    puts (a / b)
    puts (a * 2)
    puts (a / 2)
    puts ((a / a) + 3)
    puts (Units.from_feet(3) + a).inspect
    puts (Units.from_feet(3) + a)
    puts (CompileTimeUnit.from_meters(3).left_add CompileTimeUnit.from_yards(2))
    puts (Units.from_meters(3) ** 2).inspect
    puts (Units.from_meters(3) ** Fix(2)).inspect
    a = Units.from_feet(2)
    puts a
    puts a.sq
    puts a.sqrt
    puts a.cb
    puts a.cbrt
    puts a.inverse.sq
    puts a.sq.cbrt
    puts 12.as_in.to_ft
    puts 12.as_in.to { 1.as_in ** 1 }
    puts CompileTimeUnit.from(10, 1.as_in)
    puts 12.as_in ** 2 + 3.as_seconds
    {% end %}
  end
end
