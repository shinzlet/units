module Units::Registry
  # singular: The singular, common name of the unit (e.g. foot)
  # names: Names that are written next to arbitrary scalar quantities (e.g. ["feet", "ft"]); plural
  # value: The amount of an SI base unit that this unit is (e.g. 0.3048)
  alias UnitDefinition = NamedTuple(singular: String, names: Array(String), value: Float64)

  DERIVED_LENGTHS = [
    # As laid out in the International Yard and Pound Agreement of 1959
    {singular: "foot", names: ["feet", "ft"], value: 0.3048_f64},
    {singular: "yard", names: ["yards", "yd"], value: 0.9144_f64},
    {singular: "inch", names: ["inches", "in"], value: 0.0254_f64},
  ] of UnitDefinition

  DERIVED_DURATIONS = [
    # These use the conventional definitions (60s = 1min,, 60min = 1hr, 24hr = 1day)
    {singular: "minute", names: ["minutes", "min"], value: 60_f64},
    {singular: "hour", names: ["hours", "hr"], value: 3600_f64},
    {singular: "day", names: ["days"], value: 86400_f64},
    # Note that the month is skipped because there is not a standard month length!
    # This is the average siderial year (actual orbital duration)
    # https://hpiers.obspm.fr/eop-pc/models/constants.html
    {singular: "year", names: ["years", "yr"], value: 31558100_f64 }
  ] of UnitDefinition

  # These macro expressions ensure that all of this data is available at compile time!
  {% begin %}
    LENGTHS = {{ DERIVED_LENGTHS + [{singular: "meter", names: ["meters", "m"], value: 1_f64}] }}
    DURATIONS = {{ DERIVED_DURATIONS + [{singular: "second", names: ["seconds", "s"], value: 1_f64}] }}
  {% end %}

  {% begin %}
    ALL_DERIVED = {{ DERIVED_LENGTHS + DERIVED_DURATIONS }}
    ALL = {{ LENGTHS + DURATIONS }}
  {% end %}
end
