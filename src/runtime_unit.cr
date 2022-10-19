require "./casting"
require "./building"
require "./dimension"
require "./formatting"
require "./si_info"
require "./unit_error"

module Units
  class RuntimeUnit(T)
    extend Building
    include Casting

    protected getter value : T
    getter dimension : Dimension

    protected def initialize(@value : T, @dimension : Dimension)
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

      RuntimeUnit.new(@value / measure.value, @dimension)
    end

    def invert : self
      RuntimeUnit.new(1 / @value, @dimension.invert)
    end

    def - : self
      RuntimeUnit.new(-@value, @dimension.invert)
    end

    def to_s(io : IO) : Nil
      io << @value
      io << " "
      io << @dimension
    end

    # Removes the unit wrapper or raises - you can't add a number to
    # any non-scalar quantity so if this returns it has to not be a unit
    # anymore
    def +(other)
      if @dimension.scalar?
        @value + other
      else
        raise UnitError.new(@dimension, Dimension.new)
      end
    end

    def -(other)
      if @dimension.scalar?
        @value - other
      else
        raise UnitError.new(@dimension, Dimension.new)
      end
    end
    
    def *(other)
      RuntimeUnit.new(@value * other, @dimension)
    end

    def /(other)
      RuntimeUnit.new(@value / other, @dimension)
    end

    def +(other : RuntimeUnit)
      if @dimension != other.dimension
        raise UnitError.new(self.dimension, other.dimension)
      end

      RuntimeUnit.new(@value + other.value, @dimension)
    end
    
    def -(other : RuntimeUnit)
      if @dimension != other.dimension
        raise UnitError.new(self.dimension, other.dimension)
      end

      RuntimeUnit.new(@value - other.value, @dimension)
    end

    def *(other : RuntimeUnit)
      RuntimeUnit.new(@value * other.value, @dimension + other.dimension)
    end

    def /(other : RuntimeUnit)
      RuntimeUnit.new(@value / other.value, @dimension - other.dimension)
    end
  end
end
