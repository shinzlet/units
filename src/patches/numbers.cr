require "../runtime_unit"

abstract struct Number
  def +(other : Units::RuntimeUnit)
    other + self
  end

  def -(other : Units::RuntimeUnit)
    -other + self
  end

  def *(other : Units::RuntimeUnit)
    other * self
  end

  def /(other : Units::RuntimeUnit)
    other.invert * self
  end
end

{% begin %}
{% end %}
