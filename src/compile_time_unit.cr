require "./algebraic_unit"
require "./building"
require "./casting"
require "./dimension"
require "./fix"
require "./formatting"
require "./runtime_unit"
require "./si_info"
require "./unit_error"

struct Units::CompileTimeUnit(X, M, L, J, O, I, N, T)
  private ERRFMT = "./compile_time_formatter.cr"
  extend Building

  include AlgebraicUnit(X)
  include Casting
  protected getter value : X

  # TODO: add `protected` again
  def initialize(@value : X)
  end

  {% begin %}
    {% idx = 0 %}
    {% for triple in SI_INFO %}
      {% dimension = {0, 0, 0, 0, 0, 0, 0} %}
      {% dimension[idx] = 1 %}

      def self.from_{{ triple[1].id }}(value)
        CompileTimeUnit(typeof(value), {{ dimension.splat }}).new(value)
      end

      def to_{{ triple[1].id }}
        \{% begin %}
           dummy_target = uninitialized CompileTimeUnit(X, {{ dimension.splat }})
           CompileTimeUnit.assert_same_units!(self, dummy_target)
           @value
        \{% end %}
      end

      {% idx += 1 %}
    {% end %}
  {% end %}

  def self.from(value, measure : CompileTimeUnit(_, M, L, J, O, I, N, T)) forall M, L, J, O, I, N, T
    new_value = value * measure.value
    CompileTimeUnit(typeof(new_value), M, L, J, O, I, N, T).new(new_value)
  end

  def to(measure : CompileTimeUnit)
    CompileTimeUnit.assert_same_units!(self, measure)
    @value / measure.value
  end

  def to(measure : AlgebraicUnit)
    if dimension =~ measure.dimension
      @value / measure.value
    else
      raise UnitError.new(self.dimension, measure.dimension)
    end
  end

  def dimension : Dimension
    {% begin %}
      Dimension.new({{ M }}, {{ L }}, {{ J }},
                    {{ O }}, {{ I }}, {{ N }}, {{ T }})
    {% end %}
  end

  def - : CompileTimeUnit
    new_value = -@value

    {% begin %}
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end

  def inverse : CompileTimeUnit
    new_value = 1 / @value

    {% begin %}
      CompileTimeUnit(
        typeof(new_value), {{ -M }},
        {{ -L }}, {{ -J }}, {{ -O }},
        {{ -I }}, {{ -I }}, {{ -T }}).new(new_value)
    {% end %}
  end

  protected def self.assert_same_units!(u1 : CompileTimeUnit(_, M1, L1, J1, O1, I1, N1, T1), u2 : CompileTimeUnit(_, M2, L2, J2, O2, I2, N2, T2)) forall M1, L1, J1, O1, I1, N1, T1, M2, L2, J2, O2, I2, N2, T2 
    {% begin %}
      {% pairs = [{M1, M2}, {L1, L2}, {J1, J2}, {O1, O2}, {I1, I2}, {N1, N2}, {T1, T2}] %}
      {% tolerance_sq = Dimension::TOLERANCE ** 2 %}
      {% if pairs.any? { |p| (p[0] - p[1]) ** 2 > tolerance_sq } %}
        {% raise "Refusing to compile because `#{run(ERRFMT, M1, L1, J1, O1, I1, N1, T1)}` and `#{run(ERRFMT, M2, L2, J2, O2, I2, N2, T2)}` are not compatible units" %}
      {% end %}
    {% end %}
  end

  protected def self.assert_scalar!(u1 : CompileTimeUnit(_, M, L, J, O, I, N, T)) forall M, L, J, O, I, N, T
    {% begin %}
      {% values = [M, L, J, O, I, N, T] %}
      {% tolerance_sq = Dimension::TOLERANCE ** 2 %}
      {% if values.any? { |v| v ** 2 > tolerance_sq } %}
        {% raise "Refusing to compile because `#{run(ERRFMT, M, L, J, O, I, N, T)}` and `(scalar)` are not compatible units" %}
      {% end %}
    {% end %}
  end

  def +(other : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
    CompileTimeUnit.assert_same_units!(self, other)

    {% begin %}
      new_value = @value + other.value
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end

  def -(other : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
    CompileTimeUnit.assert_same_units!(self, other)

    {% begin %}
      new_value = @value - other.value
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end

  def *(other : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
    {% begin %}
      new_value = @value * other.value
      {% pairs = [{M, M2}, {L, L2}, {J, J2}, {O, O2}, {I, I2}, {N, N2}, {T, T2}] %}
      {% new_units = pairs.map { |p| p[0] + p[1] } %}
      CompileTimeUnit(
        typeof(new_value),
        {{ new_units.splat }}
      ).new(new_value)
    {% end %}
  end

  def /(other : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
    {% begin %}
      new_value = @value / other.value
      {% pairs = [{M, M2}, {L, L2}, {J, J2}, {O, O2}, {I, I2}, {N, N2}, {T, T2}] %}
      {% new_units = pairs.map { |p| p[0] - p[1] } %}
      CompileTimeUnit(
        typeof(new_value),
        {{ new_units.splat }}
      ).new(new_value)
    {% end %}
  end

  def +(other : AlgebraicUnit)
    other.left_add(self)
  end

  def -(other : AlgebraicUnit)
    other.left_subtract(self)
  end

  def *(other : AlgebraicUnit)
    other.left_multiply(self)
  end

  def /(other : AlgebraicUnit)
    other.inverse.left_multiply(self)
  end

  def +(other)
    CompileTimeUnit.assert_scalar!(self)

    @value + other
  end

  def -(other)
    CompileTimeUnit.assert_scalar!(self)

    @value - other
  end
  
  def *(other) : CompileTimeUnit
    new_value = @value * other

    {% begin %}
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end

  def /(other) : CompileTimeUnit
    new_value = @value / other

    {% begin %}
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end
  
  def **(power : Fix(Exp).class) : CompileTimeUnit forall Exp
    {% begin %}
      {% new_dim = {M, L, J, O, I, N, T}.map &.*(Exp) %}
      new_value = @value ** {{ Exp }}
      CompileTimeUnit(typeof(new_value), {{ new_dim.splat }}).new(new_value)
    {% end %}
  end

  def **(other) : RuntimeUnit
    new_value = @value ** other
    RuntimeUnit.new(new_value, dimension * other)
  end

  def left_add(lhs : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
    CompileTimeUnit.assert_same_units!(self, lhs)

    {% begin %}
      new_value = lhs.value + @value
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end

  def left_add(lhs)
    CompileTimeUnit.assert_scalar!(self)

    lhs + @value
  end

  def left_multiply(lhs : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
    {% begin %}
      new_value = lhs.value * @value
      {% pairs = [{M, M2}, {L, L2}, {J, J2}, {O, O2}, {I, I2}, {N, N2}, {T, T2}] %}
      {% new_units = pairs.map { |p| p[0] + p[1] } %}
      CompileTimeUnit(
        typeof(new_value),
        {{ new_units.splat }}
      ).new(new_value)
    {% end %}
  end

  def left_multiply(lhs)
    new_value = lhs * @value

    {% begin %}
      CompileTimeUnit(
        typeof(new_value),
        {{ @type.type_vars[1..].splat }}
      ).new(new_value)
    {% end %}
  end

  def sq
    self ** Fix(2)
  end

  def sqrt
    self ** Fix(0.5_f64)
  end

  def cb
    self ** Fix(3)
  end

  def cbrt
    {% begin %}
    self ** Fix( {{ 1 / 3 }})
    {% end %}
  end
end 
