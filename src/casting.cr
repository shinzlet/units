require "./algebraic_unit"
require "./registry"

module Units::Casting
  abstract def to_kilograms
  abstract def to_meters
  abstract def to_candela
  abstract def to_kelvin
  abstract def to_amperes
  abstract def to_moles
  abstract def to_seconds
  abstract def to(measure : self)

  private macro populate_from(registry, reciever)
    \{% begin %}
      \{% for entry in {{registry}} %}
        \{% value = entry[:value] %}
        \{% for name in entry[:names] %}
          def to_\{{ name.id }}
            {{ reciever.id }} / (\{{ value }})
          end
        \{% end %}
      \{% end %}
    \{% end %}
  end

  populate_from(Registry::DERIVED_LENGTHS, :to_meters)
  populate_from(Registry::DERIVED_DURATIONS, :to_seconds)

  def to(&)
    to(with Library yield)
  end
end
