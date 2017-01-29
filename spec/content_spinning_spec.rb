require "spec_helper"

describe ContentSpinning do

  describe "#count" do
    it "returns an array" do
      expect(ContentSpinning.new("AaBb").count).to eq(1)
    end

    it "handles empty spin source" do
      expect(ContentSpinning.new("").count).to eq(1)
    end

    it "strips empty choices" do
      expect(ContentSpinning.new("a{}").count).to eq(1)
      expect(ContentSpinning.new("a{|}").count).to eq(1)
      expect(ContentSpinning.new("a{||}").count).to eq(1)
      expect(ContentSpinning.new("{}a{}").count).to eq(1)
      expect(ContentSpinning.new("{}a{|}").count).to eq(1)
    end

    it "keeps empty strings from the returned array" do
      expect(ContentSpinning.new("{|a}").count).to eq(2)
      expect(ContentSpinning.new("{a|}").count).to eq(2)
    end

    it "manages one spin" do
      expect(ContentSpinning.new("{a}").count).to eq(1)
      expect(ContentSpinning.new("a{b}").count).to eq(1)
      expect(ContentSpinning.new("a{b}c").count).to eq(1)
    end

    it "manages two spin" do
      expect(ContentSpinning.new("{a}{b}").count).to eq(1)
      expect(ContentSpinning.new("a{b}{c}d").count).to eq(1)
    end

    it "manages spin with an empty choices" do
      expect(ContentSpinning.new("{|a}").count).to eq(2)
      expect(ContentSpinning.new("{|a}b").count).to eq(2)
      expect(ContentSpinning.new("{a|}b").count).to eq(2)
      expect(ContentSpinning.new("{a|}{b|}").count).to eq(4)
      expect(ContentSpinning.new("a{b|}{c|}d").count).to eq(4)
    end

    it "manages spin with two choices" do
      expect(ContentSpinning.new("{a|b}").count).to eq(2)
      expect(ContentSpinning.new("{a|b}c").count).to eq(2)
      expect(ContentSpinning.new("{a|b}{c|d}").count).to eq(4)
      expect(ContentSpinning.new("{a|b}c{d|e}").count).to eq(4)
    end

    it "manages spin with three choices" do
      expect(ContentSpinning.new("{a|b|c}").count).to eq(3)
      expect(ContentSpinning.new("{a|b|c}d").count).to eq(3)
      expect(ContentSpinning.new("{a|b|c}{d|e}").count).to eq(6)
    end

    it "manages recursive spin" do
      expect(ContentSpinning.new("{a{b|c}|d}").count).to eq(3)
      expect(ContentSpinning.new("{{a|b}|c}").count).to eq(3)
      expect(ContentSpinning.new("{a|{b|c}}").count).to eq(3)
      expect(ContentSpinning.new("{a|{b|c}}{d|e}").count).to eq(6)
    end

    it "manages recursive spin with empty choices" do
      expect(ContentSpinning.new("{a|{b|{c|{d|e}}}}").count).to eq(5)
    end

    it "manages duplicate choices" do
      expect(ContentSpinning.new("{a|a}").count).to eq(1)
    end
  end

  describe "#parse" do
    it "returns the string if there is no spin" do
      expect(ContentSpinning.new("AaBb").parse).to eq("AaBb")
    end

    it "parses simple spin" do
      expect(ContentSpinning.new("{a|b}").parse).to eq(
        ContentSpinning::Spinner.new("a", "b")
      )
      expect(ContentSpinning.new("a{b|c}").parse).to eq(
        ContentSpinning::Sentence.new(
          "a",
          ContentSpinning::Spinner.new("b", "c")
        )
      )
      expect(ContentSpinning.new("{a|b}c{d|e}").parse).to eq(
        ContentSpinning::Sentence.new(
          ContentSpinning::Spinner.new("a", "b"),
          "c",
          ContentSpinning::Spinner.new("d", "e")
        )
      )
    end

    it "manages recursive spin" do
      expect(ContentSpinning.new("{{a|b}|c}").parse).to eq(
        ContentSpinning::Spinner.new(ContentSpinning::Spinner.new("a", "b"), "c")
      )
      expect(ContentSpinning.new("{a|{b|c}}").parse).to eq(
        ContentSpinning::Spinner.new("a", ContentSpinning::Spinner.new("b", "c"))
      )
    end
  end

  describe ".spin" do
    it "returns an array" do
      expect(ContentSpinning.spin("AaBb")).to eq(["AaBb"])
    end

    it "handles empty spin source" do
      expect(ContentSpinning.spin("")).to eq([""])
    end

    it "strips empty choices" do
      expect(ContentSpinning.spin("a{}")).to eq(["a"])
      expect(ContentSpinning.spin("a{|}")).to eq(["a"])
      expect(ContentSpinning.spin("a{||}")).to eq(["a"])
      expect(ContentSpinning.spin("{}a{}")).to eq(["a"])
      expect(ContentSpinning.spin("{}a{|}")).to eq(["a"])
    end

    it "keeps empty strings from the returned array" do
      expect(ContentSpinning.spin("{|a}")).to eq(["", "a"])
      expect(ContentSpinning.spin("{a|}")).to eq(["a", ""])
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
      expect(ContentSpinning.spin("{|a}")).to eq(["", "a"])
      expect(ContentSpinning.spin("{|a}b")).to eq(%w(b ab))
      expect(ContentSpinning.spin("{a|}b")).to eq(%w(ab b))
      expect(ContentSpinning.spin("{a|}{b|}")).to eq(%w(ab a b) + [""])
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

    context 'with limit' do
      before { @old_seed = Random.srand(2736) }
      after { Random.srand(@old_seed) }

      it "manages recursive spin with empty choices" do
        expect(ContentSpinning.spin("{a|{b|{c|{d|e}}}}_z", limit: 2)).to eq(%w(d_z a_z))
      end

      it "manages recursive spin" do
        expect(ContentSpinning.spin("{a|{b|c}}{d|e}_z", limit: 2)).to eq(%w(ce_z ad_z))
      end
    end
  end

  describe "#to_source" do
    it "returns the string if there is no spin" do
      expect(ContentSpinning.new("AaBb").to_source).to eq("AaBb")
    end

    it "strips empty spin" do
      expect(ContentSpinning.new("a{}").to_source).to eq("a")
      expect(ContentSpinning.new("a{|}").to_source).to eq("a")
      expect(ContentSpinning.new("a{||}").to_source).to eq("a")
      expect(ContentSpinning.new("{}a{}").to_source).to eq("a")
      expect(ContentSpinning.new("{}a{|}").to_source).to eq("a")

      expect(ContentSpinning.new("a{{}}").to_source).to eq("a")
      expect(ContentSpinning.new("a{{|}}").to_source).to eq("a")
      expect(ContentSpinning.new("a{{}|}").to_source).to eq("a")

      expect(ContentSpinning.new("a{a{}}").to_source).to eq("aa")
    end

    it "removes spin with no choice" do
      expect(ContentSpinning.new("{a}").to_source).to eq("a")
      expect(ContentSpinning.new("a{b}").to_source).to eq("ab")
      expect(ContentSpinning.new("a{b}c").to_source).to eq("abc")
      expect(ContentSpinning.new("a{b}c{d}e").to_source).to eq("abcde")

      expect(ContentSpinning.new("{{a}}").to_source).to eq("a")
      expect(ContentSpinning.new("a{{b}}").to_source).to eq("ab")
      expect(ContentSpinning.new("a{{b}}c").to_source).to eq("abc")
      expect(ContentSpinning.new("a{{b}}c{{d}}e").to_source).to eq("abcde")

      expect(ContentSpinning.new("{{{a}}}").to_source).to eq("a")
    end

    it "removes duplicate choices" do
      expect(ContentSpinning.new("{a|a}").to_source).to eq("a")
      expect(ContentSpinning.new("{a|a|b}").to_source).to eq("{a|b}")
      expect(ContentSpinning.new("{a|b|a|b}").to_source).to eq("{a|b}")
    end

    it "keeps legitimate spin" do
      expect(ContentSpinning.new("{a|b}").to_source).to eq("{a|b}")
      expect(ContentSpinning.new("a{b|c}").to_source).to eq("a{b|c}")
      expect(ContentSpinning.new("a{b|}").to_source).to eq("a{b|}")
      expect(ContentSpinning.new("{{a|b}|c}").to_source).to eq("{{a|b}|c}")
    end
  end
end
