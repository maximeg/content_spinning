require "bundler"
Bundler.setup

require "content_spinning"
require "ruby-prof"

n = 500
spins = 5

source = "{a|b|{c|d}}" * spins

RubyProf.start

n.times do
  source.spin
end

result = RubyProf.stop
result.eliminate_methods!([/Integer#times/])

# print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
