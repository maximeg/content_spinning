require "content_spinning/core_ext/string"

module ContentSpinning

  class << self

    def spin(text)
      result = parse(clean(text))

      content_array = if result[:max_level] == 0
        [result[:parsed]]
      else
        spin_a_level([result[:parsed]], level: result[:max_level])
      end

      content_array.reject!(&:empty?)
      content_array.uniq!

      content_array
    end

    EMPTY_SPIN_REGEXP = /\{\|*\}/
    ONE_CHOICE_SPIN_REGEXP = /\{([^\{\}\|]+)\}/

    def clean(text)
      cleaned = text.dup

      loop do
        text_before_run = cleaned.dup

        # Strip empty spin
        cleaned.gsub!(EMPTY_SPIN_REGEXP, "")

        # Remove spin with only one choice
        cleaned.gsub!(ONE_CHOICE_SPIN_REGEXP, '\1')

        break if cleaned == text_before_run
      end

      cleaned
    end

    INNER_SPIN_REGEXP = /\{([^\{\}]+)\}/

    def parse(text)
      parsed = text.dup

      level = 0
      loop do
        level += 1

        modification_happened = parsed.gsub!(INNER_SPIN_REGEXP) do |match|
          match.sub!("{", "__SPIN_BEGIN_#{level}__")
          match.sub!("}", "__SPIN_END_#{level}__")
          match.gsub!("|", "__SPIN_OR_#{level}__")
        end

        break unless modification_happened
      end

      { parsed: parsed, max_level: level - 1 }
    end

    PARTITIONNER_REGEXP_FOR_LEVEL = Hash.new { |h, level| h[level] = /__SPIN_BEGIN_#{level}__.+?__SPIN_END_#{level}__/ }

    def spin_a_level(contents, level:)
      spin_begin = "__SPIN_BEGIN_#{level}__"
      spin_end = "__SPIN_END_#{level}__"
      spin_or = "__SPIN_OR_#{level}__"

      contents.flat_map do |text|
        parts = []

        loop do
          before, spin, after = text.partition(PARTITIONNER_REGEXP_FOR_LEVEL[level])

          # Before
          if before != ""
            parts << [before]
          end

          break if spin == ""

          # Let's vary
          spin.sub!(spin_begin, "")
          spin.sub!(spin_end, "")
          parts << spin.split(spin_or, -1)

          # After
          text = after
        end

        parts.map! do |part|
          spin_a_level(part, level: level - 1)
        end if level >= 2

        if parts.length > 1
          parts[0].product(*parts[1..-1]).tap do |products|
            products.map!(&:join)
          end
        else
          parts[0]
        end
      end
    end

  end

end
