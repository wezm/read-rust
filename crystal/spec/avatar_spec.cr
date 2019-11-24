require "./spec_helper"

describe Avatar do
  describe "avatar_thumbnail" do
    context "svg" do
      it { Avatar.new("test.svg").thumbnail_path.should eq Path["images/u/test.svg"] }
    end

    context "jpg" do
      it { Avatar.new("test.jpg").thumbnail_path.should eq Path["images/u/thumb/test.jpg"] }
    end

    context "png" do
      it { Avatar.new("test.png").thumbnail_path.should eq Path["images/u/thumb/test.jpg"] }
    end
  end
end
