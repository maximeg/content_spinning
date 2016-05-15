require "spec_helper"

describe ContentSpinning do
  describe "#clean" do
    it "returns the string if there is no spin" do
      expect(ContentSpinning.clean("AaBb")).to eq("AaBb")
    end

    it "strips empty spin" do
      expect(ContentSpinning.clean("a{}")).to eq("a")
      expect(ContentSpinning.clean("a{|}")).to eq("a")
      expect(ContentSpinning.clean("a{||}")).to eq("a")
      expect(ContentSpinning.clean("{}a{}")).to eq("a")
      expect(ContentSpinning.clean("{}a{|}")).to eq("a")

      expect(ContentSpinning.clean("a{{}}")).to eq("a")
      expect(ContentSpinning.clean("a{{|}}")).to eq("a")
      expect(ContentSpinning.clean("a{{}|}")).to eq("a")

      expect(ContentSpinning.clean("a{a{}}")).to eq("aa")
    end

    it "remove spin with no choice" do
      expect(ContentSpinning.clean("{a}")).to eq("a")
      expect(ContentSpinning.clean("a{b}")).to eq("ab")
      expect(ContentSpinning.clean("a{b}c")).to eq("abc")
      expect(ContentSpinning.clean("a{b}c{d}e")).to eq("abcde")

      expect(ContentSpinning.clean("{{a}}")).to eq("a")
      expect(ContentSpinning.clean("a{{b}}")).to eq("ab")
      expect(ContentSpinning.clean("a{{b}}c")).to eq("abc")
      expect(ContentSpinning.clean("a{{b}}c{{d}}e")).to eq("abcde")

      expect(ContentSpinning.clean("{{{a}}}")).to eq("a")
    end

    it "keep legitimate spin" do
      expect(ContentSpinning.clean("{a|b}")).to eq("{a|b}")
      expect(ContentSpinning.clean("a{b|c}")).to eq("a{b|c}")
      expect(ContentSpinning.clean("a{b|}")).to eq("a{b|}")
      expect(ContentSpinning.clean("{{a|b}|c}")).to eq("{{a|b}|c}")
    end
  end

  describe "#parse" do
    it "returns the string if there is no spin" do
      expect(ContentSpinning.parse("AaBb")).to eq(max_level: 0, parsed: "AaBb")
    end

    it "parses simple spin" do
      expect(ContentSpinning.parse("{a|b}")).to eq(max_level: 1, parsed: "__SPIN_BEGIN_1__a__SPIN_OR_1__b__SPIN_END_1__")
      expect(ContentSpinning.parse("a{b|c}")).to eq(max_level: 1, parsed: "a__SPIN_BEGIN_1__b__SPIN_OR_1__c__SPIN_END_1__")
      expect(ContentSpinning.parse("{a|b}c{d|e}")).to eq(max_level: 1, parsed: "__SPIN_BEGIN_1__a__SPIN_OR_1__b__SPIN_END_1__c__SPIN_BEGIN_1__d__SPIN_OR_1__e__SPIN_END_1__")
    end

    it "manages recursive spin" do
      expect(ContentSpinning.parse("{{a|b}|c}")).to eq(max_level: 2, parsed: "__SPIN_BEGIN_2____SPIN_BEGIN_1__a__SPIN_OR_1__b__SPIN_END_1____SPIN_OR_2__c__SPIN_END_2__")
      expect(ContentSpinning.parse("{a|{b|c}}")).to eq(max_level: 2, parsed: "__SPIN_BEGIN_2__a__SPIN_OR_2____SPIN_BEGIN_1__b__SPIN_OR_1__c__SPIN_END_1____SPIN_END_2__")
    end
  end

  describe "#spin" do
    it "calls the clean function of ContentSpinning module with the string in argument" do
      expect(ContentSpinning).to receive(:clean).with("AaBb").and_return("AaBb")
      ContentSpinning.spin("AaBb")
    end

    it "returns an array" do
      expect(ContentSpinning.spin("AaBb")).to eq(["AaBb"])
    end

    it "returns an empty array if the string to spin is empty" do
      expect(ContentSpinning.spin("")).to eq([])
    end

    it "strips empty choices" do
      expect(ContentSpinning.spin("a{}")).to eq(["a"])
      expect(ContentSpinning.spin("a{|}")).to eq(["a"])
      expect(ContentSpinning.spin("a{||}")).to eq(["a"])
      expect(ContentSpinning.spin("{}a{}")).to eq(["a"])
      expect(ContentSpinning.spin("{}a{|}")).to eq(["a"])
    end

    it "strips empty strings from the returned array" do
      expect(ContentSpinning.spin("{|a}")).to eq(["a"])
      expect(ContentSpinning.spin("{a|}")).to eq(["a"])
    end

    it "manages one spin" do
      expect(ContentSpinning.spin("{a}")).to eq(["a"])
      expect(ContentSpinning.spin("a{b}")).to eq(["ab"])
      expect(ContentSpinning.spin("a{b}c")).to eq(["abc"])
    end

    it "manages two spin" do
      expect(ContentSpinning.spin("{a}{b}")).to eq(["ab"])
      expect(ContentSpinning.spin("a{b}{c}d")).to eq(["abcd"])
    end

    it "manages spin with an empty choices" do
      expect(ContentSpinning.spin("{|a}")).to eq(["a"])
      expect(ContentSpinning.spin("{|a}b")).to eq(%w(b ab))
      expect(ContentSpinning.spin("{a|}b")).to eq(%w(ab b))
      expect(ContentSpinning.spin("{a|}{b|}")).to eq(%w(ab a b))
      expect(ContentSpinning.spin("a{b|}{c|}d")).to eq(%w(abcd abd acd ad))
    end

    it "manages spin with two choices" do
      expect(ContentSpinning.spin("{a|b}")).to eq(%w(a b))
      expect(ContentSpinning.spin("{a|b}c")).to eq(%w(ac bc))
      expect(ContentSpinning.spin("{a|b}{c|d}")).to eq(%w(ac ad bc bd))
      expect(ContentSpinning.spin("{a|b}c{d|e}")).to eq(%w(acd ace bcd bce))
    end

    it "manages spin with three choices" do
      expect(ContentSpinning.spin("{a|b|c}")).to eq(%w(a b c))
      expect(ContentSpinning.spin("{a|b|c}d")).to eq(%w(ad bd cd))
      expect(ContentSpinning.spin("{a|b|c}{d|e}")).to eq(%w(ad ae bd be cd ce))
    end

    it "manages recursive spin" do
      expect(ContentSpinning.spin("{a{b|c}|d}")).to eq(%w(ab ac d))
      expect(ContentSpinning.spin("{{a|b}|c}")).to eq(%w(a b c))
      expect(ContentSpinning.spin("{a|{b|c}}")).to eq(%w(a b c))
      expect(ContentSpinning.spin("{a|{b|c}}{d|e}")).to eq(%w(ad ae bd be cd ce))
    end

    it "manages recursive spin with empty choices" do
      expect(ContentSpinning.spin("{a|{b|{c|{d|e}}}}")).to eq(%w(a b c d e))
    end

    it "does not return twice the same result" do
      expect(ContentSpinning.spin("{a|a}")).to eq(["a"])
    end

    it "does not modify the source string" do
      source = "{a|b}"
      expect {
        ContentSpinning.spin(source)
      }.not_to change { source }
    end
  end
end
