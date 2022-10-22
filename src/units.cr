require "./runtime_unit"
require "./compile_time_unit"
require "./library"
require "./patches/*"

module Units
  VERSION = "0.1.0"

  def self.new
    with Library yield
  end

  def self.from(value, measure)
    RuntimeUnit.from(value, measure)
  end

  {% begin %}
    {% for entry in Units::Registry::ALL %}
      {% for name in entry[:names] %}
        def self.from_{{ name.id }}(value)
          RuntimeUnit.from_{{ name.id }}(value)
        end
      {% end %}
    {% end %}
  {% end %}
end
