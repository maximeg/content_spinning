module ContentSpinning
  class << self

    def spin(text)
      result = parse(text)
      spin_all_level(result[:parsed], result[:max_level])
    end

    def parse(text, level = 1)
      return {:parsed => text, :max_level => level - 1} unless text.include? "{"

      text.gsub!(/\{\}/, '')
      text.gsub!(/\{([^\{\}\|]+)\}/, '\1')

      text.gsub!(/\{([^\{\}]+)\}/) do |match|
        match.gsub!(/\{/, "__SPIN_BEGIN_" + level.to_s + "__")
        match.gsub!(/\}/, "__SPIN_END_" + level.to_s + "__")
        match.gsub!(/\|/, "__SPIN_OR_" + level.to_s + "__")
      end

      parse(text, level+1)
    end

    def spin_a_level(text_or_array, level)
      text_or_array = [text_or_array] unless text_or_array.is_a? Array

      spin_begin = '__SPIN_BEGIN_' + level.to_s + '__'
      spin_end = '__SPIN_END_' + level.to_s + '__'
      spin_or = '__SPIN_OR_' + level.to_s + '__'

      text_or_array.map! do |text|
        return [text] unless text.include? spin_begin

        deb, vary, fin = text.partition(Regexp.new(spin_begin + '.+?' + spin_end))

        vary.gsub!(Regexp.union(spin_begin, spin_end), '')
        varies = vary.split(Regexp.new(spin_or))

        varies.map! do |vary|
          spin_a_level([deb + vary + fin], level)
        end

        varies
      end

      text_or_array.flatten
    end

    def spin_all_level(text_or_array, from_level)
      text_or_array = [text_or_array] unless text_or_array.is_a? Array
      return text_or_array if from_level == 0

      (1..from_level).reverse_each do |level|
        text_or_array = spin_a_level(text_or_array, level)
      end

      text_or_array
    end

  end
end

String.class_eval do
  def spin
    ContentSpinning.spin(self)
  end
end

