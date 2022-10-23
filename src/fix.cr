# Non-constructable generic shim type
struct Units::Fix(N)
  private def initialize
  end

  private def self.allocate
  end
end
