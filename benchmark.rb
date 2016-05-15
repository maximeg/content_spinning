require "bundler"
Bundler.setup

require "benchmark"
require "content_spinning"

n = 500
spins = 5
Benchmark.bm(5) do |x|
  (1..spins).each do |spin|
    x.report("#{spin} spins:") do
      n.times do
        source = "{a|b|{c|d}}" * spin
        source.spin
      end
    end
  end
end
