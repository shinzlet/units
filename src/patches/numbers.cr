require "../runtime_unit"

abstract struct Number
  def +(other : Units::RuntimeUnit)
    other.left_add(self)
  end

  def -(other : Units::RuntimeUnit)
    other.left_subtract(self)
  end

  def *(other : Units::RuntimeUnit)
    other.left_multiply(self)
  end

  def /(other : Units::RuntimeUnit)
    other.invert.left_multiply(self)
  end
end
