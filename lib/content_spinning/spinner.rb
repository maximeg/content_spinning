# frozen_string_literal: true
class ContentSpinning

  class Spinner < ::Array

    def initialize(*items)
      push(*items)
    end

    def cleaned
      map!(&:cleaned)

      uniq!

      if length == 1
        first
      else
        self
      end
    end

    def count
      map(&:count).inject(:+)
    end

    def inspect
      "<Spinner {#{map(&:inspect).join(" | ")}}>"
    end

    def random
      sample.random
    end

    def spin
      flat_map(&:spin)
    end

    def to_source
      "{#{map(&:to_source).join("|")}}"
    end

  end

end
