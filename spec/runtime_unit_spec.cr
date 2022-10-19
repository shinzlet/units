require "./spec_helper.cr"

describe RuntimeUnit do
  it "should" do
    RuntimeUnit.from_feet(3).to_yards.should be_close(1, 1e-10)
    puts(Units.new { 10 * meter / second }.to { yard / hour }.to_s)
  end
end
