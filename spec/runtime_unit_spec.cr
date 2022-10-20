require "./spec_helper.cr"

describe RuntimeUnit do
  it "should" do
    RuntimeUnit.from_feet(3).to_yards.should be_close(1, 1e-10)
    puts(Units.new { 10 * meter / second }.to { yard / hour }.to_s)
    puts 1 / Units::Library.foot
    puts 1 - (Units::Library.foot / Units::Library.foot)
  end
end
