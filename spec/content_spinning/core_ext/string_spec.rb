require "spec_helper"

describe String do
  describe "#spin" do
    it "is defined" do
      expect("").to respond_to(:spin)
    end
    it "calls the spin function of ContentSpinning module with the string in argument" do
      expect(ContentSpinning).to receive(:spin).with("AaBb")
      "AaBb".spin
    end
  end
end
