# units

A library for computing with physical quantities that enforces the rules of
dimensional analysis (at compile time whenever possible, with decay to runtime
checking for indeterminite units). For example, `Units.from_meters(2)
+ Units.from_seconds(3)` will not even compile:

```text
In src/compile_time_unit.cr:103:23

 103 | CompileTimeUnit.assert_same_units!(self, other)
                       ^-----------------
Error: Refusing to compile because `m` and `s` are not compatible units
```

For more details about the unit checking system, see [Automatic Unit Checking.](#automatic-unit-checking)

## Usage
- [Building and Casting Units](#building-and-casting-units)
- [Automatic Unit Checking.](#automatic-unit-checking)

### Building and Casting Units
```crystal
require "units"

# Units can be constructed with the `from_*` family, which support most
# quantites:
a_length = Units.from_yards(1)

# Under the hood, `units` stores everything in SI base units. So, printing
# your quantity will display the SI equivalent:
puts a_length # => 0.9144 m

# Every `from_` constructor has a complementary `to_` method. `from_` will
# wrap a value into a unit, whereas `to_` will scale the value by a conversion
# factor and unwrap it:
puts typeof(a_length.to_feet) # => Float64
puts a_length.to_feet # => 3
puts a_length.to_inches # => 36

# Common unit aliases are also supported:
puts a_length.to_ft # => 3
puts a_length.to_in # => 36

# More complex units can be constructed algebraically:
an_area = Units.build { 3 * meter ** 2 }
puts an_area # => 3.0 m²

# Casting can also be done with arbitrarily complex units:
puts an_area.to { foot ** 2 } # => 32.29173125012917
```

### Automatic Unit Checking
As mentioned in the introduction, `units` always ensures that your physical
calculations are dimensionally sound. In most cases, this can happen at compile
time:

```crystal
Units.build { foot * minute }.to_years
# => Error: Refusing to compile because `m s` and `s` are not compatible units
```

Compile time unit checking has two benefits:
- Your code won't unexpectedly crash due to unit incompatibility
- Units have no performance effect during runtime

Compile time unit checking is guaranteed as long as you stick to only using the
following methods on your `CompileTimeUnit`s:
- addition
- subtraction
- multiplication
- division
- construction
- casting

This covers most use cases, but exponentiation is left off of this list. The
reason why is that, in `a ** b`, the function `a#**(other)` recieves `b` as a
runtime parameter. This is also true of multiplication by a scalar, but scalar
multiplication does not modify units, whereas exponentiation does.

Of course, exponentiation still works just fine - but by default it will
decay to runtime units:

```crystal
a = Units.from_feet(2) # => CompileTimeUnit(Float64, ...)
a_sq = a ** 2 # => RuntimeUnit(Float64)
a + a_sq # => Units::UnitError will be raised at runtime :(
```

This can be worked around using a const generic wrapper:
```crystal
a = Units.from_feet(2) # => CompileTimeUnit(Float64, ...)
a_sq = a ** Units::Fix(2) # => RuntimeUnit(Float64)
a + a_sq # => Error: Refusing to compile because `m` and `m²` are not compatible units
```

Or, in specific (but very common) cases, by using named methods:
```crystal
# All of these are compile-time checked
# (floats are truncated for readability)
a = Units.from_feet(2)   # => 0.6096 m
a_sq = a.sq              # => 0.3716 m²
a_sqrt = a.sqrt          # => 0.7807 m⁰⋅⁵⁰
a_cb = a.cb              # => 0.2265 m³
a_cbrt = a.cbrt          # => 0.8479 m⁰⋅³³

a_inv_sq = a.inverse.sq  # => 2.6909 m⁻²
a_two_thirds = a.sq.cbrt # => 0.7189 m⁰⋅⁶⁷
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     units:
       github: shinzlet/units
   ```

2. Run `shards install`

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/shinzlet/units/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Seth Hinz](https://github.com/shinzlet) - creator and maintainer
