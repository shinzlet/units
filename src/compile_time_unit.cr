require "./algebraic_unit"

module Units
  class CompileTimeUnit(X, M, L, J, O, I, N, T)
    private TOLERANCE = 1e-3
    include AlgebraicUnit(X)

    protected getter value : X

    # TODO: add `protected` again
    def initialize(@value : X)
    end

    def dimension : Dimension
      {% begin %}
        Dimension.new({{ M }}, {{ L }}, {{ J }},
                      {{ O }}, {{ I }}, {{ N }}, {{ T }})
      {% end %}
    end

    def - : self
      new_value = -@value

      {% begin %}
        CompileTime(
          typeof(new_value),
          {{ @type.type_vars[1..].splat }}
        ).new(new_value)
      {% end %}
    end

    def inverse : self
      new_value = 1 / @value

      {% begin %}
        CompileTimeUnit(
          typeof(new_value), {{ -M }},
          {{ -L }}, {{ -J }}, {{ -O }},
          {{ -I }}, {{ -I }}, {{ -T }}).new(new_value)
      {% end %}
    end

    protected def self.assert_same_unit!(u1 : CompileTimeUnit(_, M1, L1, J1, O1, I1, N1, T1), u2 : CompileTimeUnit(_, M2, L2, J2, O2, I2, N2, T2)) forall M1, L1, J1, O1, I1, N1, T1, M2, L2, J2, O2, I2, N2, T2 
      {% begin %}
        {% pairs = [{M1, M2}, {L1, L2}, {J1, J2}, {O1, O2}, {I1, I2}, {N1, N2}, {T1, T2}] %}
        {% tolerance_sq = TOLERANCE ** 2 %}
        {% if pairs.any? { |p| (p[0] - p[1]) ** 2 > tolerance_sq } %}
          {% raise "bad!" %}
        {% end %}
      {% end %}
    end

    protected def self.assert_scalar!(u1 : CompileTimeUnit(_, M, L, J, O, I, N, T)) forall M, L, J, O, I, N, T
      {% begin %}
        {% values = [M, L, J, O, I, N, T] %}
        {% tolerance_sq = TOLERANCE ** 2 %}
        {% if values.any? { |v| v ** 2 > tolerance_sq } %}
          {% raise "bad!" %}
        {% end %}
      {% end %}
    end

    def +(other : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
      CompileTimeUnit.assert_same_unit!(self, other)

      {% begin %}
        new_value = @value + other.value
        CompileTime(
          typeof(new_value),
          {{ @type.type_vars[1..].splat }}
        ).new(new_value)
      {% end %}
    end

    def -(other : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
      CompileTimeUnit.assert_same_unit!(self, other)

      {% begin %}
        new_value = @value - other.value
        CompileTime(
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

    def left_add(lhs : CompileTimeUnit(X2, M2, L2, J2, O2, I2, N2, T2)) : CompileTimeUnit forall X2, M2, L2, J2, O2, I2, N2, T2
      CompileTimeUnit.assert_same_unit!(self, lhs)

      {% begin %}
        new_value = lhs.value + @value
        CompileTime(
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
        new_value = other.value * @value
        {% pairs = [{M, M2}, {L, L2}, {J, J2}, {O, O2}, {I, I2}, {N, N2}, {T, T2}] %}
        {% new_units = pairs.map { |p| p[0] + p[1] } %}
        CompileTimeUnit(
          typeof(new_value),
          {{ new_units.splat }}
        ).new(new_value)
      {% end %}
    end

    def left_multiply(lhs)
      new_value = other * @value

      {% begin %}
        CompileTime(
          typeof(new_value),
          {{ @type.type_vars[1..].splat }}
        ).new(new_value)
      {% end %}
    end
  end
end 
