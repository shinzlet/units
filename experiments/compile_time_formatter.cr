{% puts "Note: This compilation may take slightly longer than expected: ph-units uses the `run` macro to format its compile-time output, and this will build an auxillary crystal program on first invocation. Subsequent compilations will be a normal speed, and this message should not print again." %}

iter = ARGV.each

puts(String.build do |x|
  iter.each do |name|
    power = iter.next
    case power
    when Iterator::Stop
      puts "(formatter error)"
      exit 0
    when String
      if power = power.to_i?
        x << raise_power(name, power)
      else
        puts "(formatter error)"
        exit 0
      end
    end
  end
end)

def raise_power(name : String, power : Int)
  case power
  when 0
    ""
  when 1
    name
  else
    name + superscript(power)
  end
end

def superscript_digit(x : Int) : Char
  case x
  when 0, 4..9
    '\u{2070}' + x
  when 2, 3
    '\u{00b0}' + x
  when 1
    '\u{00b9}'
  else
    ' '
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
