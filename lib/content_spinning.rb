# frozen_string_literal: true
require "content_spinning/core_ext/string"
require "content_spinning/sentence"
require "content_spinning/spinner"
require "content_spinning/string"

class ContentSpinning

  class << self

    def spin(source, limit: nil)
      new(source).spin(limit: limit)
    end

  end

  def initialize(source)
    @source = source
  end

  attr_reader :source

  def count
    parse.count
  end

  SPIN_END = "}"
  SPIN_OR = "|"
  SPIN_START = "{"

  def parse
    return @root if defined?(@root)

    heap = [::ContentSpinning::Sentence.new]

    source.scan(/ [{}|] | [^{}|]+ /x).each do |part|
      current = heap.last

      if part == SPIN_START
        spinner = ::ContentSpinning::Spinner.new
        current << spinner
        heap << spinner

        sentence = ::ContentSpinning::Sentence.new
        spinner << sentence
        heap << sentence
      elsif part == SPIN_OR
        heap.pop
        spinner = heap.last
        sentence = ::ContentSpinning::Sentence.new
        spinner << sentence
        heap << sentence
      elsif part == SPIN_END
        heap.pop(2)
      else
        current << ::ContentSpinning::String.new(part)
      end
    end

    @root = heap.first.cleaned
  end

  def spin(limit: nil)
    if limit && limit < count
      spin_with_limit(limit: limit)
    else
      spin_all
    end
  end

  def spin_all
    parse.spin
  end

  def spin_with_limit(limit:)
    parsed = parse

    Array.new(limit) { parsed.random }
  end

  def to_source
    parse.to_source
  end

end
