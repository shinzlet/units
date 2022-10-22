require "./dimension"

{% puts "Note: The first compilation with `units` installed will be slightly slower, as the compile-time formatter has not yet been cached. On subsequent compilations, speed should return to normal and this message should not be printed." %}

# Usage:
# compile_time_formatter DIMENSION_LIST
# DIMENSION_LIST is a list of 7 numbers that must be
# indexed one-to-one with Units::SI_INFO.

# This code must not crash - if it does, it will be extremely confusing to the
# user as to where their error comes from. Thus, any "invalid input" should
# just print a warning message and exit with 0, not actually cause any havoc.

iter = ARGV.each

dims = {0, 0, 0, 0, 0, 0, 0}.map do
  exp = iter.next
  case exp
  in Iterator::Stop
    print "(formatter error)"
    exit 0
  in String
    exp.to_f32
  end
end

print Units::Dimension.new(*dims)
