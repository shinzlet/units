require "./runtime_unit"
require "./registry"

module Units::Library
  {% begin %}
    {% for entry in Units::Registry::ALL %}
      def self.{{ entry[:singular].id }}
        RuntimeUnit.from_{{ entry[:names][0].id }}(1_f64)
      end
    {% end %}
  {% end %}
end