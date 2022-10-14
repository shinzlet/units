require "../../ph-core/src/ph-core.cr"

# Seconds, kg, mol, cd, K, A, m
# time (T), length (L), mass (M), electric current (I), absolute temperature (Θ), amount of substance (N) and luminous intensity (J).
# Use O for temperature
struct Unit(T, L)
  protected getter amount

  alias Length = Unit(0, 1)
  alias Time = Unit(1, 0)

  def initialize(@amount : Float64)
  end

  def self.multiplicative_identity
    Unit(0, 0).new(1f64)
  end

  def self.additive_identity
    UnitAdditiveIdentity.new
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

  def to_s(io : IO)
    io << "Unit[#{@amount}s^#{T}m^#{L}]"
  end
end

struct UnitAdditiveIdentity
  def +(u : Unit)
    u
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

# puts "long and important setup"
# sleep 10.seconds
# 
u = 2.meters
puts u
puts u*u
puts "very long operation"
puts u*u + u

# include Phase

# n1 = NArray[[1.meters, 1.meters]]
# n2 = NArray[[1.meters, 2.meters]]
# n3 = n1 + n2
# puts n3.sum
