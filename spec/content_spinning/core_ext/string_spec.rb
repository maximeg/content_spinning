# frozen_string_literal: true
require "spec_helper"

describe String do
  describe "#spin" do
    it "is defined" do
      expect("").to respond_to(:spin)
    end

    it "calls the spin function of ContentSpinning module with the string in argument" do
      expect(ContentSpinning).to receive(:spin).with("AaBb", limit: nil)
      "AaBb".spin
    end

    it "does not modify the source string" do
      source = "{a|b}"
      expect {
        source.spin
      }.not_to change { source }
    end
  end
end
