require "./unit_error"

module Units::AlgebraicUnit(X)
  protected abstract def value : X
  abstract def dimension : Dimension

  # Multiplicative and additive inverses must be defined

  abstract def - : AlgebraicUnit
  abstract def inverse : AlgebraicUnit

  # Interaction with other dimensioned quantities

  abstract def +(other : AlgebraicUnit) : AlgebraicUnit
  abstract def -(other : AlgebraicUnit) : AlgebraicUnit
  abstract def *(other : AlgebraicUnit) : AlgebraicUnit
  abstract def /(other : AlgebraicUnit) : AlgebraicUnit

  # Interaction with scalars

  abstract def *(other) : AlgebraicUnit
  abstract def /(other) : AlgebraicUnit

  # Manipulation from the left (e.g. `5 + self` becomes `self.left_add(5)`)

  abstract def left_add(lhs)
  abstract def left_multiply(lhs)

  # Note: Adding to a scalar must produce a scalar

  def +(other)
    if dimension.scalar?
      value + other
    else
      raise UnitError.new(self.dimension, Dimension.new)
    end
  end
  
  def -(other)
    if dimension.scalar?
      value - other
    else
      raise UnitError.new(self.dimension, Dimension.new)
    end
  end

  def left_subtract(lhs)
    (-self).left_add(lhs)
  end

  # Note: left_divide is not a well defined concept, so the
  # user is left to compose #left_multiply and #inverse if they
  # want that behaviour e.g. `3 / self == (self.inverse).left_multiply(3)`
end
