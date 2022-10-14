require "../../ph-core/src/ph-core.cr"

# Seconds, kg, mol, cd, K, A, m
# time (T), length (L), mass (M), electric current (I), absolute temperature (Θ), amount of substance (N) and luminous intensity (J).
# Use O for temperature
struct Unit(X, T, L)
  getter value

  def initialize(@value : X)
  end

  # def self.multiplicative_identity
  #   Unit(0, 0).new(1f64)
  # end

  # def self.additive_identity
  #   UnitAdditiveIdentity.new
  # end

  def *(u : Unit(X, OT, OL)) forall OT, OL
    {% begin %}
    Unit(X, {{ OT + T }}, {{ OL + L }}).new(@value * u.value)
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
    Unit(X, T, L).new(@value + u.value)
  end

  def *(x : Number)
    Unit(X, T, L).new(@value * x)
  end

  # def to_meters : X
  #   {% begin %}
  #     {% unless T == 0 && L == 1 %}
  #       {% raise "Cannot cast to meters: s^#{T}m^#{L} is not a length" %}
  #     {% end %}
  #   {% end %}

  #   @value
  # end

  def inspect(io : IO)
    io << "Unit[#{@value.inspect}s^#{T}m^#{L}]"
  end

  def to_s(io : IO)
    io << "Unit[#{@value.to_s}s^#{T}m^#{L}]"
  end

  def sum
    sum_helper(@value.sum)
  end

  private def sum_helper(value : K) forall K
    Unit(K, T, L).new(value)
  end
end

# puts "long and important setup"
# sleep 10.seconds
# 
# u = 2.meters
# puts u*u+u

include Phase

a = Unit(NArray(Int32), 0, 1).new(NArray[1, 2])
b = Unit(NArray(Int32), 0, 1).new(NArray[2, 1])
puts a + b
puts (a + b).sum
