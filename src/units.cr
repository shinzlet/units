require "./runtime_unit"
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
        def from_{{ name.id }}(value) : self
          RuntimeUnit.from_{{ name.id }}(value)
        end
      {% end %}
    {% end %}
  {% end %}
end
