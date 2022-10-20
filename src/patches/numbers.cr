require "../algebraic_unit"

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
end
