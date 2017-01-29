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
      case part
      when SPIN_START
        modify_heap_for_spin_start(heap)
      when SPIN_OR
        modify_heap_for_spin_or(heap)
      when SPIN_END
        modify_heap_for_spin_end(heap)
      else
        heap.last << ::ContentSpinning::String.new(part)
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

  private

  def modify_heap_for_spin_end(heap)
    heap.pop(2)
  end

  def modify_heap_for_spin_or(heap)
    heap.pop
    current_spinner = heap.last

    new_sentence = ::ContentSpinning::Sentence.new
    current_spinner << new_sentence
    heap << new_sentence
  end

  def modify_heap_for_spin_start(heap)
    current = heap.last

    new_spinner = ::ContentSpinning::Spinner.new
    current << new_spinner
    heap << new_spinner

    new_sentence = ::ContentSpinning::Sentence.new
    new_spinner << new_sentence
    heap << new_sentence
  end

end
