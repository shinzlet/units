require "./registry"

module Units::Building
  abstract def from_kilograms(value)
  abstract def from_meters(value)
  abstract def from_candela(value)
  abstract def from_kelvin(value)
  abstract def from_amperes(value)
  abstract def from_moles(value)
  abstract def from_seconds(value)
  abstract def from(value, measure : self)

  private macro populate_from(registry, reciever)
    \{% begin %}
      \{% for entry in {{registry}} %}
        \{% value = entry[:value] %}
        \{% for name in entry[:names] %}
          def from_\{{ name.id }}(value) : self
            {{ reciever.id }}(value * (\{{ value }}))
          end
        \{% end %}
      \{% end %}
    \{% end %}
  end

  populate_from(Registry::DERIVED_LENGTHS, :from_meters)
  populate_from(Registry::DERIVED_DURATIONS, :from_seconds)
end
