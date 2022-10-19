require "./dimension"

class Units::UnitError < Exception
	def initialize(d1 : Dimension, d2 : Dimension)
		@message = "Operation failed because `#{d1}` and `#{d2}` are not compatible units"
	end
end
