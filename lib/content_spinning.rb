require "content_spinning/core_ext/string"

module ContentSpinning

  class << self

    def spin(text)
      text = text.dup
      text = clean(text)
      result = parse(text)

      spin_all_level(result[:parsed], result[:max_level])
    end

    EMPTY_SPIN_REGEXP = /\{\|*\}/
    ONE_CHOICE_SPIN_REGEXP = /\{([^\{\}\|]+)\}/

    def clean(text)
      loop do
        text_before_run = text.dup

        # Strip empty spin
        text.gsub!(EMPTY_SPIN_REGEXP, "")

        # Remove spin with only one choice
        text.gsub!(ONE_CHOICE_SPIN_REGEXP, '\1')

        break if text == text_before_run
      end

      text
    end

    INNER_SPIN_REGEXP = /\{([^\{\}]+)\}/

    def parse(text, level = 1)
      return { parsed: text, max_level: level - 1 } unless text.include?("{")

      text.gsub!(INNER_SPIN_REGEXP) do |match|
        match.gsub!("{", "__SPIN_BEGIN_#{level}__")
        match.gsub!("}", "__SPIN_END_#{level}__")
        match.gsub!("|", "__SPIN_OR_#{level}__")
      end

      parse(text, level + 1)
    end

    PARTITIONNER_REGEXP_FOR_LEVEL = Hash.new { |h, level| h[level] = /__SPIN_BEGIN_#{level}__.+?__SPIN_END_#{level}__/ }

    def spin_a_level(text_or_array, level)
      content_array = text_or_array.is_a?(Array) ? text_or_array : [text_or_array]

      spin_begin = "__SPIN_BEGIN_#{level}__"
      spin_end = "__SPIN_END_#{level}__"
      spin_or = "__SPIN_OR_#{level}__"

      content_array.map! do |text|
        if text.include?(spin_begin)
          # Spin a first one
          before, vary, after = text.partition(PARTITIONNER_REGEXP_FOR_LEVEL[level])
          vary.gsub!(spin_begin, "")
          vary.gsub!(spin_end, "")

          varies = vary.split(spin_or, -1)
          varies.map! { |choice| before + choice + after }

          # Continue spinning the level if there are other same level spin or just return
          if after.include?(spin_begin)
            spin_a_level(varies, level)
          else
            varies
          end
        else
          text
        end
      end

      content_array.flatten!

      content_array
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
