# encoding: utf-8
require 'spec_helper'

describe String do

  describe "spin" do
    it "should be defined" do
      String.new.respond_to?(:spin).should be_true
    end
    it "should call the spin function of ContentSpinning module with the string in argument" do
      ContentSpinning.should_receive(:spin).with("AaBb")
      "AaBb".spin
    end
  end

end

describe ContentSpinning do

  describe "clean" do
    it "should return the string if there is no spin" do
      ContentSpinning.clean("AaBb").should eq "AaBb"
    end

    it "should strip empty spin" do
      ContentSpinning.clean("a{}").should eq "a"
      ContentSpinning.clean("a{|}").should eq "a"
      ContentSpinning.clean("a{||}").should eq "a"
      ContentSpinning.clean("{}a{}").should eq "a"
      ContentSpinning.clean("{}a{|}").should eq "a"

      ContentSpinning.clean("a{{}}").should eq "a"
      ContentSpinning.clean("a{{|}}").should eq "a"
      ContentSpinning.clean("a{{}|}").should eq "a"

      ContentSpinning.clean("a{a{}}").should eq "aa"
    end

    it "should remove spin with no choice" do
      ContentSpinning.clean("{a}").should eq "a"
      ContentSpinning.clean("a{b}").should eq "ab"
      ContentSpinning.clean("a{b}c").should eq "abc"
      ContentSpinning.clean("a{b}c{d}e").should eq "abcde"

      ContentSpinning.clean("{{a}}").should eq "a"
      ContentSpinning.clean("a{{b}}").should eq "ab"
      ContentSpinning.clean("a{{b}}c").should eq "abc"
      ContentSpinning.clean("a{{b}}c{{d}}e").should eq "abcde"

      ContentSpinning.clean("{{{a}}}").should eq "a"
    end

    it "should keep legitimate spin" do
      ContentSpinning.clean("{a|b}").should eq "{a|b}"
      ContentSpinning.clean("a{b|c}").should eq "a{b|c}"
      ContentSpinning.clean("{{a|b}|c}").should eq "{{a|b}|c}"
    end
  end

  describe "parse" do
    it "should return the string if there is no spin" do
      ContentSpinning.parse("AaBb").should eq :max_level => 0, :parsed => "AaBb"
    end

    it "should parse simple spin" do
      ContentSpinning.parse("{a|b}").should eq :max_level => 1, :parsed => "__SPIN_BEGIN_1__a__SPIN_OR_1__b__SPIN_END_1__"
      ContentSpinning.parse("a{b|c}").should eq :max_level => 1, :parsed => "a__SPIN_BEGIN_1__b__SPIN_OR_1__c__SPIN_END_1__"
      ContentSpinning.parse("{a|b}c{d|e}").should eq :max_level => 1, :parsed => "__SPIN_BEGIN_1__a__SPIN_OR_1__b__SPIN_END_1__c__SPIN_BEGIN_1__d__SPIN_OR_1__e__SPIN_END_1__"
    end

    it "should manage recursive spin" do
      ContentSpinning.parse("{{a|b}|c}").should eq :max_level => 2, :parsed => "__SPIN_BEGIN_2____SPIN_BEGIN_1__a__SPIN_OR_1__b__SPIN_END_1____SPIN_OR_2__c__SPIN_END_2__"
      ContentSpinning.parse("{a|{b|c}}").should eq :max_level => 2, :parsed => "__SPIN_BEGIN_2__a__SPIN_OR_2____SPIN_BEGIN_1__b__SPIN_OR_1__c__SPIN_END_1____SPIN_END_2__"
    end
  end

  describe "spin" do
    it "should call the clean function of ContentSpinning module with the string in argument" do
      ContentSpinning.should_receive(:clean).with("AaBb").and_return("AaBb")
      ContentSpinning.spin("AaBb")
    end

    it "should return an array" do
      "AaBb".spin.should eq ["AaBb"]
    end

    it "should return an empty array if the string to spin is empty" do
      "".spin.should eq []
    end

    it "should strip empty choices" do
      "a{}".spin.should eq ["a"]
      "a{|}".spin.should eq ["a"]
      "a{||}".spin.should eq ["a"]
      "{}a{}".spin.should eq ["a"]
      "{}a{|}".spin.should eq ["a"]
    end

    it "should strip empty strings from the returned array" do
      "{|a}".spin.should eq ["a"]
      "{a|}".spin.should eq ["a"]
    end

    it "should manage one spin" do
      "{a}".spin.should eq ["a"]
      "a{b}".spin.should eq ["ab"]
      "a{b}c".spin.should eq ["abc"]
      "{a}{b}".spin.should eq ["ab"]
      "a{b}{c}d".spin.should eq ["abcd"]
    end

    it "should manage two spin" do
      "{a}".spin.should eq ["a"]
      "a{b}".spin.should eq ["ab"]
      "a{b}c".spin.should eq ["abc"]
      "{a}{b}".spin.should eq ["ab"]
      "a{b}{c}d".spin.should eq ["abcd"]
    end

    it "should manage spin with an empty choice" do
      "{|a}".spin.should eq ["a"]
      "{|a}b".spin.should eq ["b", "ab"]
      "{a|}b".spin.should eq ["ab", "b"]
      "{a|}{b|}".spin.should eq ["ab", "a", "b"]
      "a{b|}{c|}d".spin.should eq ["abcd", "abd", "acd", "ad"]
    end

    it "should manage spin with two choice" do
      "{a|b}".spin.should eq ["a", "b"]
      "{a|b}c".spin.should eq ["ac", "bc"]
      "{a|b}{c|d}".spin.should eq ["ac", "ad", "bc", "bd"]
    end

    it "should manage spin with three choice" do
      "{a|b|c}".spin.should eq ["a", "b", "c"]
      "{a|b|c}d".spin.should eq ["ad", "bd", "cd"]
      "{a|b|c}{d|e}".spin.should eq ["ad", "ae", "bd", "be", "cd", "ce"]
    end

    it "should manage recursive spin" do
      "{a{b|c}|d}".spin.should eq ["ab", "ac", "d"]
      "{{a|b}|c}".spin.should eq ["a", "b", "c"]
      "{a|{b|c}}".spin.should eq ["a", "b", "c"]
    end

    it "should not return twice the same result" do
      "{a|a}".spin.should eq ["a"]
    end
  end

end

