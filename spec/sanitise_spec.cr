require "./spec_helper"

describe Sanitise do
  context "strip_tags" do
    it "strips tags" do
      stripped = Sanitise.strip_tags("<p>This is a <em>simple</em> test.</p><div><div><img src='foo.png' /></div></div>")
      stripped.should eq "This is a simple test."
    end

    it "puts whitespace around inline tags" do
      stripped = Sanitise.strip_tags("<p>Paragraph</p><span>Next to paragraph.</span>")
      stripped.should eq "Paragraph Next to paragraph."
    end

    it "strips content from script, style, etc. tags" do
      stripped = Sanitise.strip_tags("Do<script>var x = 1;</script> not<iframe>hello</iframe> want. <style>body { background-color: red }")
      stripped.should eq "Do not want."
    end
  end
end
