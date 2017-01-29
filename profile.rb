require "bundler"
Bundler.setup

require "content_spinning"
require "ruby-prof"

n = 100
spins = 5

# source = "{a|b|{c|d|{e|f}}}" * spins
source = "{{a|b}|{c|d|{e|f}|g}|h}" * spins

RubyProf.start

n.times do |i|
  result = ContentSpinning.spin(source, limit: ENV["LIMIT"])
  puts(result.length) if i == 0
  puts(result.uniq.length) if i == 0
end

result = RubyProf.stop
result.eliminate_methods!([/Integer#times/])

# print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
