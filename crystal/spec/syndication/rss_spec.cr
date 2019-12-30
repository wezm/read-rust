require "../spec_helper"

describe RSS::Item do
  describe "description" do
    it "preserves simple formatting" do
      description = "This\nis some formatted text.\n\nAnd some more."
      item = RSS::Item.new(RSS::Guid.new(value: "test-guid", is_permalink: false), "Test", "https://example.com/", "Me", description, Time.utc(2019, 12, 30, 1, 4, 32))


      xml = XML.build(encoding: "UTF-8") do |xml|
        item.to_xml(xml)
      end

      xml.strip.should eq <<-RSS
      <?xml version="1.0" encoding="UTF-8"?>
      <item><guid isPermaLink="false">test-guid</guid><pubDate>Mon, 30 Dec 2019 01:04:32 +0000</pubDate><title>Test</title><link>https://example.com/</link><dc:creator>Me</dc:creator><description><![CDATA[This
      <br>is some formatted text.<br><br>And some more.]]></description></item>
      RSS
    end
  end
end
