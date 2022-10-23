require "./casting"
require "./building"
require "./dimension"
require "./formatting"
require "./si_info"
require "./unit_error"
require "./algebraic_unit"

module Units
  struct RuntimeUnit(X)
    extend Building

    include AlgebraicUnit(X)
    include Casting

    protected getter value : X
    getter dimension : Dimension

    protected def initialize(@value : X, @dimension : Dimension)
    end

    {% begin %}
      {% for triple in SI_INFO %}
        def self.from_{{triple[1].id}}(value)
          new(value, Dimension.{{triple[0].id}})
        end

        def to_{{triple[1].id}}
          if @dimension == Dimension.{{triple[0].id}}
            @value
          else
            raise "Cannot cast quantity #{self} to a {{triple[0].gsub(/_/, " ").id}} - its units are incompatible"
          end
        end
      {% end %}
    {% end %}

    def self.from(value, measure : self)
      self.new(value * measure.value, measure.dimension)
    end

    def to(measure : self)
      if @dimension != measure.dimension
        raise UnitError.new(@dimension, measure.dimension)
      end

      @value / measure.value
    end

    def inverse : self
      RuntimeUnit.new(1 / @value, @dimension.inverse)
    end

    def - : self
      RuntimeUnit.new(-@value, @dimension)
    end

    def to_s(io : IO) : Nil
      io << @value
      io << " "
      io << @dimension
    end

    # other + self
    def left_add(lhs)
      if @dimension.scalar?
        lhs + @value
      else
        raise UnitError.new(@dimension, Dimension.new)
      end
    end

    def left_add(lhs : AlgebraicUnit) : AlgebraicUnit
      if @dimension != lhs.dimension
        raise UnitError.new(self.dimension, lhs.dimension)
      end

      RuntimeUnit.new(lhs.value + @value, @dimension)
    end

    # lhs * self
    def left_multiply(lhs)
      RuntimeUnit.new(lhs * @value, @dimension)
    end

    def left_multiply(lhs : AlgebraicUnit) : AlgebraicUnit
      RuntimeUnit.new(lhs.value * @value, @dimension + lhs.dimension)
    end

    def +(other : AlgebraicUnit) : AlgebraicUnit
      if @dimension != other.dimension
        raise UnitError.new(self.dimension, other.dimension)
      end

      RuntimeUnit.new(@value + other.value, @dimension)
    end
    
    def -(other : AlgebraicUnit) : AlgebraicUnit
      if @dimension != other.dimension
        raise UnitError.new(self.dimension, other.dimension)
      end

      RuntimeUnit.new(@value - other.value, @dimension)
    end

    def *(other : AlgebraicUnit) : AlgebraicUnit
      RuntimeUnit.new(@value * other.value, @dimension + other.dimension)
    end

    def /(other : AlgebraicUnit) : AlgebraicUnit
      RuntimeUnit.new(@value / other.value, @dimension - other.dimension)
    end

    def *(other) : AlgebraicUnit
      RuntimeUnit.new(@value * other, @dimension)
    end

    def /(other) : AlgebraicUnit
      RuntimeUnit.new(@value / other, @dimension)
    end
  end
end
