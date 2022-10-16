module Units::LengthFactors
  extend self

  METER = 1_f64

  # As laid out in the International Yard and Pound Agreement of 1959
  YARD = FOOT * 3
  FOOT = INCH * 12
  INCH = 0.0254_f64
end
