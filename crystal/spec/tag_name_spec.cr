require "./spec_helper"

describe TagName do
  describe "format" do
    context "without a suffix" do
      it "returns an empty string" do
        TagName.new("error-handling").format.should eq ""
      end
    end

    context "with a suffix" do
      it "returns the suffix" do
        TagName.new("error-handling.rss").format.should eq ".rss"
      end
    end
  end

  describe "name" do
    context "without a suffix" do
      it "returns the full name" do
        TagName.new("error-handling").name.should eq "error-handling"
      end
    end

    context "with a suffix" do
      it "returns name without the suffix" do
        TagName.new("error-handling.rss").name.should eq "error-handling"
      end
    end
  end
end
