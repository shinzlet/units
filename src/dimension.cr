require "./si_info"

module Units
  record Dimension,
    mass : Float32 = 0,
    length : Float32 = 0,
    luminant_intensity : Float32 = 0,
    temperature : Float32 = 0,
    current : Float32 = 0,
    amount : Float32 = 0,
    time : Float32 = 0

  struct Dimension
    {% begin %}
      {% for triple in SI_INFO %}
        {% name = triple[0] %}
        def self.{{name.id}}
          new({{name.id}}: 1)
        end
      {% end %}
    {% end %}

    def scalar?
      {% begin %}
        {{ SI_INFO.map { |name| name[0].id.stringify + " == 0"}.join(" && ").id }}
      {% end %}
    end

    def to_s(io : IO, scalar_message = "(scalar)")
      if scalar?
        io << scalar_message
        return
      end

      on_first = true
      {% begin %}
        {% for triple in SI_INFO %}
          exp = @{{triple[0].id}}
          if exp != 0
            if on_first
              on_first = false
            else
              io << '·'
            end

            if exp == 1
              io << {{triple[2].id.stringify}}
            else
              io << {{triple[2].id.stringify}}
              io << Formatting.format_exponent(exp)
            end
          end
        {% end %}
      {% end %}
    end

    def invert
      Dimension.new(
        -@mass,
        -@length,
        -@luminant_intensity,
        -@temperature,
        -@current,
        -@amount,
        -@time)
    end

    def +(other : self) : self
      Dimension.new(
        @mass + other.mass,
        @length + other.length,
        @luminant_intensity + other.luminant_intensity,
        @temperature + other.temperature,
        @current + other.current,
        @amount + other.amount,
        @time + other.time)
    end

    def -(other : self) : self
      Dimension.new(
        @mass - other.mass,
        @length - other.length,
        @luminant_intensity - other.luminant_intensity,
        @temperature - other.temperature,
        @current - other.current,
        @amount - other.amount,
        @time - other.time)
    end

    def *(value) : self
      Dimension.new(
        @mass * value,
        @length * value,
        @luminant_intensity * value,
        @temperature * value,
        @current * value,
        @amount * value,
        @time * value)
    end

    def /(value) : self
      Dimension.new(
        @mass / value,
        @length / value,
        @luminant_intensity / value,
        @temperature / value,
        @current / value,
        @amount / value,
        @time / value)
    end
  end
end
