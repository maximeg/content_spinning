# frozen_string_literal: true
class String

  def spin(limit: nil)
    ContentSpinning.spin(self, limit: limit)
  end

end
