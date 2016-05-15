require "bundler"
Bundler.setup

require "content_spinning"
require "ruby-prof"

n = 100
spins = 5

source = "{a|b|{c|d|{e|f}}}" * spins

RubyProf.start

n.times do |i|
  result = ContentSpinning.spin(source)
  puts(result.length) if i == 0
end

result = RubyProf.stop
result.eliminate_methods!([/Integer#times/])

# print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
