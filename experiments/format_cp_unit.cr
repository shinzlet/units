# {% num = 1500 %}
# {% src = num.stringify.chars %}
# {% str = "x" %}
# {% for digit in src %}
#   {% str += digits[digit] %}
# {% end %}

DIGITS = {'0' => '⁰', '1' => '¹', '2' => '²', '3' => '³', '4' => '⁴', '5' => '⁵', '6' => '⁶', '7' => '⁷', '8' => '⁸', '9' => '⁹'}

struct Test(N)
  macro superscript(input, append_to)
    \{% src = input.stringify.chars %}
    \{% output = "" %}
    \{% for digit in src %}
      \{% output += 'a' %}
    \{% end %}
    \{% append_to << output %}
  end

  def +(other)
    {% begin %}
      {% stringy = [] of StringLiteral %}
      {% puts "from +" %}
      superscript(N, stringy)
      {% puts stringy.join(" ") %}
    {% end %}
  end

  def -(other)
    {% begin %}
      {% raise run("./compile_time_formatter.cr", "n", N, "m", N + 1).stringify %}
    {% end %}
  end
end

Test(1).new - Test(2).new

struct Unit(T, L)
  getter amount

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

  alias Length = Unit(0, 1)
  alias Time = Unit(1, 0)

  def initialize(@amount : Float64)
  end

  def self.multiplicative_identity
    RuntimeUnit.new(1)
  end

  def self.additive_identity
    UnitAdditiveIdentity.new
  end

  def pretty_name : String
    if T == L && L == 0
      return "scalar"
    end

    output = [] of String

    output << raise_power("s", T)
    output << raise_power("m", L)

    output.join
  end
  
  def *(u : Unit(OT, OL)) forall OT, OL
    {% begin %}
    Unit({{ OT + T }}, {{ OL + L }}).new(@amount * u.amount)
    {% end %}
  end

  # def +(u : Unit(OT, OL)) forall OT, OL
  #   % begin %}
  #     % unless T == OT && L == OL %}
  #       % raise "Cannot add: s^#{T}m^#{L} is not compatible with s^#{OT}m^#{OL}" %}
  #     % end %}
  #   % end %}
  #   self.new(@amount + u.amount)
  # end

  def +(u : self)
    Unit(T, L).new(@amount + u.amount)
  end

  def *(x : Number)
    Unit(T, L).new(@amount * x)
  end

  def to_meters : Float64
    {% begin %}
      {% unless T == 0 && L == 1 %}
        {% raise "Cannot cast to meters: s^#{T}m^#{L} is not a length" %}
      {% end %}
    {% end %}

    @amount
  end

  def inspect(io : IO)
    to_s(io)
  end

  def to_s(io : IO) : Nil
    io << "Unit[#{@amount}#{pretty_name}]"
  end
end

puts Unit(1, 2).new(1)
