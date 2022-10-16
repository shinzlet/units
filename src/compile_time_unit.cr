module Units
  private LENGTH   = {0, 1, 0, 0, 0, 0, 0}
  private PREFIXES = [
    {1e-24, "yocto", "y"},
    {1e-21, "zepto", "z"},
    {1e-18, "atto", "a"},
    {1e-15, "femto", "f"},
    {1e-12, "pico", "p"},
    {1e-09, "nano", "n"},
    {1e-06, "micro", "u"},
    {1e-03, "milli", "m"},
    {1e-02, "centi", "c"},
    {1e-01, "deci", "d"},
    {1e+01, "deca", "da"},
    {1e+02, "hecto", "h"},
    {1e+03, "kilo", "k"},
    {1e+06, "mega", "M"},
    {1e+09, "giga", "G"},
    {1e+12, "tera", "T"},
    {1e+15, "peta", "P"},
    {1e+18, "exa", "E"},
    {1e+21, "zetta", "Z"},
    {1e+24, "yotta", "Y"},
  ]
  private TOLERANCE_SQUARED = 0.1

  struct Wrap(T)
  end

  # Seconds, kg, mol, cd, K, A, m
  # time (T), length (L), mass (M), electric current (I), absolute temperature (Θ), amount of substance (N) and luminous intensity (J).
  # Use O for temperature
  struct Unit(X, M, L, J, O, I, N, T)
    protected getter value : X

    protected def initialize(@value : X)
    end

    # Each SI base unit has a handwritten constructor - others are derived
    def self.from_kilograms(x : X) forall X
      Unit(X, 1, 0, 0, 1, 0, 0, 0).new(x)
    end

    def self.from_meters(x : X) forall X
      Unit(X, 0, 1, 0, 0, 0, 0, 0).new(x)
    end

    def self.from_candela(x : X) forall X
      Unit(X, 0, 0, 1, 0, 0, 0, 0).new(x)
    end

    def self.from_kelvin(x : X) forall X
      Unit(X, 0, 0, 0, 1, 0, 0, 0).new(x)
    end

    def self.from_amperes(x : X) forall X
      Unit(X, 0, 0, 0, 0, 1, 0, 0).new(x)
    end

    def self.from_moles(x : X) forall X
      Unit(X, 0, 0, 0, 0, 0, 1, 0).new(x)
    end

    def self.from_seconds(x : X) forall X
      Unit(X, 0, 0, 0, 0, 0, 0, 1).new(x)
    end

    macro make_registry_macro(name, si_base)
			macro {{name.id}}(coeff, *aliases)
				\{% for unit_name in aliases %}
					def self.from_\{{unit_name.id}}(x)
						from_{{si_base.id}}(x * \{{coeff}})
					end

					def to_\{{unit_name.id}}
						@value / \{{coeff}}
					end
				\{% end %}
			end
		end

    make_registry_macro(:define_mass, :kilograms)
    make_registry_macro(:define_length, :meters)
    make_registry_macro(:define_luminous_intensity, :candela)
    make_registry_macro(:define_absolute_temperature, :kelvin)
    make_registry_macro(:define_current, :amperes)
    make_registry_macro(:define_time, :seconds)

    macro define_si_series(si_name, si_short_name)
			{% begin %}
				{% for p in PREFIXES %}
					{% coeff, prefix, short_prefix = p %}
					def self.from_{{prefix.id}}{{si_name.id}}(x)
						from_{{si_name.id}}(x * {{coeff}})
					end

					def to_{{prefix.id}}{{si_name.id}}
						@value / {{coeff}}
					end

					def self.from_{{short_prefix.id}}{{si_short_name.id}}(x)
						from_{{si_name.id}}(x * {{coeff}})
					end

					def to_{{short_prefix.id}}{{si_short_name.id}}
						@value / {{coeff}}
					end
				{% end %}
			{% end %}
		end

    define_length(0.3048, :feet, :ft)
    define_length(0.9144, :yards, :yd)
    define_length(0.0254, :inches, :in)
    define_si_series(:meters, :m)

    define_time(60, :minutes, :min)

    class UnitConsts
      def feet
        Unit.from_feet(1)
      end

      def seconds
        Unit.from_seconds(1)
      end

      def minutes
        Unit.from_minutes(1)
      end

      def yards
        Unit.from_yards(1)
      end
    end

    def to(&block : UnitConsts -> self) : X
      converter = yield UnitConsts.new
      @value / converter.value
    end

    def self.from(value : X, &block : -> Unit(_, M, L, J, O, I, N, T)) forall X, M, L, J, O, I, N, T
      Unit(X, M, L, J, O, I, N, T).new(value)
    end

    def sqrt
      self ** Wrap(0.5)
    end

    def sq
      self ** Wrap(2)
    end

    def cbrt
      {% begin %}
			self ** Wrap({{1/3}})
			{% end %}
    end

    def cb
      self ** Wrap(3)
    end

    def **(exp : Wrap(Exp).class) forall Exp
      {% begin %}
			new_value = @value ** Exp
			Unit(
				typeof(new_value),
				{{M * Exp}},
				{{L * Exp}},
				{{J * Exp}},
				{{O * Exp}},
				{{I * Exp}},
				{{N * Exp}},
				{{T * Exp}}).new(new_value)
			{% end %}
    end

    def *(other : Unit(X2, M2, L2, J2, O2, I2, N2, T2)) forall X2, M2, L2, J2, O2, I2, N2, T2
      new_value = @value * other.value
      {% begin %}
			Unit(
				typeof(new_value),
				{{M + M2}},
				{{L + L2}},
				{{J + J2}},
				{{O + O2}},
				{{I + I2}},
				{{N + N2}},
				{{T + T2}}).new(new_value)
			{% end %}
    end

    def /(other : Unit(X2, M2, L2, J2, O2, I2, N2, T2)) forall X2, M2, L2, J2, O2, I2, N2, T2
      new_value = @value / other.value
      {% begin %}
			Unit(
				typeof(new_value),
				{{M - M2}},
				{{L - L2}},
				{{J - J2}},
				{{O - O2}},
				{{I - I2}},
				{{N - N2}},
				{{T - T2}}).new(new_value)
			{% end %}
    end

    def +(other : Unit(X2, M2, L2, J2, O2, I2, N2, T2)) forall X2, M2, L2, J2, O2, I2, N2, T2
      new_value = @value + other.@value
      {% begin %}
				{% if (M2 - M) ** 2 > TOLERANCE_SQUARED ||
            (L2 - L) ** 2 > TOLERANCE_SQUARED ||
            (J2 - J) ** 2 > TOLERANCE_SQUARED ||
            (O2 - O) ** 2 > TOLERANCE_SQUARED ||
            (I2 - I) ** 2 > TOLERANCE_SQUARED ||
            (N2 - N) ** 2 > TOLERANCE_SQUARED ||
            (T2 - T) ** 2 > TOLERANCE_SQUARED %}
					{% raise "bad" %}
				{% end %}
			{% end %}

      Unit(typeof(new_value), M, L, J, O, I, N, T).new(new_value)
    end

    def -(other : Unit(X2, M2, L2, J2, O2, I2, N2, T2)) forall X2, M2, L2, J2, O2, I2, N2, T2
      new_value = @value - other.@value
      {% begin %}
				{% if (M2 - M) ** 2 > TOLERANCE_SQUARED ||
            (L2 - L) ** 2 > TOLERANCE_SQUARED ||
            (J2 - J) ** 2 > TOLERANCE_SQUARED ||
            (O2 - O) ** 2 > TOLERANCE_SQUARED ||
            (I2 - I) ** 2 > TOLERANCE_SQUARED ||
            (N2 - N) ** 2 > TOLERANCE_SQUARED ||
            (T2 - T) ** 2 > TOLERANCE_SQUARED %}
					{% raise "bad" %}
				{% end %}
			{% end %}

      Unit(typeof(new_value), M, L, J, O, I, N, T).new(new_value)
    end
  end

  # macro def_assert(name, signature)
  # 	def assert_{{name.id}}!(u : Unit(_, M, L, J, O, I, N, T)) forall M, L, J, O, I, N, T
  # 		\{% begin %}
  # 			\{% if {M, L, J, O, I, N, T} != {{signature}} %}
  # 				\{% raise "bad" %}
  # 			\{% end %}
  # 		\{% end %}

  # 		# TODO: check at runtime for runtime units
  # 	end
  # end

  # def_assert("length", LENGTH)
end

include Units

# Shouldn't compile
# puts Length.new(2)
# puts foo(Unit(Int32, 0, 1, 0, 0, 0, 0, 0).new(3))
{% begin %}
  u1 = Unit.from_yards(1).cbrt
  # u2 = Unit.from_meters(1).cbrt.sq
  # u3 = u1 * u2
  # puts u3
  # puts u3 + Unit.from_meters(1)
  # puts u3 - Unit.from_meters(1)
{% end %}
# puts Unit.from_meters(2) ** Wrap(2)
# 3 ft^2 * (1yd/3ft)**2 = 3ft^2 / 9
