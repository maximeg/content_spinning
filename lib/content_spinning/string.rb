class ContentSpinning

  class String < ::String

    def initialize(text)
      self.<<(text)
    end

    def cleaned
      self
    end

    def count
      1
    end

    def inspect
      "<String {#{inspect}}>"
    end

    def random
      self
    end

    def spin
      [self]
    end

    def to_source
      self
    end

  end

end
