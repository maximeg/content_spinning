module ContentSpinning
  class << self

    def spin(text)
      text = clean(text)
      result = parse(text)

      spin_all_level(result[:parsed], result[:max_level])
    end

    def clean(text)
      begin
        text_before_run = text.clone

        # Strip empty spin
        text.gsub!(/\{\|*\}/, '')

        # Remove spin with only one choice
        text.gsub!(/\{([^\{\}\|]+)\}/, '\1')

      end while (text != text_before_run)

      text
    end

    def parse(text, level = 1)
      return {:parsed => text, :max_level => level - 1} unless text.include? "{"

      text.gsub!(/\{([^\{\}]+)\}/) do |match|
        match.gsub!(/\{/, "__SPIN_BEGIN_#{level}__")
        match.gsub!(/\}/, "__SPIN_END_#{level}__")
        match.gsub!(/\|/, "__SPIN_OR_#{level}__")
      end

      parse(text, level+1)
    end

    def spin_a_level(text_or_array, level)
      content_array = text_or_array.is_a?(Array) ? text_or_array : [text_or_array]

      spin_begin = "__SPIN_BEGIN_#{level}__"
      spin_end = "__SPIN_END_#{level}__"
      spin_or = "__SPIN_OR_#{level}__"

      content_array.map! do |text|
        if text.include? spin_begin
          # Spin a first one
          before, vary, after = text.partition(Regexp.new(spin_begin + '.+?' + spin_end))
          vary.gsub!(Regexp.union(spin_begin, spin_end), '')

          varies = vary.split(Regexp.new(spin_or), -1)
          varies.map! { |vary| before + vary + after }

          # Continue spinning the level if there are other same level spin or just return
          if after.include? spin_begin
            spin_a_level(varies, level).flatten
          else
            varies
          end
        else
          text
        end
      end

      content_array.flatten
    end

    def spin_all_level(text_or_array, from_level)
      content_array = text_or_array.is_a?(Array) ? text_or_array : [text_or_array]

      if from_level > 0
        (1..from_level).reverse_each do |level|
          content_array = spin_a_level(content_array, level)
        end
      end

      content_array.delete_if(&:empty?).uniq
    end

  end
end

String.class_eval do
  def spin
    ContentSpinning.spin(self)
  end
end

