require "math"

puts "{#{(0..9).map { |i| "'#{i}' => '#{superscript_digit(i)}'" }.join(", ")}}"

{% begin %}
  {% digits = {'0' => '⁰', '1' => '¹', '2' => '²', '3' => '³', '4' => '⁴', '5' => '⁵', '6' => '⁶', '7' => '⁷', '8' => '⁸', '9' => '⁹'} %}
  {% num = 1500 %}
  {% src = num.stringify.chars %}
  {% str = "x" %}
  {% for digit in src %}
    {% str += digits[digit] %}
  {% end %}
  {% raise str %}
{% end %}

# macro superscript_digit(x)
#   x + 1
# end

def superscript_digit(x : Int) : Char
  case x
  when 0, 4..9
    '\u{2070}' + x
  when 2, 3
    '\u{00b0}' + x
  when 1
    '\u{00b9}'
  else
    raise ":C (#{x} isn't a digit"
  end
end

def superscript(x : Int) : String
  num_digits = Math.log10(x).ceil.to_i32
  s = String.build(num_digits) do |sb|
    digit = x % 10
    while x > 0
      sb << superscript_digit(digit)

      x //= 10
      digit = x % 10
    end
  end

  s.reverse
end
