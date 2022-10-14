# class UnitConsts
# 	def feet
# 		"hi"
# 	end
# end
# 
# def to(&block : -> String)
# 	converter = with UnitConsts.new yield
# end
# 
# a = to do
# 	feet
# end
# 
# puts a

class Other
  def one
    1
  end
end

class Foo
  def yield_with_other(&block)
		with Other.new yield
  end
end

puts Foo.new.yield_with_other { one } # => 1
