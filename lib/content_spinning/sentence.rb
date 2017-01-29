class ContentSpinning

  class Sentence < ::Array

    def initialize(*items)
      push(*items)
    end

    def cleaned
      map!(&:cleaned)

      case length
      when 0
        ::ContentSpinning::String.new("")
      when 1
        first
      else
        self
      end
    end

    def count
      case length
      when 0
        1
      else
        map(&:count).inject(:*)
      end
    end

    def inspect
      "<Sentence [#{map(&:inspect).join(", ")}]>"
    end

    def random
      map(&:random).join
    end

    def spin
      spinned = map(&:spin)

      case spinned.length
      when 1
        spinned[0]
      else
        spinned[0].product(*spinned[1..-1]).tap do |products|
          products.map!(&:join)
        end
      end
    end

    def to_source
      map(&:to_source).join
    end

  end

end
