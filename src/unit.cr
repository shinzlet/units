module Units::Building
  abstract def from_meters(x)
  abstract def from_seconds(x)
  abstract def from(x, template : self)

  private macro make_registry_macro(name, si_base)
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

  private make_registry_macro(:define_mass, :kilograms)
  private make_registry_macro(:define_length, :meters)
  private make_registry_macro(:define_luminous_intensity, :candela)
  private make_registry_macro(:define_absolute_temperature, :kelvin)
  private make_registry_macro(:define_current, :amperes)
  private make_registry_macro(:define_time, :seconds)

  define_length(0.3048, :feet, :ft)
  define_length(0.9144, :yards, :yd)
  define_length(0.0254, :inches, :in)
end

module Units::Casting
  abstract def to_meters
  abstract def to_seconds
  abstract def to(template : self)
end

module Units::Unit

  # define_mass()
end

struct Test
  extend Units::Building
  include Units::Casting

  @value : Int32

  private def initialize(@value)
  end

  def self.from_meters(x)
    new(x)
  end

  def self.from_seconds(x)
    new(x)
  end

  def self.from(x, template : self)
  end

  def to_meters
  end

  def to_seconds
  end

  def to(template : self)
  end
end

Test.from_meters(1).to_meters
