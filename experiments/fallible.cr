require "../../ph-core/src/ph-core.cr"

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

# Seconds, kg, mol, cd, K, A, m
# time (T), length (L), mass (M), electric current (I), absolute temperature (Θ), amount of substance (N) and luminous intensity (J).
# Use O for temperature
struct Unit(T, L) < Number
  getter amount

  def_hash

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
    io << "Unit[#{@amount}s^#{T}m^#{L}]"
  end
end

struct UnitAdditiveIdentity
  def +(u : Unit)
    u
  end
end

struct RuntimeUnit < Number
  getter amount : Float64
  def_hash
  getter t, l
  def initialize(@amount, @t = 0, @l = 0)
  end

  def pretty_name : String
    if @t == @l && @l == 0
      return "scalar"
    end

    output = [] of String

    output << raise_power("s", @t)
    output << raise_power("m", @l)

    output.join
  end

  def *(u : RuntimeUnit)
    RuntimeUnit.new(@amount * u.amount, @t + u.t, @l + u.l)
  end

  def *(u : Unit(T, L)) forall T, L
    RuntimeUnit.new(@amount * u.amount, @t + T, @l + L)
  end

  def +(u : RuntimeUnit)
    if u.l == @l && u.t == @t
      RuntimeUnit.new(@amount + u.amount, @t, @l)
    else
      raise "Cannot add unit of #{u.pretty_name} to unit of #{pretty_name}"
    end
  end

  def +(u : Unit(T, L)) forall T, L
    if T == @t && L == @l
      RuntimeUnit.new(@amount + u.amount, @t, @l)
    else
      raise "Cannot add unit of #{u.pretty_name} to unit of #{pretty_name}"
    end
  end

  def to_s(io : IO) : Nil
    io << "RuntimeUnit[#{@amount}s^#{@t}m^#{@l}]"
  end
end

struct Number
  def meters : Unit::Length
    Unit::Length.new(self.to_f64)
  end

  def feet : Unit::Length
    Unit::Length.new(self.to_f64 * 0.3048)
  end

  def u_seconds : Unit(1, 0)
    Unit::Time.new(self.to_f64)
  end
end

# u = 2.meters
# puts u
# puts u*u
# puts u*u + u

# u = RuntimeUnit.new(2, l: 1)
# puts u
# puts u + RuntimeUnit.new(1, l: 1)
# puts u * RuntimeUnit.new(1, l: 1)
# puts u + RuntimeUnit.new(1, t: 1)

# u = 2.meters
# puts RuntimeUnit.new(2, l: 1) + u
# puts RuntimeUnit.new(2, t: 1) * u
# puts RuntimeUnit.new(2, l: 1) * u
# puts RuntimeUnit.new(2, t: 1) + u
 
# loop do
#   input = gets.not_nil!.to_i32
#   arr = [1.meters] * input
#   puts arr.product
# 
#   begin
#     puts arr.product + (5.meters * 5.meters)
#   rescue
#     puts "bad units!"
#   end
# end

([1.meters] * 2).product + 1.meters
