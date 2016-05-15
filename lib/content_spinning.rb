require "content_spinning/core_ext/string"

module ContentSpinning

  SPIN_BEGIN_FOR_LEVEL = Hash.new { |h, level| h[level] = "__SPIN_BEGIN_#{level}__" }
  SPIN_END_FOR_LEVEL = Hash.new { |h, level| h[level] = "__SPIN_END_#{level}__" }
  SPIN_OR_FOR_LEVEL = Hash.new { |h, level| h[level] = "__SPIN_OR_#{level}__" }

  PARTITIONNER_REGEXP_FOR_LEVEL = Hash.new do |h, level|
    h[level] = /#{SPIN_BEGIN_FOR_LEVEL[level]}.+?#{SPIN_END_FOR_LEVEL[level]}/
  end

  class << self

    def spin(text)
      result = parse(clean(text))

      contents = if result[:max_level] == 0
        [result[:parsed]]
      else
        spin_a_level([result[:parsed]], level: result[:max_level])
      end

      contents.reject!(&:empty?)
      contents.uniq!

      contents
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
          match.sub!("{", SPIN_BEGIN_FOR_LEVEL[level])
          match.sub!("}", SPIN_END_FOR_LEVEL[level])
          match.gsub!("|", SPIN_OR_FOR_LEVEL[level])
        end

        break unless modification_happened
      end

      { parsed: parsed, max_level: level - 1 }
    end

    def spin_a_level(contents, level:)
      contents.flat_map do |text|
        parts = extract_parts(text, level: level)

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

    private

    def extract_parts(text, level:)
      parts = []

      loop do
        before, spin, after = text.partition(PARTITIONNER_REGEXP_FOR_LEVEL[level])

        # Before
        parts << [before] if before != ""

        break if spin == ""

        # Let's vary
        spin.sub!(SPIN_BEGIN_FOR_LEVEL[level], "")
        spin.sub!(SPIN_END_FOR_LEVEL[level], "")
        parts << spin.split(SPIN_OR_FOR_LEVEL[level], -1)

        # After
        text = after
      end

      parts
    end

  end

end
