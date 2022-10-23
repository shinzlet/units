require "../algebraic_unit"
require "../registry"

abstract struct Number
  def +(other : Units::AlgebraicUnit)
    other.left_add(self)
  end

  def -(other : Units::AlgebraicUnit)
    other.left_subtract(self)
  end

  def *(other : Units::AlgebraicUnit)
    other.left_multiply(self)
  end

  def /(other : Units::AlgebraicUnit)
    other.inverse.left_multiply(self)
  end

  {% begin %}
    {% for entry in Units::Registry::ALL %}
      {% for name in entry[:names] %}
        def as_{{ name.id }}
          CompileTimeUnit.from_{{ name.id }}(self)
        end
      {% end %}
    {% end %}
  {% end %}
end
