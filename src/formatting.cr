class Units::Formatting
  private SUPERSCRIPT_MAP_FROM =   "+-.0123456789E"
  private SUPERSCRIPT_MAP_TO = "⁺⁻⋅⁰¹²³⁴⁵⁶⁷⁸⁹ᴱ"
  class_property use_superscript = true

  private def self.to_readable_string(exponent) : String
    rounded = exponent.round
    if (exponent - rounded).abs < 1e-3
      # Because we use floats, we don't have the rational precision we'd
      # like for actual unit algebra. To make it a little less painful
      # on the eyes, we have a very high (0.001) tolerance on what we'll just
      # print as an integer:
      return rounded.to_i.to_s
    else
      if exponent.abs > 99
        # If the exponent is big (again, subjective preference),
        # print the whole thing - it's gonna look ugly no matter what,
        # and the user is clearly doing something weird.
        "%.4G" % exponent
      else
        # If the exponent is not near an integer, but not too large,
        # print a stomachable number of digits
        "%.2f" % exponent
      end
    end
  end

  def self.format_exponent(exponent) : String
    output = to_readable_string(exponent)

    if use_superscript
      output.tr(SUPERSCRIPT_MAP_FROM, SUPERSCRIPT_MAP_TO)
    else
      output
    end
  end
end
